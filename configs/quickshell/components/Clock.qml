import QtQuick

Text {
    id: clockText
    signal clicked

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

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: clockText.clicked()
    }
}
