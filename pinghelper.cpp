#include "PingHelper.h"
#include <QDebug>

PingHelper::PingHelper(QObject *parent) : QObject(parent) {
    connect(&process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &PingHelper::onPingFinished);
}

void PingHelper::ping(const QString &ipAddress) {
    emit pingInProgress();
    process.start("ping", QStringList() << ipAddress);
}

void PingHelper::onPingFinished() {
    if (process.exitCode() == 0) {
        emit pingSuccess();
    } else {
        emit pingFailed();
    }
}

