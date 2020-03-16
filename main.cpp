#include <QQmlApplicationEngine>
#include <QFontDatabase>

#include <QIcon>
#include <QLibrary>
#include <QCommandLineParser>

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#include "fmstatic.h"
#else
#include <MauiKit/fmstatic.h>
#endif

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QIcon>
#include "mauiandroid.h"
#else
#include <QApplication>
#endif

#include <QtWebView>

#include "vvave.h"

#include "utils/bae.h"
#include "services/web/youtube.h"
#include "services/local/player.h"

#include "models/tracks/tracksmodel.h"
#include "models/albums/albumsmodel.h"
#include "models/playlists/playlistsmodel.h"
#include "models/cloud/cloud.h"

#ifdef Q_OS_ANDROID
Q_DECL_EXPORT
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_WIN32
    qputenv("QT_MULTIMEDIA_PREFERRED_PLUGINS", "w");
#endif

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setApplicationName(BAE::appName);
    app.setApplicationVersion(BAE::version);
    app.setApplicationDisplayName(BAE::displayName);
    app.setOrganizationName(BAE::orgName);
    app.setOrganizationDomain(BAE::orgDomain);
    app.setWindowIcon(QIcon("qrc:/assets/vvave.png"));

    QCommandLineParser parser;
    parser.setApplicationDescription(BAE::description);

    const QCommandLineOption versionOption = parser.addVersionOption();
    parser.process(app);

    const QStringList args = parser.positionalArguments();
      static auto babe = new  vvave;
    static auto youtube = new YouTube;
    //    Spotify spotify;

    QFontDatabase::addApplicationFont(":/assets/materialdesignicons-webfont.ttf");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url, args](QObject *obj, const QUrl &objUrl)
    {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
        if(FMStatic::loadSettings("Settings", "ScanCollectionOnStartUp", true ).toBool())
        {
            const auto currentSources = vvave::getSourceFolders();
            babe->scanDir(currentSources.isEmpty() ? BAE::defaultSources : currentSources);
        }

        if(!args.isEmpty())
            babe->openUrls(args);

    }, Qt::QueuedConnection);

    qmlRegisterSingletonType<vvave>("org.maui.vvave", 1, 0, "Vvave",
                                  [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return babe;
    });

    qmlRegisterSingletonType<vvave>("org.maui.vvave", 1, 0, "YouTube",
                                  [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)
        return youtube;
    });

    qmlRegisterType<TracksModel>("TracksList", 1, 0, "Tracks");
    qmlRegisterType<PlaylistsModel>("PlaylistsList", 1, 0, "Playlists");
    qmlRegisterType<AlbumsModel>("AlbumsList", 1, 0, "Albums");
    qmlRegisterType<Cloud>("CloudList", 1, 0, "Cloud");
    qmlRegisterType<Player>("Player", 1, 0, "Player");

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes();
#endif
    QtWebView::initialize();

    engine.load(url);
    return app.exec();
}
