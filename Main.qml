import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Yazılım Yükleme Projesi"

    GridLayout {
        anchors.fill: parent
        columns: 4
        rowSpacing: 10
        columnSpacing: 10

        Button {
            text: "Bağlama"
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 20
            Layout.topMargin: 10
            Layout.columnSpan: 4
        }

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
        }
        Label {
            text: "Label 1"
            Layout.fillWidth: true
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
        }
        Label {
            text: "Label 2"
            Layout.fillWidth: true
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
        }
        Label {
            text: "Label 3"
            Layout.fillWidth: true
        }

        Item {
            Layout.rowSpan: 3
        }

        Button {
            text: "Başla"
            Layout.alignment: Qt.AlignHCenter
            Layout.columnSpan: 4
        }
    }
}
