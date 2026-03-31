import Quickshell
import QtQuick

Rectangle {
    id: root
    property string icon
    property bool active

    signal clicked

    width: 30
    height: 30
    color: active ? "#bd93f9" : "#1a1b26"
    radius: 3

    Text {
        anchors.centerIn: parent
        text: icon
        color: "white"
        font.family: materialIcons.name
        font.pixelSize: 22
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
