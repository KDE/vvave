#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>
#include <QApplication>
#include <QIcon>
#include "babe.h"
#include "services/local/player.h"
#include <QLibrary>
#include <QQuickStyle>

#ifdef Q_OS_ANDROID
#include "./3rdparty/kirigami/src/kirigamiplugin.h"
//#include "java/notificationclient.h"
#endif

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    app.setApplicationName(BAE::App);
    app.setApplicationVersion(BAE::Version);
    app.setWindowIcon(QIcon("qrc:/assets/babe.png"));
    QFontDatabase::addApplicationFont(":/utils/materialdesignicons-webfont.ttf");
    //    QQuickStyle::setStyle("org.kde.desktop");

    QQmlApplicationEngine engine;

    auto context = engine.rootContext();

#ifdef Q_OS_ANDROID
//    NotificationClient *notificationClient = new NotificationClient(&engine);
//    context->setContextProperty(QLatin1String("notificationClient"), notificationClient);
    KirigamiPlugin::getInstance().registerTypes();
#endif

    Babe bae;
    Player player;

    context->setContextProperty("bae", &bae);
    context->setContextProperty("player", &player);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
