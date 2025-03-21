#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QCommandLineParser>
#include <QIcon>

#include <KLocalizedString>

#if defined Q_OS_ANDROID || defined Q_OS_IOS
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include "kde/mpris2/mpris2.h"

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
#include "kde/mpris2/mediaplayer2player.h"
#endif

#ifdef Q_OS_ANDROID
#include <MauiKit4/Core/mauiandroid.h>
#endif

#ifdef Q_OS_MACOS
#include <MauiKit4/Core/mauimacos.h>
#endif

#include <MauiKit4/FileBrowsing/fmstatic.h>
#include <MauiKit4/Core/mauiapp.h>
#include <MauiKit4/FileBrowsing/moduleinfo.h>

#include <taglib/taglib.h>

#include "../vvave_version.h"

#include "vvave.h"

#include "services/local/artworkprovider.h"
#include "services/local/player.h"
#include "services/local/playlist.h"
#include "services/local/trackinfo.h"
#include "services/local/metadataeditor.h"

#include "models/albums/albumsmodel.h"
#include "models/playlists/playlistsmodel.h"
#include "models/tracks/tracksmodel.h"
#include "models/folders/foldersmodel.h"

#include "kde/server.h"

#define VVAVE_URI "org.maui.vvave"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qDebug() << "APP LOADING SPEED TESTS" << 0;

#ifdef Q_OS_WIN32
    qputenv("QT_MULTIMEDIA_PREFERRED_PLUGINS", "w");
#endif

#if defined Q_OS_ANDROID || defined Q_OS_IOS
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    qDebug() << "APP LOADING SPEED TESTS" << 2;

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/assets/vvave.png"));

    KLocalizedString::setApplicationDomain("vvave");
    KAboutData about(QStringLiteral("vvave"),
                     QStringLiteral("Vvave"),
                     VVAVE_VERSION_STRING,
                     i18n("Organize and listen to your music."),
                     KAboutLicense::LGPL_V3,
                     APP_COPYRIGHT_NOTICE,
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor("Camilo Higuita", i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.addAuthor("Will Chen", i18n("Developer"), QStringLiteral("intralexical@gmail.com"));

    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/vvave");
    about.setBugAddress("https://invent.kde.org/maui/vvave/-/issues");
    about.setOrganizationDomain(VVAVE_URI);
    about.setProgramLogo(app.windowIcon());
    about.setDesktopFileName("org.kde.vvave");

    about.addComponent("TagLib",
                       "",
                       QString("%1.%2.%3").arg(QString::number(TAGLIB_MAJOR_VERSION),QString::number(TAGLIB_MINOR_VERSION),QString::number(TAGLIB_PATCH_VERSION)),
                       "https://taglib.org/api/index.html");

    const auto FBData = MauiKitFileBrowsing::aboutData();
    about.addComponent(FBData.name(), MauiKitFileBrowsing::buildVersion(), FBData.version(), FBData.webAddress());

    KAboutData::setApplicationData(about);

    MauiApp::instance()->setIconName("qrc:/assets/vvave.png");

    QCommandLineParser parser;
    about.setupCommandLine(&parser);
    parser.process(app);
    about.processCommandLine(&parser);

    const QStringList args = parser.positionalArguments();
    QStringList paths;

    if (!args.isEmpty())
    {
        for(const auto &path : args)
            paths << QUrl::fromUserInput(path).toString();
    }

#ifdef Q_OS_ANDROID
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.MANAGE_EXTERNAL_STORAGE",
                                               "android.permission.WRITE_EXTERNAL_STORAGE"}))
        qWarning() << "Failed to get WRITE and READ permissions";
#endif

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
    if (AppInstance::attachToExistingInstance(QUrl::fromStringList(paths)))
    {
        // Successfully attached to existing instance of Nota
        return 0;
    }

    AppInstance::registerService();
#endif

    auto server =  std::make_unique<Server>();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/app/maui/vvave/main.qml"));

    qDebug() << "APP LOADING SPEED TESTS" << 3;

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url, args, &server](QObject *obj, const QUrl &objUrl)
        {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);

            server->setQmlObject(obj);

            if (!args.isEmpty())
                server->openFiles(args);

        }, Qt::QueuedConnection);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    qmlRegisterSingletonInstance<vvave>(VVAVE_URI, 1, 0, "Vvave", vvave::instance());
    qmlRegisterSingletonInstance<Server>(VVAVE_URI, 1, 0, "Server", server.get());

    qmlRegisterType<TracksModel>(VVAVE_URI, 1, 0, "Tracks");
    qmlRegisterType<AlbumsModel>(VVAVE_URI, 1, 0, "Albums");
    qmlRegisterType<FoldersModel>(VVAVE_URI, 1, 0, "Folders");

    qmlRegisterType<Player>(VVAVE_URI, 1, 0, "Player");
    qmlRegisterType<Playlist>(VVAVE_URI, 1, 0, "Playlist");
    qmlRegisterType<Mpris2>(VVAVE_URI, 1, 0, "Mpris2");

    qmlRegisterType<TrackInfo>(VVAVE_URI, 1, 0, "TrackInfo");
    qmlRegisterType<MetadataEditor>(VVAVE_URI, 1, 0, "MetadataEditor");

    qmlRegisterType<PlaylistsModel>(VVAVE_URI, 1, 0, "Playlists");

    engine.addImageProvider("artwork", new ArtworkProvider());

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID
    qRegisterMetaType<MediaPlayer2Player *>();
#endif

    qDebug() << "APP LOADING SPEED TESTS" << 4;

    engine.load(url);

    qDebug() << "APP LOADING SPEED TESTS" << 5;

#ifdef Q_OS_MACOS
    //	MAUIMacOS::removeTitlebarFromWindow();
#endif

    return app.exec();
}
