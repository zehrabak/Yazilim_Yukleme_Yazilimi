#ifndef PINGHELPER_H
#define PINGHELPER_H

#include <QObject>
#include <QProcess>

class PingHelper : public QObject {
    Q_OBJECT

public:
    explicit PingHelper(QObject *parent = nullptr);

public slots:
    void ping();

signals:
    void pingSuccess();
    void pingFailed();
};

#endif // PINGHELPER_H
