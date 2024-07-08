#include "PingHelper.h"
#include <QDebug>

PingHelper::PingHelper(QObject *parent) : QObject(parent) {
    connect(&process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &PingHelper::onPingFinished);
}

void PingHelper::ping() {
    emit pingInProgress();
    process.start("ping", QStringList() << "192.168.1.1");
}

void PingHelper::onPingFinished() {
    if (process.exitCode() == 0) {
        emit pingSuccess();
    } else {
        emit pingFailed();
    }
}

/*#include "PingHelper.h"
#include <QDebug>

PingHelper::PingHelper(QObject *parent) : QObject(parent) {}

void PingHelper::ping() {
    QProcess process;
    process.start("ping", QStringList() << "192.168.1.1");
    process.waitForFinished();

    if (process.exitCode() == 0) {
        emit pingSuccess();
    } else {
        emit pingFailed();
    }
} */
