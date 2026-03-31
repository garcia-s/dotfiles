import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool isOpen: false
    property var screen: null

    property int volume: 50
    property int micVolume: 50
    property var sinks: []
    property var sources: []

    // Fetch initial data
}
