Rectangle {
    id: bluetoothToggle
    width: 32
    height: 32
    radius: 8

    readonly property var adapter: Bluetooth.adapters.length > 0 ? Bluetooth.adapters[0] : null

    color: (adapter && adapter.powered) ? "#3d59a1" : "#2a2b36"
    Layout.alignment: Qt.AlignHCenter

    Text {
        anchors.centerIn: parent
        font.family: materialIcons.name
        font.pixelSize: 20
        text: (adapter && adapter.powered) ? "\ue1a7" : "\ue1a8"
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (adapter) {
                adapter.powered = !adapter.powered;
            }
        }
    }
}
