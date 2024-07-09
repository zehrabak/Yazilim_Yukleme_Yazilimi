import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

ApplicationWindow {
    visible: true
    width: 600
    height: 400
    title: "Yazılım Yükleme Projesi"

    GridLayout {
        anchors.fill: parent
        columns: 4
        rowSpacing: 10
        columnSpacing: 10

        RowLayout {
            Layout.columnSpan: 4

            Button {
                id: connectButton
                text: "Bağlan"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                Layout.topMargin: 10
                onClicked: {
                    pingHelper.ping()
                }
            }

            Label {
                id: pingResultLabel
                text: ""  // Başlangıçta boş metin
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                Layout.topMargin: 10
            }
        }

        // SSH bağlantısı için alan
        RowLayout {
            Layout.columnSpan: 4
            Layout.topMargin: 20

            Button {
                id: sshConnectButton
                text: "SSH Bağlan"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                onClicked: {
                    sshHelper.connectToHost("10.255.0.45", "zehra", "12345")
                }
            }

            Label {
                id: sshResultLabel
                text: ""
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
            }
        }

        // Diğer içerikler buraya gelecek...
        Text {
            text: "u-boot"
            Layout.leftMargin: 20
        }
        CheckBox {
            id: ubootCheckBox
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
        }
        Button {
            text: "Seç"
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: ubootCheckBox.checked

        }

        Label {
            text: "Label 1"
            Layout.fillWidth: true
            enabled: ubootCheckBox.checked
        }

        Text {
            text: "linux"
            Layout.leftMargin: 20
        }
        CheckBox {
            id: linuxCheckBox
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
        }
        Button {
            text: "Seç"
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: linuxCheckBox.checked
            onClicked: {
                if (linuxCheckBox.checked) {
                    linuxFileDialog.open()
                }
            }
        }
        Label {
            text: "Label 2"
            id: linuxFileLabel
            Layout.fillWidth: true
            enabled: linuxCheckBox.checked
        }

        Text {
            text: "rootfs"
            Layout.leftMargin: 20
        }
        CheckBox {
            id: rootfsCheckBox
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
        }
        Button {
            text: "Seç"
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: rootfsCheckBox.checked
            onClicked: {
                if (rootfsCheckBox.checked) {
                    rootfsFileDialog.open()
                }
            }
        }
        Label {
            text: "Label 3"
            id: rootfsFileLabel
            Layout.fillWidth: true
            enabled: rootfsCheckBox.checked
        }

        Item {
            Layout.rowSpan: 3
        }

        Button {
            text: "Başla"
            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 4
        }

        Connections {
            target: pingHelper
            onPingInProgress: {
                pingResultLabel.text = "Ping testi devam ediyor"
                pingAnimation.running = true
            }
            onPingSuccess: {
                pingResultLabel.text = "Ping başarılı"
                pingResultLabel.color = "green"  // Başarılı durum için yeşil renk
                pingAnimation.running = false
            }
            onPingFailed: {
                pingResultLabel.text = "Ping başarısız"
                pingResultLabel.color = "red"  // Başarısız durum için kırmızı renk
                pingAnimation.running = false
            }
        }

        Connections {
            target: sshHelper
            onSshConnected: {
                sshResultLabel.text = "SSH bağlantısı başarılı"
                sshResultLabel.color = "green"
            }
            onSshConnectionFailed: {
                sshResultLabel.text = "SSH bağlantısı başarısız"
                sshResultLabel.color = "red"
            }
            onSshMessage: {
                sshResultLabel.text = message
            }
        }
    }

    Timer {
        id: pingAnimation
        interval: 500
        repeat: true
        running: false
        onTriggered: {
            if (pingResultLabel.text === "Ping testi devam ediyor") {
                pingResultLabel.text = "Ping testi devam ediyor ."
            } else if (pingResultLabel.text === "Ping testi devam ediyor .") {
                pingResultLabel.text = "Ping testi devam ediyor . ."
            } else if (pingResultLabel.text === "Ping testi devam ediyor . .") {
                pingResultLabel.text = "Ping testi devam ediyor . . ."
            } else {
                pingResultLabel.text = "Ping testi devam ediyor"
            }
        }
    }

    FileDialog {
        id: linuxFileDialog
        title: "Linux Dosyasını Seçin"
        onAccepted: {
            console.log("Seçilen dosya: " + selectedFile)
            linuxFileLabel.text = selectedFile
            sshHelper.uploadFile(selectedFile, "/mnt/update");
            // Burada dosya işlemlerini yap.
        }
        onRejected: {
            console.log("Linux dosyası seçimi iptal edildi.")
        }
    }

    FileDialog {
        id: rootfsFileDialog
        title: "Rootfs Dosyasını Seçin"

        onAccepted: {
            console.log("Seçilen dosya: " + selectedFile)
            rootfsFileLabel.text = selectedFile
            sshHelper.uploadFile(selectedFile, "/mnt/update");
        }
        onRejected: {
            console.log("Rootfs dosyası seçimi iptal edildi.")
        }
    }
}

