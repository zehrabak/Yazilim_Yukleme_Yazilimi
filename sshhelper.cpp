#include "sshhelper.h"
#include <QDebug>
SshHelper::SshHelper(QObject *parent) : QObject(parent), session(ssh_new())
{
}

SshHelper::~SshHelper()
{
    if (session) {
        ssh_disconnect(session);
        ssh_free(session);
    }
}

bool SshHelper::connectToHost(const QString &host, const QString &user, const QString &password)
{
    ssh_options_set(session, SSH_OPTIONS_HOST, host.toStdString().c_str());
    ssh_options_set(session, SSH_OPTIONS_USER, user.toStdString().c_str());

    if (ssh_connect(session) != SSH_OK) {
        qWarning("Error connecting to host: %s", ssh_get_error(session));
        return false;
    }

    if (ssh_userauth_password(session, nullptr, password.toStdString().c_str()) != SSH_AUTH_SUCCESS) {
        qWarning("Error authenticating with password: %s", ssh_get_error(session));
        return false;
    }

    return true;
}

QString SshHelper::executeCommand(const QString &command)
{
    ssh_channel channel = ssh_channel_new(session);
    if (channel == nullptr) {
        qWarning("Error creating channel: %s", ssh_get_error(session));
        return QString();
    }

    if (ssh_channel_open_session(channel) != SSH_OK) {
        qWarning("Error opening channel: %s", ssh_get_error(session));
        ssh_channel_free(channel);
        return QString();
    }

    if (ssh_channel_request_exec(channel, command.toStdString().c_str()) != SSH_OK) {
        qWarning("Error executing command: %s", ssh_get_error(session));
        ssh_channel_close(channel);
        ssh_channel_free(channel);
        return QString();
    }

    QByteArray response;
    char buffer[256];
    int nbytes;
    while ((nbytes = ssh_channel_read(channel, buffer, sizeof(buffer), 0)) > 0) {
        response.append(buffer, nbytes);
    }

    ssh_channel_close(channel);
    ssh_channel_free(channel);

    return QString::fromUtf8(response);
}
