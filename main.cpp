#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>
#include <QApplication>

#include "babe.h"
#include "services/local/player.h"
#include <QLibrary>

//#ifdef Q_OS_ANDROID
//#include "./3rdparty/kirigami/src/kirigamiplugin.h"
//#endif

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/utils/materialdesignicons-webfont.ttf");

    QQmlApplicationEngine engine;

    auto context = engine.rootContext();

    Babe bae;
    Player player;
//    bae.registerTypes();

    context->setContextProperty("bae", &bae);
    context->setContextProperty("player", &player);

    //#ifdef Q_OS_ANDROID
    //    KirigamiPlugin::getInstance().registerTypes();
    //#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
