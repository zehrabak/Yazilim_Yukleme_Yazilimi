#include "sshhelper.h"
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QUrl>

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
    QByteArray ipBytes = host.toUtf8(); // or toLatin1() depending on your needs
    const char *ip = ipBytes.constData(); // pointer to the raw data

    ssh_options_set(session, SSH_OPTIONS_HOST, ip);
    ssh_options_set(session, SSH_OPTIONS_USER, user.toStdString().c_str());

    int rc = ssh_connect(session);
    if (rc != SSH_OK) {
        qWarning() << "Ana bilgisayara bağlanırken hata oluştu:" << ssh_get_error(session);
        emit sshConnectionFailed();
        return false;
    }

    rc = ssh_userauth_password(session, nullptr, password.toStdString().c_str());
    if (rc != SSH_AUTH_SUCCESS) {
        qWarning() << "Parola ile kimlik doğrulama başarısız oldu:" << ssh_get_error(session);
        qWarning() << "Devam edebilecek kimlik doğrulama yöntemleri: publickey,password";
        emit sshConnectionFailed();
        return false;
    }
    emit sshMessage("SSH bağlantısı başarıyla kuruldu.");
    qDebug() << "SSH bağlantısı başarıyla kuruldu.";
    emit sshConnected();
    return true;
}

bool SshHelper::executeRemoteCommand(const QString &command)
{
    ssh_channel channel = ssh_channel_new(session);
    if (channel == nullptr) {
        qWarning() << "Error creating channel: " << ssh_get_error(session);
        return false;
    }

    if (ssh_channel_open_session(channel) != SSH_OK) {
        qWarning() << "Error opening channel: " << ssh_get_error(session);
        ssh_channel_free(channel);
        return false;
    }

    if (ssh_channel_request_exec(channel, command.toStdString().c_str()) != SSH_OK) {
        qWarning() << "Error executing command: " << ssh_get_error(session);
        ssh_channel_close(channel);
        ssh_channel_free(channel);
        return false;
    }

    char buffer[256];
    int nbytes;
    while ((nbytes = ssh_channel_read(channel, buffer, sizeof(buffer), 0)) > 0) {
        QString output = QString::fromUtf8(buffer, nbytes);
        emit sshMessage(output);
        qDebug() << "Command output:" << output;
    }

    ssh_channel_send_eof(channel);
    ssh_channel_close(channel);
    ssh_channel_free(channel);

    qDebug() << "Remote command executed successfully: " << command;
    return true;
}

bool SshHelper::uploadFile(const QString &localFilePath, const QString &remoteDir)
{
    QUrl fileUrl(localFilePath);
    QString localFilePathDecoded = fileUrl.toLocalFile();

    ssh_scp scp = ssh_scp_new(session, SSH_SCP_WRITE, remoteDir.toStdString().c_str());
    if (scp == nullptr) {
        qWarning() << "Error creating SCP session: " << ssh_get_error(session);
        return false;
    }

    if (ssh_scp_init(scp) != SSH_OK) {
        qWarning() << "Error initializing SCP session: " << ssh_get_error(session);
        ssh_scp_free(scp);
        return false;
    }

    QFile file(localFilePathDecoded);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Cannot open local file for reading: " << file.errorString();
        ssh_scp_free(scp);
        return false;
    }

    QFileInfo fileInfo(localFilePathDecoded);
    if (ssh_scp_push_file(scp, fileInfo.fileName().toStdString().c_str(), file.size(), 0644) != SSH_OK) {
        qWarning() << "Error pushing file: " << ssh_get_error(session);
        file.close();
        ssh_scp_free(scp);
        return false;
    }

    QByteArray buffer;
    buffer.resize(4096);
    qint64 bytesRead;
    while ((bytesRead = file.read(buffer.data(), buffer.size())) > 0) {
        if (ssh_scp_write(scp, buffer.constData(), bytesRead) != SSH_OK) {
            qWarning() << "Error writing to SCP channel: " << ssh_get_error(session);
            file.close();
            ssh_scp_free(scp);
            return false;
        }
    }

    file.close();
    ssh_scp_close(scp);
    ssh_scp_free(scp);

    qDebug() << "File uploaded successfully.";
    emit sshMessage("File uploaded successfully.");
    return true;
}

