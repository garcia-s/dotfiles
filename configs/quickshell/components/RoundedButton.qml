import QtQuick

Rectangle {
    id: root
    property string icon
    property bool active
    signal clicked
    width: 26
    height: 26
    color: active ? "#bd93f9" : "#111"
    radius: 14

    Text {
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
