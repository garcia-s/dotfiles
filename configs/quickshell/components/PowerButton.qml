
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: btn
    property string icon
    property string label
    property color accent: "#7aa2f7"
    signal clicked

    width: 80
    height: 80
    Layout.alignment: Qt.AlignHCenter
    color: area.containsMouse ? btn.accent : "transparent"
    radius: 14

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 5

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: btn.icon
            font.family: materialIcons.name
            font.pixelSize: 22
            color: "white"
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: btn.label
            color: "#c0caf5"
            font.pixelSize: 11
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: btn.clicked()
    }
}
