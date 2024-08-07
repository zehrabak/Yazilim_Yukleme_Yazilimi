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
    title: qsTr("Yazılım Yükleme Projesi")
    color: "lightgrey"

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
                text: qsTr("IP :")
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 20
                verticalAlignment: Text.AlignVCenter
                color: "black"
                font.bold: true
            }

            TextField {
                id: ipAddressField
                placeholderText:qsTr("IP adresini girin")
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 10
                width: 150
            }

            Button {
                text: qsTr("Ping Testi")
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
                        pingResultLabel.text = qsTr("Geçerli bir IP adresi girin.")
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
                        sshHelper.connectToHost(ip, "root", "")
                    } else {
                        sshResultLabel.text = qsTr("Geçerli bir IP adresi girin.")
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
            anchors.left: parent.left
            anchors.right: parent.right
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
            width: Screen.width
            height: Screen.height
            currentIndex: bar.currentIndex

            Item {
                ColumnLayout{
                GridLayout {
                    columns: 4
                    rowSpacing: 10
                    columnSpacing: 10

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
                        text: qsTr("Seç")
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
                        text: qsTr("Seç")
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
                        text: qsTr("Seç")
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
                RowLayout {
                    Layout.columnSpan: 4
                    Layout.topMargin: 20

                    Button {
                        text: qsTr("Yazılımı Yükle")
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 20
                        enabled: sshConnected && (linuxFileLabel.text !== "..." || rootfsFileLabel.text !== "...")
                        background: Rectangle {
                            color: "#3498db"
                            radius: 5
                        }
                        onClicked: {
                            console.log(sshConnected)
                            var result = ""
                            if (linuxCheckBox.checked) {
                                result = sshHelper.executeRemoteCommand("reboot")
                                sshHelper.disconnectFromHost()
                            }
                            if (rootfsCheckBox.checked) {
                                result = sshHelper.executeRemoteCommand("reboot")
                                sshHelper.disconnectFromHost()
                            }
                            resultLabel1.text = result
                        }
                    }
                    Label {
                        id: resultLabel1
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 10
                        text: ""
                    }
                }
            }
        }
            Item {
                width: Screen.width
                height: Screen.height

                ColumnLayout {
                    anchors.fill: parent

                    ComboBox {
                        id: bekbComboBox
                        Layout.alignment: Qt.AlignLeft
                        Layout.leftMargin: 30

                        width: parent.width / 2
                        model: ["BKB1", "BKB2", "BKB3"]
                        onCurrentTextChanged: {
                            switch (currentText) {
                                case "BKB1":
                                fileDialog1.title = qsTr("BKB1 Dosyasını Seçin")
                                break;
                                case "BKB2":
                                fileDialog1.title = qsTr("BKB2 Dosyasını Seçin")
                                break;
                                case "BKB3":
                                fileDialog1.title = qsTr("BKB3 Dosyasını Seçin")
                                break;
                            }
                        }
                    }

                    GridLayout {
                        columns: 4
                        rowSpacing: 10
                        columnSpacing: 10
                        id: gridLayoutBekb

                        Text {
                            text: qsTr("Yazılım")
                            Layout.leftMargin: 20
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 1
                            Layout.row: 0
                            color: "darkblue"
                            visible: bekbComboBox.currentText === "BKB1"
                        }
                        Button {
                            text: qsTr("Seç")
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
                            visible: bekbComboBox.currentText === "BKB1"
                        }
                        Label {
                            text: "..."
                            id: bekb1Filelabel
                            Layout.fillWidth: true
                            Layout.column: 3
                            Layout.row: 0
                            enabled: sshConnected
                            visible: bekbComboBox.currentText === "BKB1"
                        }

                        Text {
                            text: qsTr("Yazılım")
                            Layout.leftMargin: 20
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 1
                            Layout.row: 0
                            color: "darkblue"
                            visible: bekbComboBox.currentText === "BKB2"
                        }
                        Button {
                            text: qsTr("Seç")
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
                            visible: bekbComboBox.currentText === "BKB2"
                        }
                        Label {
                            text: "..."
                            id: bekb2Filelabel
                            Layout.fillWidth: true
                            Layout.column: 3
                            Layout.row: 0
                            enabled: sshConnected
                            visible: bekbComboBox.currentText === "BKB2"
                        }

                        Text {
                            text: qsTr("Yazılım")
                            Layout.leftMargin: 20
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 1
                            Layout.row: 0
                            color: "darkblue"
                            visible: bekbComboBox.currentText === "BKB3"
                        }
                        Button {
                            text: qsTr("Seç")
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
                            visible: bekbComboBox.currentText === "BKB3"
                        }
                        Label {
                            text: "..."
                            id: bekb3Filelabel
                            Layout.fillWidth: true
                            Layout.column: 3
                            Layout.row: 0
                            enabled: sshConnected
                            visible: bekbComboBox.currentText === "BKB3"
                        }
                    }

                    RowLayout {
                        Layout.columnSpan: 4
                        Layout.topMargin: 20
                        visible: bekbComboBox.currentText === "BKB1"

                        Button {
                            text: qsTr("Yazılımı Yükle")
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 20
                            enabled: sshConnected && bekb1Filelabel.text !== "..."
                            background: Rectangle {
                                color: "#3498db"
                                radius: 5
                            }
                            onClicked: {
                                console.log(sshConnected)
                                var result = ""
                                if (bekb1Filelabel.text !== "...") {
                                    result = sshHelper.executeRemoteCommand("/opt/CanUpdate/app/CANUpdate_Console --update can1 /mnt/update/DIA.elf BEKB_1_MCU_ALL")
                                }
                                resultLabel21.text = result
                            }
                        }
                        Label {
                            id: resultLabel21
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 10
                            text: ""
                        }
                    }

                    RowLayout {
                        Layout.columnSpan: 4
                        Layout.topMargin: 20
                        visible: bekbComboBox.currentText === "BKB2"

                        Button {
                            text: qsTr("Yazılımı Yükle")
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 20
                            enabled: sshConnected && bekb2Filelabel.text !== "..."
                            background: Rectangle {
                                color: "#3498db"
                                radius: 5
                            }
                            onClicked: {
                                console.log(sshConnected)
                                var result = ""
                                if (bekb2Filelabel.text !== "...") {
                                    result = sshHelper.executeRemoteCommand("/opt/CanUpdate/app/CANUpdate_Console --update can1 /mnt/update/DIA.elf BEKB_2_MCU_ALL")
                                }
                                resultLabel22.text = result
                            }
                        }
                        Label {
                            id: resultLabel22
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 10
                            text: ""
                        }
                    }

                    RowLayout {
                        Layout.columnSpan: 4
                        Layout.topMargin: 20
                        visible: bekbComboBox.currentText === "BKB3"

                        Button {
                            text: qsTr("Yazılımı Yükle")
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 20
                            enabled: sshConnected && bekb3Filelabel.text !== "..."
                            background: Rectangle {
                                color: "#3498db"
                                radius: 5
                            }
                            onClicked: {
                                console.log(sshConnected)
                                var result = ""
                                if (bekb3Filelabel.text !== "...") {
                                    result = sshHelper.executeRemoteCommand("/opt/CanUpdate/app/CANUpdate_Console --update can1 /mnt/update/DIA.elf BEKB_3_MCU_ALL")
                                }
                                resultLabel23.text = result
                            }
                        }
                        Label {
                            id: resultLabel23
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 10
                            text: ""
                        }
                    }
                }
            }

            Item {
                width: Screen.width
                height: Screen.height
                ColumnLayout {
                    GridLayout {
                       columns: 4
                        rowSpacing: 20
                        columnSpacing: 20
                        Layout.topMargin: 20


                        Text {
                            text: qsTr("Yazılım")
                            Layout.leftMargin: 20
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 1
                            Layout.row: 0
                            color: "darkblue"
                        }
                        Button {
                            text: qsTr("Seç")
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
                    RowLayout {
                        Layout.columnSpan: 4
                        Layout.topMargin: 20

                        Button {
                            text: qsTr("Yazılımı Yükle")
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 20
                            enabled: sshConnected && skpFilelabel.text !== "..."
                            background: Rectangle {
                                color: "#3498db"
                                radius: 5
                            }
                            onClicked: {
                                console.log(sshConnected)
                                var result = ""
                                if (skpFilelabel.text !== "...") {
                                     result = sshHelper.executeRemoteCommand("cd /opt/CANUpdate/app && /opt/CANUpdate/app/CANUpdate_Console --update can1 /mnt/update/DIA.elf SKP ")
                                }
                                resultLabel3.text = result
                            }
                        }
                        Label {
                            id: resultLabel3
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 10
                            text: ""
                        }
                    }
                }
        }
            Item {
                width: Screen.width
                height: Screen.height
                ColumnLayout {
                    GridLayout {
                        columns: 4
                        rowSpacing: 20
                        columnSpacing: 20
                        Layout.topMargin: 20

                        // u-boot Row
                        Text {
                            text: qsTr("Yazılım")
                            Layout.leftMargin: 20
                            Layout.alignment: Qt.AlignLeft
                            Layout.columnSpan: 1
                            Layout.row: 0
                            color: "darkblue"
                        }
                        Button {
                            text: qsTr("Seç")
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
                    RowLayout {
                        Layout.columnSpan: 4
                        Layout.topMargin: 20

                        Button {
                            text: qsTr("Yazılımı Yükle")
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 20
                            enabled: sshConnected && ggapFilelabel.text !== "..."
                            background: Rectangle {
                                color: "#3498db"
                                radius: 5
                            }
                            onClicked: {
                                console.log(sshConnected)
                                var result = ""
                                if (ggapFilelabel.text !== "...") {
                                    result = sshHelper.executeRemoteCommand("/opt/CanUpdate/app/CANUpdate_Console --update can1 /mnt/update/DIA.elf GGAB")
                                }
                                resultLabel4.text = result
                            }
                        }
                        Label {
                            id: resultLabel4
                            Layout.alignment: Qt.AlignLeft
                            Layout.leftMargin: 10
                            text: ""
                        }
                    }
                }
            }
        }

        ProgressBar {
            id: progressBar
            anchors.left: parent.left
            anchors.right: parent.right
            Layout.alignment: Qt.AlignLeft
            Layout.columnSpan: 4
            visible: false
            from: 0
            to: 100
            value: 0
            contentItem: Rectangle {
                width: progressBar.visualPosition * progressBar.width
                height: progressBar.height
                color: "green"
            }
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
            text: qsTr("Karşıya Yükle")
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
                if ( bekb1Filelabel.text !== "..."){
                    sshHelper.uploadFile(bekb1Filelabel.text, "/mnt/update")
                }
                if (bekb2Filelabel.text !== "..."){
                    sshHelper.uploadFile(bekb2Filelabel.text, "/mnt/update")
                }
                if (bekb3Filelabel.text !== "..."){
                    sshHelper.uploadFile(bekb3Filelabel.text, "/mnt/update")
                }
                if (skpFilelabel.text !== "...") {
                    sshHelper.uploadFile(skpFilelabel.text, "/mnt/update")
                }
                if (ggapFilelabel.text !== "...") {
                    sshHelper.uploadFile(ggapFilelabel.text, "/mnt/update")
                }
                uploadTimer.stop()
                progressBar.value = 100
                progressBar.visible = true
                uploadComplete = true
            }
        }


        Connections {
            target: pingHelper
            onPingInProgress: {

                pingAnimation.running = true
                pingResultLabel.text = qsTr("Ping testi devam ediyor")

            }
            onPingSuccess: {
                pingResultLabel.text = qsTr("Ping başarılı")
                pingResultLabel.color = "green"
                pingAnimation.running = false
                pingSuccessful = true;
            }
            onPingFailed: {
                pingResultLabel.text = qsTr("Ping başarısız")
                pingResultLabel.color = "red"
                pingAnimation.running = false
                pingSuccessful = false;
            }
        }

        Connections {
            target: sshHelper
            onSshConnected: {
                sshResultLabel.text = qsTr("SSH bağlantısı başarılı")
                sshResultLabel.color = "green"
                sshConnected = true;
            }
            onSshConnectionFailed: {
                sshResultLabel.text = qsTr("SSH bağlantısı başarısız")
                sshResultLabel.color = "red"
                sshConnected = false;
            }
            onSshMessage: {
                sshResultLabel.text = message
            }
        }

        Timer {
            id: pingAnimation
            interval: 500
            repeat: true
            running: false
            onTriggered: {
                if (pingResultLabel.text === qsTr("Ping testi devam ediyor")) {
                    pingResultLabel.text = qsTr("Ping testi devam ediyor .")
                } else if (pingResultLabel.text === qsTr("Ping testi devam ediyor .")) {
                    pingResultLabel.text = qsTr("Ping testi devam ediyor . .")
                } else if (pingResultLabel.text === qsTr("Ping testi devam ediyor . .")) {
                    pingResultLabel.text = qsTr("Ping testi devam ediyor . . .")
                } else {
                    pingResultLabel.text = qsTr("Ping testi devam ediyor")
                }
            }
        }
        FileDialog {
            id: fileDialog
            title: "Dosya Seçin"
            onAccepted: {
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
            title: qsTr("Dosya Seçin")
            onAccepted: {
                console.log("Seçilen dosya: " + selectedFile)
                switch (bekbComboBox.currentText) {
                    case "BKB1":
                        bekb1Filelabel.text = selectedFile
                        break;
                    case "BKB2":
                        bekb2Filelabel.text = selectedFile
                        break;
                    case "BKB3":
                        bekb3Filelabel.text = selectedFile

                        break;
                }
            }
            onRejected: {
                console.log("Dosya seçimi iptal edildi.")
            }
        }
        FileDialog {
             id: linuxFileDialog
             title: qsTr("Linux Dosyasını Seçin")
             onAccepted: {
                 console.log("Seçilen dosya: " + selectedFile)
                 linuxFileLabel.text = selectedFile
             }
             onRejected: {
                 console.log("Linux dosyası seçimi iptal edildi.")
             }
        }

         FileDialog {
             id: rootfsFileDialog
             title: qsTr("Rootfs Dosyasını Seçin")
             onAccepted: {
                 console.log("Seçilen dosya: " + selectedFile)
                 rootfsFileLabel.text = selectedFile
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
