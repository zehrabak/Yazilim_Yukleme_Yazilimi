#ifndef PINGHELPER_H
#define PINGHELPER_H

#include <QObject>
#include <QProcess>
#include <QTimer>

class PingHelper : public QObject {
    Q_OBJECT
public:
    explicit PingHelper(QObject *parent = nullptr);
    Q_INVOKABLE void ping();

signals:
    void pingInProgress();
    void pingSuccess();
    void pingFailed();

private slots:
    void onPingFinished();

private:
    QProcess process;
    QTimer *timer;
};

#endif
