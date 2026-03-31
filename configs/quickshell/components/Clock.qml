import QtQuick

Text {
    id: clockText
    color: "white"
    font.pixelSize: 14
    font.weight: Font.Bold
    horizontalAlignment: Text.AlignHCenter
    function updateTime() {
        clockText.text = Qt.formatDateTime(new Date(), "HH\nmm");
    }

    Component.onCompleted: updateTime()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockText.updateTime()
    }
}
