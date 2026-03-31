import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    Component.onCompleted: {
        if (this.WlrLayershell != null) {
            this.WlrLayershell.layer = WlrLayer.Top;
        }
    }

    property var radius: 30
    property bool isOpen: false
    exclusiveZone: -10000
    color: "transparent"
    anchors.left: true
    anchors.top: true
    margins.left: isOpen ? 0 : -root.width - bar.implicitWidth

    Behavior on margins.left {
        NumberAnimation {
            duration: 450
            easing.type: Easing.OutQuint
        }
    }

    Rectangle {
        id: body
        color: "transparent"
        anchors.fill: parent

        Rectangle {
            id: mainBarBackground
            width: parent.width
            height: parent.height - (2 * root.radius)
            anchors.centerIn: parent

            topRightRadius: root.radius
            bottomRightRadius: root.radius
            color: "#1a1b26"

            Item {
                id: container
                anchors.fill: parent
                clip: true
            }
        }

        InvertedCorner {
            location: 3
            radius: root.radius
            color: "#1a1b26"
            anchors.bottom: mainBarBackground.top
            anchors.left: parent.left
        }

        InvertedCorner {
            location: 1
            radius: root.radius
            color: "#1a1b26"
            anchors.top: mainBarBackground.bottom
            anchors.left: parent.left
        }
    }
}
