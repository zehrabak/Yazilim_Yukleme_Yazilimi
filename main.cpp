#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlEngine>
#include <QSettings>
#include <QTranslator>
#include <QLocale>
#include <QDebug>
#include "PingHelper.h"
#include "SshHelper.h"
#include <QLibraryInfo>

int main(int argc, char *argv[])
{

    QGuiApplication app(argc, argv);

    app.setOrganizationName("Some Company");
    app.setOrganizationDomain("somecompany.com");
    app.setApplicationName("Amazing Application");

    QQmlApplicationEngine engine;
    PingHelper pingHelper;
    engine.rootContext()->setContextProperty("pingHelper", &pingHelper);

    SshHelper sshHelper;
    engine.rootContext()->setContextProperty("sshHelper", &sshHelper);

    const QUrl url(QStringLiteral("qrc:/YazilimYuklemeProjesi/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    QTranslator translator;

    // Hedef dil olarak en_EN belirleyin
    QString locale = "en.qm";
    qDebug() << "Locale:" << locale;

    // Çeviri dosyasının yolu
    QString translationPath = "translations/";

    // Çeviri dosyasını yükle
    if (translator.load(translationPath + "yazilim_yukleme_" + locale)) {
        app.installTranslator(&translator);
        qDebug() << "Loaded translation file:" << translationPath + "yazilim_yukleme_" + locale;
    } else {
        qWarning() << "Failed to load translation file for locale:" << locale;
    }

    engine.retranslate();

    QString str = QObject::tr("Seç");
    qDebug() << str;

    return app.exec();
}
