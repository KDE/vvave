#include <QFontDatabase>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QCommandLineParser>
#include <QIcon>

#if defined Q_OS_MACOS || defined Q_OS_WIN
#include <KF5/KI18n/KLocalizedString>
#else
#include <KI18n/KLocalizedString>
#endif

#if defined Q_OS_ANDROID || defined Q_OS_IOS
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include "kde/mpris2/mpris2.h"

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#include "kde/mpris2/mediaplayer2player.h"
#endif

#ifdef Q_OS_ANDROID
#include "mauiandroid.h"
#endif

#ifdef Q_OS_MACOS
#include "mauimacos.h"
#endif

#include <MauiKit/fmstatic.h>
#include <MauiKit/mauiapp.h>

#include "../vvave_version.h"

#include "utils/bae.h"

#include "vvave.h"

#include "services/local/artworkprovider.h"
#include "services/local/player.h"
#include "services/local/playlist.h"
#include "services/local/trackinfo.h"
#include "services/local/metadataeditor.h"

#include "models/albums/albumsmodel.h"
#include "models/cloud/cloud.h"
#include "models/playlists/playlistsmodel.h"
#include "models/tracks/tracksmodel.h"
#include "models/folders/foldersmodel.h"

#define VVAVE_URI "org.maui.vvave"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

#ifdef Q_OS_WIN32
    qputenv("QT_MULTIMEDIA_PREFERRED_PLUGINS", "w");
#endif

#if defined Q_OS_ANDROID | defined Q_OS_IOS
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

#ifdef Q_OS_ANDROID
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon("qrc:/assets/vvave.png"));

    MauiApp::instance()->setHandleAccounts(true); // for now pix can not handle cloud accounts
    MauiApp::instance()->setIconName("qrc:/assets/vvave.png");

    KLocalizedString::setApplicationDomain("vvave");
    KAboutData about(
        QStringLiteral("vvave"), i18n("Vvave"), VVAVE_VERSION_STRING, i18n("Vvave lets you organize, browse and listen to your local and online music collection."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())),i18n("Built from ") + QString(GIT_BRANCH) + " " + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/vvave");
    about.setBugAddress("https://invent.kde.org/maui/vvave/-/issues");
    about.setOrganizationDomain(VVAVE_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);

    const QStringList args = parser.positionalArguments();

    QFontDatabase::addApplicationFont(":/assets/materialdesignicons-webfont.ttf");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url, args](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);

            if (!args.isEmpty())
                vvave::instance()->openUrls(args);
        },
        Qt::QueuedConnection);

    qmlRegisterSingletonInstance<vvave>(VVAVE_URI, 1, 0, "Vvave", vvave::instance());

    qmlRegisterType<TracksModel>(VVAVE_URI, 1, 0, "Tracks");
    qmlRegisterType<PlaylistsModel>(VVAVE_URI, 1, 0, "Playlists");
    qmlRegisterType<AlbumsModel>(VVAVE_URI, 1, 0, "Albums");
    qmlRegisterType<Cloud>(VVAVE_URI, 1, 0, "Cloud");
    qmlRegisterType<FoldersModel>(VVAVE_URI, 1, 0, "Folders");

    qmlRegisterType<Player>(VVAVE_URI, 1, 0, "Player");
    qmlRegisterType<Playlist>(VVAVE_URI, 1, 0, "Playlist");
    qmlRegisterType<Mpris2>(VVAVE_URI, 1, 0, "Mpris2");

    qmlRegisterType<TrackInfo>(VVAVE_URI, 1, 0, "TrackInfo");
    qmlRegisterType<MetadataEditor>(VVAVE_URI, 1, 0, "MetadataEditor");

    engine.addImageProvider("artwork", new ArtworkProvider());

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    qRegisterMetaType<MediaPlayer2Player *>();
#endif

    engine.load(url);

#ifdef Q_OS_MACOS
    //	MAUIMacOS::removeTitlebarFromWindow();
#endif

    return app.exec();
}
