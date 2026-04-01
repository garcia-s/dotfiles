import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: panel
    default property alias content: container.children
    anchors.fill: parent
    color: "transparent"
    width: parent.width
    height: parent.height

    Rectangle {
        id: mainBarBackground
        width: parent.width
        height: parent.height - (2 * panel.radius)
        anchors.centerIn: parent
        topRightRadius: panel.radius
        bottomRightRadius: panel.radius
        color: "#1a1b26"

        Item {
            id: container
            anchors.fill: parent
            clip: true
        }
    }

    InvertedCorner {
        location: 3
        radius: panel.radius
        color: "#1a1b26"
        anchors.bottom: mainBarBackground.top
        anchors.left: parent.left
    }

    InvertedCorner {
        location: 1
        radius: panel.radius
        color: "#1a1b26"
        anchors.top: mainBarBackground.bottom
        anchors.left: parent.left
    }
}
