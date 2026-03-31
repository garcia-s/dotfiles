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
    Component.onCompleted: {
        updateAll();
    }

    Timer {
        id: updateTimer
        interval: 1000
        running: root.isOpen
        repeat: true
        onTriggered: updateAll()
    }

    function updateAll() {
        volumeProcess.run();
        micVolumeProcess.run();
        sinksProcess.run();
        sourcesProcess.run();
    }

    Process {
        id: volumeProcess
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        onExited: {
            if (exitCode === 0) {
                var match = stdout.match(/(\d+)%/);
                if (match)
                    root.volume = parseInt(match[1]);
            }
        }
    }

    Process {
        id: micVolumeProcess
        command: ["pactl", "get-source-volume", "@DEFAULT_SOURCE@"]
        onExited: {
            if (exitCode === 0) {
                var match = stdout.match(/(\d+)%/);
                if (match)
                    root.micVolume = parseInt(match[1]);
            }
        }
    }

    Process {
        id: sinksProcess
        command: ["pactl", "list", "short", "sinks"]
        onExited: {
            if (exitCode === 0) {
                var lines = stdout.trim().split("\n");
                var newList = [];
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("\t");
                    if (parts.length >= 2) {
                        newList.push({
                            id: parts[0],
                            name: parts[1]
                        });
                    }
                }
                root.sinks = newList;
            }
        }
    }

    Process {
        id: sourcesProcess
        command: ["pactl", "list", "short", "sources"]
        onExited: {
            if (exitCode === 0) {
                var lines = stdout.trim().split("\n");
                var newList = [];
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split("\t");
                    if (parts.length >= 2) {
                        newList.push({
                            id: parts[0],
                            name: parts[1]
                        });
                    }
                }
                root.sources = newList;
            }
        }
    }

    function setVolume(val) {
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "' + val + '%"] }', root);
        proc.run();
    }

    function setMicVolume(val) {
        var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["pactl", "set-source-volume", "@DEFAULT_SOURCE@", "' + val + '%"] }', root);
        proc.run();
    }

    // Custom Slider Component
    component CustomSlider: Rectangle {
        id: sliderRoot
        property real value: 0
        property real from: 0
        property real to: 100
        signal moved(real val)

        Layout.fillWidth: true
        height: 20
        color: "#33ffffff"
        radius: 10

        Rectangle {
            id: handle
            width: parent.width * ((sliderRoot.value - sliderRoot.from) / (sliderRoot.to - sliderRoot.from))
            height: parent.height
            color: "#bd93f9"
            radius: parent.radius
        }

        MouseArea {
            anchors.fill: parent
            function update() {
                var val = Math.round(sliderRoot.from + (mouseX / sliderRoot.width) * (sliderRoot.to - sliderRoot.from));
                sliderRoot.value = Math.max(sliderRoot.from, Math.min(sliderRoot.to, val));
                sliderRoot.moved(sliderRoot.value);
            }
            onPressed: update()
            onPositionChanged: if (pressed)
                update()
        }
    }

    RoundedPanel {
        id: panel
        isOpen: root.isOpen
        screen: root.screen
        width: 350
        height: 500
        radius: 40

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            Text {
                text: "Sound Control"
                color: "white"
                font.pixelSize: 22
                font.bold: true
            }

            // Output Volume
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                RowLayout {
                    spacing: 10
                    Text {
                        text: "\ue050" // volume_up
                        font.family: materialIcons.name
                        font.pixelSize: 20
                        color: "white"
                    }
                    Text {
                        text: "Output: " + root.volume + "%"
                        color: "white"
                        font.pixelSize: 14
                    }
                }
                CustomSlider {
                    value: root.volume
                    onMoved: val => setVolume(val)
                }
            }

            // Output Devices
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                spacing: 5
                Text {
                    text: "Output Device"
                    color: "white"
                    font.pixelSize: 12
                    opacity: 0.7
                }
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.sinks
                    delegate: Rectangle {
                        width: parent.width
                        height: 35
                        color: "#2a2b36"
                        radius: 8
                        border.color: "#33ffffff"
                        Text {
                            anchors.fill: parent
                            anchors.margins: 10
                            text: modelData.name.replace("alsa_output.", "").replace(".analog-stereo", "")
                            color: "white"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["pactl", "set-default-sink", "' + modelData.name + '"] }', root);
                                proc.run();
                                updateAll();
                            }
                        }
                    }
                }
            }

            // Input Volume
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                RowLayout {
                    spacing: 10
                    Text {
                        text: "\ue029" // mic
                        font.family: materialIcons.name
                        font.pixelSize: 20
                        color: "white"
                    }
                    Text {
                        text: "Input: " + root.micVolume + "%"
                        color: "white"
                        font.pixelSize: 14
                    }
                }
                CustomSlider {
                    value: root.micVolume
                    onMoved: val => setMicVolume(val)
                }
            }

            // Input Devices
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                spacing: 5
                Text {
                    text: "Input Device"
                    color: "white"
                    font.pixelSize: 12
                    opacity: 0.7
                }
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.sources
                    delegate: Rectangle {
                        width: parent.width
                        height: 35
                        color: "#2a2b36"
                        radius: 8
                        border.color: "#33ffffff"
                        Text {
                            anchors.fill: parent
                            anchors.margins: 10
                            text: modelData.name.replace("alsa_input.", "").replace(".analog-stereo", "")
                            color: "white"
                            font.pixelSize: 12
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["pactl", "set-default-source", "' + modelData.name + '"] }', root);
                                proc.run();
                                updateAll();
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
