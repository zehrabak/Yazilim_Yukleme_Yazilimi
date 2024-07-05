#include "PingHelper.h"
#include <QDebug>

PingHelper::PingHelper(QObject *parent) : QObject(parent) {}

void PingHelper::ping() {
    QProcess process;
    process.start("ping", QStringList() << "127.0.0.1");
    process.waitForFinished();

    if (process.exitCode() == 0) {
        emit pingSuccess();
    } else {
        emit pingFailed();
    }
}
