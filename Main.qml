import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import QtCore
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    visible: true
    width: 700
    height: 500
    title: "Yazılım Yükleme Projesi"
    color: "lightgrey"

    property string selectedLinuxFile: ""
    property string selectedRootfsFile: ""
    property string selectedBEKB1File: ""
    property string selectedBEKB2File: ""
    property string selectedBEKB3File: ""
    property string selectedSKPFile: ""
    property string selectedGGAPFile: ""
    property bool pingSuccessful: false
    property bool sshConnected: false
    property bool uploadComplete: false

    Settings {
        id: ipSettings
        property alias ip: ipAddressField.text
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.columnSpan: 4
            Layout.topMargin: 20
            Layout.alignment: Qt.AlignHCenter

            Text {
                text: "IP Adresi:"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                verticalAlignment: Text.AlignVCenter
                color: "black"
                font.bold: true
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
                background: Rectangle {
                    color: "#3498db"
                    radius: 5
                }

                onClicked: {
                    var ip = ipAddressField.text.trim()
                    if (ip !== "") {
                        pingHelper.ping(ip)
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
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: sshConnectButton
                text: "SSH Testi"
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                background: Rectangle {
                    color: "#3498db"
                    radius: 5
                }

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

        TabBar {
            id: bar
            width: parent.width
            contentWidth: 700

            TabButton {
                text: "AGP"
                onClicked: bar.currentIndex = 0
            }
            TabButton {
                text: "BEKB"
                onClicked: bar.currentIndex = 1
            }
            TabButton {
                text: "SKP"
                onClicked: bar.currentIndex = 2
            }
            TabButton {
                text: "GGAP"
                onClicked: bar.currentIndex = 3
            }
        }

        StackLayout {
            id: stack
            width: parent.width
            currentIndex: bar.currentIndex

            Item {
                GridLayout {
                    columns: 4
                    rowSpacing: 10
                    columnSpacing: 10

                    // u-boot Row
                    Text {
                        text: "u-boot"
                        Layout.leftMargin: 20
                        Layout.alignment: Qt.AlignLeft
                        Layout.columnSpan: 1
                        Layout.row: 0
                        color: "darkblue"
                    }
                    CheckBox {
                        id: ubootCheckBox
                        Layout.alignment: Qt.AlignLeft
                        Layout.column: 1
                        Layout.row: 0
                        enabled: sshConnected
                    }
                    Button {
                        text: "Seç"
                        Layout.alignment: Qt.AlignLeft
                        Layout.column: 2
                        Layout.row: 0
                        enabled: ubootCheckBox.checked && sshConnected
                        background: Rectangle {
                            color: "#3498db"
                            radius: 5
                        }
                    }
                    Label {
                        text: "..."
                        Layout.fillWidth: true
                        Layout.column: 3
                        Layout.row: 0
                        enabled: ubootCheckBox.checked && sshConnected
                    }

                    // linux Row
                    Text {
                        text: "linux"
                        Layout.leftMargin: 20
                        Layout.alignment: Qt.AlignLeft
                        Layout.columnSpan: 1
                        Layout.row: 1
                        color: "darkblue"
                    }
                    CheckBox {
                        id: linuxCheckBox
                        Layout.alignment: Qt.AlignLeft
                        Layout.column: 1
                        Layout.row: 1
                        enabled: sshConnected
                    }
                    Button {
                        text: "Seç"
                        Layout.alignment: Qt.AlignLeft
                        Layout.column: 2
                        Layout.row: 1
                        enabled: linuxCheckBox.checked && sshConnected
                        background: Rectangle {
                            color: "#3498db"
                            radius: 5
                        }
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
                        Layout.column: 3
                        Layout.row: 1
                        enabled: linuxCheckBox.checked && sshConnected
                    }

                    // rootfs Row
                    Text {
                        text: "rootfs"
                        Layout.leftMargin: 20
                        Layout.alignment: Qt.AlignLeft
                        Layout.columnSpan: 1
                        Layout.row: 2
                        color: "darkblue"
                    }
                    CheckBox {
                        id: rootfsCheckBox
                        Layout.alignment: Qt.AlignLeft
                        Layout.column: 1
                        Layout.row: 2
                        enabled: sshConnected
                    }
                    Button {
                        text: "Seç"
                        Layout.alignment: Qt.AlignLeft
                        Layout.column: 2
                        Layout.row: 2
                        enabled: rootfsCheckBox.checked && sshConnected
                        background: Rectangle {
                            color: "#3498db"
                            radius: 5
                        }
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
                        Layout.column: 3
                        Layout.row: 2
                        enabled: rootfsCheckBox.checked && sshConnected
                    }
                }

            }

            Item {

                ColumnLayout {

                    ComboBox {
                        id:bekbComboBox
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 20
                        width: parent.width / 2
                        model: ["BKB1", "BKB2", "BKB3"]
                        onCurrentTextChanged: {
                            switch (currentText) {
                                case "BKB1":
                                fileDialog1.title = "BKB1 Dosyasını Seçin"
                                break;
                                case "BKB2":
                                fileDialog1.title = "BKB2 Dosyasını Seçin"
                                break;
                                case "BKB3":
                                fileDialog1.title = "BKB3 Dosyasını Seçin"
                                break;
                            }
                        }
                    }
                    GridLayout {
                        columns: 4
                        rowSpacing: 10
                        columnSpacing: 10
                        id: gridLayoutBekb

                        // u-boot Row
                        Text {
                            text: "u-boot"
                            Layout.leftMargin: 20
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 1
                            Layout.row: 0
                            color: "darkblue"

                        }
                        Button {
                            text: "Seç"
                            Layout.alignment: Qt.AlignLeft
                            Layout.column: 2
                            Layout.row: 0
                            enabled: sshConnected
                            background: Rectangle {
                                color: "#3498db"
                                radius: 5
                            }
                            onClicked: {
                                fileDialog1.open()
                            }
                        }
                        Label {
                            text: "..."
                            id: bekb1Filelabel
                            Layout.fillWidth: true
                            Layout.column: 3
                            Layout.row: 0
                            enabled:sshConnected
                        }
                        Label {
                            text: "..."
                            id: bekb2Filelabel
                            Layout.fillWidth: true
                            Layout.column: 3
                            Layout.row: 1
                            enabled:sshConnected
                        }
                        Label {
                            text: "..."
                            id: bekb3Filelabel
                            Layout.fillWidth: true
                            Layout.column: 3
                            Layout.row: 2
                            enabled:sshConnected
                        }

                    }
                }
            }

            Item {
                ColumnLayout {
                    GridLayout {
                       columns: 4
                        rowSpacing: 20
                        columnSpacing: 20
                        Layout.topMargin: 20

                        // u-boot Row
                        Text {
                            text: "u-boot"
                            Layout.leftMargin: 20
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 1
                            Layout.row: 0
                            color: "darkblue"
                        }
                        Button {
                            text: "Seç"
                            Layout.alignment: Qt.AlignLeft
                            Layout.column: 2
                            Layout.row: 0
                            enabled: sshConnected
                            background: Rectangle {
                                color: "#3498db"
                                radius: 5
                            }
                            onClicked: {
                                fileDialog.title = "SKP Dosyasını Seçin"
                                fileDialog.open()
                            }
                        }
                        Label {
                            text: "..."
                            id: skpFilelabel
                            Layout.fillWidth: true
                            Layout.column: 3
                            Layout.row: 0
                            enabled:sshConnected
                        }
                    }
                }
        }
            Item {
                ColumnLayout {
                    GridLayout {
                        columns: 4
                        rowSpacing: 20
                        columnSpacing: 20
                        Layout.topMargin: 20

                        // u-boot Row
                        Text {
                            text: "u-boot"
                            Layout.leftMargin: 20
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 1
                            Layout.row: 0
                            color: "darkblue"
                        }
                        Button {
                            text: "Seç"
                            Layout.alignment: Qt.AlignLeft
                            Layout.column: 2
                            Layout.row: 0
                            enabled: sshConnected
                            background: Rectangle {
                                color: "#3498db"
                                radius: 5
                            }
                            onClicked: {
                                fileDialog.title = "GGAP Dosyasını Seçin"
                                fileDialog.open()
                            }
                        }
                        Label {
                            text: "..."
                            id: ggapFilelabel
                            Layout.fillWidth: true
                            Layout.column: 3
                            Layout.row: 0
                            enabled:sshConnected
                        }
                    }
            }   }
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
            Layout.leftMargin: 20
            enabled: sshConnected
            background: Rectangle {
                color: "#3498db"
                radius: 5
            }
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
                if (bekbComboBox.currentText === "BKB1"){
                    sshHelper.uploadFile(bekb1Filelabel.text, "/mnt/update")
                }
                if (bekbComboBox.currentText === "BKB2"){
                    sshHelper.uploadFile(bekb2Filelabel.text, "/mnt/update")
                }
                if (bekbComboBox.currentText === "BKB3"){
                    sshHelper.uploadFile(bekb3Filelabel.text, "/mnt/update")
                }
                if (skpFilelabel !== "...") {
                    sshHelper.uploadFile(skpFilelabel.text, "/mnt/update")
                }
                if (ggapFilelabel !== "...") {
                    sshHelper.uploadFile(ggapFilelabel.text, "/mnt/update")
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
                background: Rectangle {
                    color: "#3498db"
                    radius: 5
                }
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
                // sshResultLabel.text = message
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
            id: fileDialog
            title: "Dosya Seçin"
            onAccepted: {
                console.log("Seçilen dosya: " + selectedFile)
                /*if (fileDialog.title === "BEKB Dosyasını Seçin") {
                    bekbFilelabel.text = selectedFile
                    selectedLinuxFile = selectedFile
                } else*/
                if (fileDialog.title === "SKP Dosyasını Seçin") {
                    skpFilelabel.text = selectedFile
                } else if (fileDialog.title === "GGAP Dosyasını Seçin") {
                    ggapFilelabel.text = selectedFile
                }
            }
            onRejected: {
                console.log("Dosya seçimi iptal edildi.")
            }
        }
        FileDialog {
            id: fileDialog1
            title: "Dosya Seçin"
            onAccepted: {
                console.log("Seçilen dosya: " + selectedFile)
                switch (bekbComboBox.currentText) {
                    case "BKB1":
                        bekb1Filelabel.text = selectedFile
                        selectedBEKB1File = selectedFile
                        break;
                    case "BKB2":
                        bekb2Filelabel.text = selectedFile
                        selectedBEKB2File = selectedFile
                        break;
                    case "BKB3":
                        bekb3Filelabel.text = selectedFile
                        selectedBEKB3File = selectedFile
                        break;
                }
            }
            onRejected: {
                console.log("Dosya seçimi iptal edildi.")
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

        PropertyAnimation {
            id: pingAnimation1
            target: pingResultLabel
            property: "color"
            from: "blue"
            to: "black"
            duration: 1000
            running: false
        }
    }
}
