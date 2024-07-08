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

#endif // PINGHELPER_H
 // PINGHELPER_H

/*#ifndef PINGHELPER_H
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

#endif // PINGHELPER_H */
