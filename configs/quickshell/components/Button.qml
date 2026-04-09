import Quickshell
import QtQuick

Rectangle {
    id: root
    property string icon
    property bool active

    signal clicked

    width: 30
    height: 30
    color: active ? "#bd93f9" : area.containsMouse ? "#2a2b36" : "#1a1b26"
    radius: 3

    Text {
        anchors.centerIn: parent
        text: icon
        color: "white"
        font.family: materialIcons.name
        font.pixelSize: 22
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
