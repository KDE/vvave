#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>
#include <QApplication>
#include <QIcon>
#include <QLibrary>
#include <QStyleHints>
#include <QQuickStyle>
#include <QCommandLineParser>
#include "vvave.h"
#include "services/local/player.h"

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#endif

#ifdef Q_OS_ANDROID
#include <QtWebView/QtWebView>
#include <QGuiApplication>
#include <QIcon>
#include "mauiandroid.h"
#else
#include <QApplication>
#include <QtWebEngine>
#endif

#include "utils/bae.h"
#include "services/web/youtube.h"
//#include "services/web/Spotify/spotify.h"
//#include "services/local/linking.h"
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

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QGuiApplication::styleHints()->setMousePressAndHoldInterval(1000); // in [ms]
    if (!MAUIAndroid::checkRunTimePermissions())
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
    QStringList urls;
    if(!args.isEmpty())
        urls = args;

    vvave vvave;

    /* Services */
    YouTube youtube;
//    Spotify spotify;

    QFontDatabase::addApplicationFont(":/assets/materialdesignicons-webfont.ttf");

    QQmlApplicationEngine engine;

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, [&]()
    {
        qDebug()<<"FINISHED LOADING QML APP";
        const auto currentSources = vvave.getSourceFolders();
        vvave.scanDir(currentSources.isEmpty() ? BAE::defaultSources : currentSources);
        if(!urls.isEmpty())
            vvave.openUrls(urls);
    });

    auto context = engine.rootContext();
    context->setContextProperty("vvave", &vvave);
    context->setContextProperty("youtube", &youtube);

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

#ifdef Q_OS_ANDROID
    QtWebView::initialize();
#else
    QtWebEngine::initialize();
#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
