import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

Item {
    id: root
    property bool isOpen: false
    property var screen: null

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    component CustomSlider: Rectangle {
        id: sliderRoot
        property real value: 0
        signal moved(real val)

        Layout.fillWidth: true
        height: 20
        color: "#33ffffff"
        radius: 10

        Rectangle {
            id: handle
            width: parent.width * sliderRoot.value
            height: parent.height
            color: "#bd93f9"
            radius: parent.radius
        }

        MouseArea {
            anchors.fill: parent
            function update() {
                var val = mouseX / sliderRoot.width;
                sliderRoot.value = Math.max(0.0, Math.min(1.0, val));
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
        width: 300
        height: 200

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            RowLayout {
                spacing: 10
                Text {
                    text: "\ue050" // volume_up
                    font.family: materialIcons.name
                    font.pixelSize: 20
                    color: "white"
                }
                CustomSlider {
                    value: Pipewire.defaultAudioSink?.audio?.volume ?? 0
                    onMoved: val => {
                        if (Pipewire.defaultAudioSink)
                            Pipewire.defaultAudioSink.audio.volume = val;
                    }
                }
            }
            RowLayout {
                spacing: 10
                Text {
                    text: "\ue029" // mic
                    font.family: materialIcons.name
                    font.pixelSize: 20
                    color: "white"
                }
                CustomSlider {
                    value: Pipewire.defaultAudioSource?.audio?.volume ?? 0
                    onMoved: val => {
                        if (Pipewire.defaultAudioSource)
                            Pipewire.defaultAudioSource.audio.volume = val;
                    }
                }
            }
        }
    }
}
