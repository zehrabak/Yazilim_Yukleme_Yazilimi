#ifndef SSHHELPER_H
#define SSHHELPER_H

#include <QObject>
#include <libssh/libssh.h>
#include <libssh/callbacks.h>
#include <QFileInfo>

class SshHelper : public QObject
{
    Q_OBJECT
public:
    explicit SshHelper(QObject *parent = nullptr);
    ~SshHelper();

    Q_INVOKABLE bool connectToHost(const QString &host, const QString &user, const QString &password = QString(""));
    Q_INVOKABLE bool executeRemoteCommand(const QString &command);
    Q_INVOKABLE bool uploadFile(const QString &localFilePath, const QString &remoteDir);

signals:
    void sshConnected();
    void sshConnectionFailed();
    void sshMessage(const QString &message);

private:
    ssh_session session;
    void initializeSshSession();
};

#endif // SSHHELPER_H


