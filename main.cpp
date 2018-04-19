#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>
#include <QApplication>
#include <QIcon>
#include "babe.h"
#include "services/local/player.h"
#include <QLibrary>
// #include <QQuickStyle>
#include <QStyleHints>
#include "services/local/linking.h"

#ifdef Q_OS_ANDROID
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
#include <QtWebView/QtWebView>
#else
#include <QtWebEngine>
#endif

#include "utils/bae.h"
#include <QCommandLineParser>
#include "services/web/youtube.h"

#ifdef Q_OS_ANDROID
Q_DECL_EXPORT
#endif
int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setApplicationName(BAE::App);
    app.setApplicationVersion(BAE::Version);
    app.setWindowIcon(QIcon("qrc:/assets/vvave.png"));
    app.setDesktopFileName(BAE::App);

    /*needed for mobile*/
    if(BAE::isMobile())
    {
        int pressAndHoldInterval = 1000; // in [ms]
        QGuiApplication::styleHints()->setMousePressAndHoldInterval(pressAndHoldInterval);
    }

    QCommandLineParser parser;
    parser.setApplicationDescription("vvave music player");
    const QCommandLineOption versionOption = parser.addVersionOption();
    parser.process(app);

    const QStringList args = parser.positionalArguments();
    bool version = parser.isSet(versionOption);

    if(version)
    {
        printf("%s %s\n", qPrintable(QCoreApplication::applicationName()),
               qPrintable(QCoreApplication::applicationVersion()));
        return 0;
    }

    Babe bae;
    /* Services */
    YouTube youtube;

    QFontDatabase::addApplicationFont(":/utils/materialdesignicons-webfont.ttf");

    QQmlApplicationEngine engine;

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, [&]()
    {
        qDebug()<<"FINISHED LOADING QML APP";
        bae.refreshCollection();
    });

    auto context = engine.rootContext();
    context->setContextProperty("player", &bae.player);
    context->setContextProperty("bae", &bae);
    context->setContextProperty("youtube", &youtube);
    context->setContextProperty("link", &bae.link);

    qmlRegisterUncreatableMetaObject(
      LINK::staticMetaObject, // static meta object
      "Link.Codes",                // import statement (can be any string)
      1, 0,                          // major and minor version of the import
      "LINK",                 // name in QML (does not have to match C++ name)
      "Error: only enums"            // error in case someone tries to create a MyNamespace object
    );

#ifdef Q_OS_ANDROID 
    KirigamiPlugin::getInstance().registerTypes();
    QtWebView::initialize();
#else
//    if(QQuickStyle::availableStyles().contains("nomad"))
//        QQuickStyle::setStyle("nomad");

    QtWebEngine::initialize();
#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
