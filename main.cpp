#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "PingHelper.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    PingHelper pingHelper;

    engine.rootContext()->setContextProperty("pingHelper", &pingHelper);

    const QUrl url(QStringLiteral("qrc:/YazilimYuklemeProjesi/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
        );

    engine.load(url);

    return app.exec();
}

