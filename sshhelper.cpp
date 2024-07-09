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
    const char *ip = "10.255.0.45";

    ssh_options_set(session, SSH_OPTIONS_HOST, ip);
    ssh_options_set(session, SSH_OPTIONS_USER, user.toStdString().c_str());

    int rc = ssh_connect(session);
    if (rc != SSH_OK) {
        qWarning() << "Ana bilgisayara bağlanırken hata oluştu:" << ssh_get_error(session);
        return false;
    }

    rc = ssh_userauth_password(session, nullptr, password.toStdString().c_str());
    if (rc != SSH_AUTH_SUCCESS) {
        qWarning() << "Parola ile kimlik doğrulama başarısız oldu:" << ssh_get_error(session);
        qWarning() << "Devam edebilecek kimlik doğrulama yöntemleri: publickey,password";
        return false;
    }

    qDebug() << "SSH bağlantısı başarıyla kuruldu.";
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


bool SshHelper::uploadFile(const QString &localFilePath, const QString &remoteDir)
{
    // QFile kullanmadan önce file URL'sini yerel bir dosya yoluna dönüştür
    QUrl fileUrl(localFilePath);
    QString localFilePathDecoded = fileUrl.toLocalFile();

    ssh_scp scp = ssh_scp_new(session, SSH_SCP_WRITE, remoteDir.toStdString().c_str());
    if (scp == nullptr) {
        qWarning("Error creating SCP session: %s", ssh_get_error(session));
        return false;
    }

    if (ssh_scp_init(scp) != SSH_OK) {
        qWarning("Error initializing SCP session: %s", ssh_get_error(session));
        ssh_scp_free(scp);
        return false;
    }

    QFile file(localFilePathDecoded);
    qDebug() << "Dosya yolu:" << localFilePathDecoded; // Dosya yolunu kontrol etmek için
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("Cannot open local file for reading: %s", qPrintable(file.errorString()));
        ssh_scp_free(scp);
        return false;
    }

    QByteArray buffer;
    qint64 bytesRead;
    while (!file.atEnd()) {
        buffer = file.read(4096); // Buffer boyutunu dosya boyutuna göre ayarla
        bytesRead = buffer.size();
        if (ssh_scp_write(scp, buffer.constData(), bytesRead) != SSH_OK) {
            qWarning("Error writing to SCP channel: %s", ssh_get_error(session));
            file.close();
            ssh_scp_close(scp);
            ssh_scp_free(scp);
            return false;
        }
    }

    file.close();
    ssh_scp_close(scp);
    ssh_scp_free(scp);

    qDebug() << "File uploaded successfully.";
    return true;
}



