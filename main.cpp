#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include "db/collectionDB.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    QFontDatabase::addApplicationFont(":/utils/materialdesignicons-webfont.ttf");

    qmlRegisterType<CollectionDB>("org.babe.qml", 1, 0, "CON");


    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
