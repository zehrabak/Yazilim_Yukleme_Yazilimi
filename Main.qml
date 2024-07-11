import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtCore

ApplicationWindow {
    visible: true
    width: 600
    height: 400
    title: "Yazılım Yükleme Projesi"

    property string selectedLinuxFile: ""
    property string selectedRootfsFile: ""
    property bool pingSuccessful: false
    property bool sshConnected: false
    property bool uploadComplete: false

    Settings {
        id: ipSettings
        property alias ip: ipAddressField.text

    }

    GridLayout {
        anchors.fill: parent
        columns: 4
        rowSpacing: 10
        columnSpacing: 10

        RowLayout {
            Layout.columnSpan: 4
            Layout.topMargin: 20

            Text {
                text: "IP Adresi:"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                verticalAlignment: Text.AlignVCenter
            }

            TextField {
                id: ipAddressField
                placeholderText: "IP adresini girin"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 10
                width: 150
            }

            Button {
                text: "Ping Testi"
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    var ip = ipAddressField.text.trim()
                    if (ip !== "") {
                        pingHelper.ping(ip)
                        ipAddressLabel.text = ip
                    } else {
                        pingResultLabel.text = "Geçerli bir IP adresi girin."
                    }
                }
            }

            Label {
                id: pingResultLabel
                Layout.topMargin: 4
                Layout.fillWidth: true
                text: ""
            }

        }


        RowLayout {
            Layout.columnSpan: 4
            Layout.topMargin: 20

            Button {
                id: sshConnectButton
                text: "SSH Bağlan"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                enabled: pingSuccessful
                onClicked: {
                    var ip = ipAddressField.text.trim()
                    if (ip !== "") {
                        sshHelper.connectToHost(ip, "zehra", "12345")
                    } else {
                        sshResultLabel.text = "Geçerli bir IP adresi girin."
                    }
                }
            }

            Label {
                id: sshResultLabel
                Layout.topMargin: 4
                Layout.fillWidth: true
                text: ""
            }
        }

        Text {
            text: "u-boot"
            Layout.leftMargin: 20
        }
        CheckBox {
            id: ubootCheckBox
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: sshConnected
        }
        Button {
            text: "Seç"
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: ubootCheckBox.checked && sshConnected
        }

        Label {
            text: "..."
            Layout.fillWidth: true
            enabled: ubootCheckBox.checked && sshConnected
        }

        Text {
            text: "linux"
            Layout.leftMargin: 20
        }
        CheckBox {
            id: linuxCheckBox
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: sshConnected
        }
        Button {
            text: "Seç"
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: linuxCheckBox.checked && sshConnected
            onClicked: {
                if (linuxCheckBox.checked) {
                    linuxFileDialog.open()
                }
            }
        }
        Label {
            text: "..."
            id: linuxFileLabel
            Layout.fillWidth: true
            enabled: linuxCheckBox.checked && sshConnected
        }

        Text {
            text: "rootfs"
            Layout.leftMargin: 20
        }
        CheckBox {
            id: rootfsCheckBox
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: sshConnected
        }
        Button {
            text: "Seç"
            Layout.minimumWidth: 50
            Layout.maximumWidth: 50
            enabled: rootfsCheckBox.checked && sshConnected
            onClicked: {
                if (rootfsCheckBox.checked) {
                    rootfsFileDialog.open()
                }
            }
        }
        Label {
            text: "..."
            id: rootfsFileLabel
            Layout.fillWidth: true
            enabled: rootfsCheckBox.checked && sshConnected
        }

        Item {
            Layout.rowSpan: 3
        }
        ProgressBar {
            id: progressBar
            Layout.alignment: Qt.AlignLeft
            Layout.columnSpan: 4
            visible: false
            from: 0
            to: 100
            value: 0
        }
        Timer {
            id: uploadTimer
            interval: 1000
            repeat: true
            running: false
            onTriggered: {
                if (progressBar.value < 100) {
                    progressBar.value += 1
                } else {
                    uploadTimer.stop()
                    progressBar.visible = false
                    uploadComplete = true
                }
            }
        }
        Button {
            id: startButton
            text: "Karşıya Yükle"
            Layout.alignment: Qt.AlignLeft
            Layout.columnSpan: 4
            Layout.minimumWidth: 100
            Layout.maximumWidth: 150
            Layout.rightMargin: 20
            enabled: sshConnected
            onClicked: {
                progressBar.visible = true
                progressBar.value = 0
                uploadTimer.start()

                if (linuxCheckBox.checked) {
                    sshHelper.uploadFile(linuxFileLabel.text, "/mnt/update")
                }
                if (rootfsCheckBox.checked) {
                    sshHelper.uploadFile(rootfsFileLabel.text, "/mnt/update")
                }

                uploadTimer.stop()
                progressBar.value = 100
                progressBar.visible = true
                uploadComplete = true
            }
        }

        RowLayout {
            Layout.columnSpan: 4
            Layout.topMargin: 20

            Button {
                text: "Yazılımı Yükle"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                enabled: sshConnected && uploadComplete
                onClicked: {
                    console.log(sshConnected)
                    var result = sshHelper.executeRemoteCommand("sync && reboot now")
                    resultLabel.text = result
                }
            }

            Label {
                id: resultLabel
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 10
                text: ""
            }
        }

        Connections {
            target: pingHelper
            onPingInProgress: {
                pingResultLabel.text = "Ping testi devam ediyor"
                pingAnimation.running = true
            }
            onPingSuccess: {
                pingResultLabel.text = "Ping başarılı"
                pingResultLabel.color = "green"
                pingAnimation.running = false
                pingSuccessful = true;
            }
            onPingFailed: {
                pingResultLabel.text = "Ping başarısız"
                pingResultLabel.color = "red"
                pingAnimation.running = false
                pingSuccessful = false;
            }
        }

        Connections {
            target: sshHelper
            onSshConnected: {
                sshResultLabel.text = "SSH bağlantısı başarılı"
                sshResultLabel.color = "green"
                sshConnected = true;
            }
            onSshConnectionFailed: {
                sshResultLabel.text = "SSH bağlantısı başarısız"
                sshResultLabel.color = "red"
                sshConnected = false;
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
            selectedLinuxFile = selectedFile
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
            selectedRootfsFile = selectedFile
        }
        onRejected: {
            console.log("Rootfs dosyası seçimi iptal edildi.")
        }
    }

    Component.onDestruction: {
        ipSettings.ip = ipAddressField.text
    }
}

