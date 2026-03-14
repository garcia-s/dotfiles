import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

PopupWindow {
    id: audioRoot
    width: 280
    height: 100
    color: "transparent"

    // Keep sink/source reactive
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#1a1b26"
        border.color: "#414868"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 0

            // ── Output ──────────────────────────────────────────────────
            RowLayout {
                spacing: 10
                Layout.fillWidth: true

                Text {
                    text: Pipewire.defaultAudioSink?.audio.muted ? "\ue04f" : "\ue050"
                    font.family: "Material Icons"
                    color: Pipewire.defaultAudioSink?.audio.muted ? "#565f89" : "#7aa2f7"
                    font.pixelSize: 20
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (Pipewire.defaultAudioSink) Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
                    }
                }

                Item {
                    id: sinkSlider
                    Layout.fillWidth: true
                    height: 20
                    property real vol: Pipewire.defaultAudioSink?.audio.volume ?? 0

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width; height: 6; radius: 3
                        color: "#24253a"
                        Rectangle {
                            width: parent.width * Math.min(sinkSlider.vol, 1)
                            height: parent.height; radius: 3
                            color: Pipewire.defaultAudioSink?.audio.muted ? "#414868" : "#7aa2f7"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        function setVol(mx) {
                            if (Pipewire.defaultAudioSink)
                                Pipewire.defaultAudioSink.audio.volume = Math.max(0, Math.min(1, mx / width))
                        }
                        onClicked:          setVol(mouse.x)
                        onPositionChanged:  if (pressed) setVol(mouse.x)
                    }
                }

                Text {
                    text: Pipewire.defaultAudioSink ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : "--"
                    color: "#c0caf5"; font.pixelSize: 12; font.family: "monospace"
                    Layout.preferredWidth: 38; horizontalAlignment: Text.AlignRight
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#414868"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

            // ── Input (Mic) ──────────────────────────────────────────────
            RowLayout {
                spacing: 10
                Layout.fillWidth: true

                Text {
                    text: Pipewire.defaultAudioSource?.audio.muted ? "\ue02b" : "\ue029"
                    font.family: "Material Icons"
                    color: Pipewire.defaultAudioSource?.audio.muted ? "#565f89" : "#9ece6a"
                    font.pixelSize: 20
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (Pipewire.defaultAudioSource) Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted
                    }
                }

                Item {
                    id: sourceSlider
                    Layout.fillWidth: true
                    height: 20
                    property real vol: Pipewire.defaultAudioSource?.audio.volume ?? 0

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width; height: 6; radius: 3
                        color: "#24253a"
                        Rectangle {
                            width: parent.width * Math.min(sourceSlider.vol, 1)
                            height: parent.height; radius: 3
                            color: Pipewire.defaultAudioSource?.audio.muted ? "#414868" : "#9ece6a"
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        function setVol(mx) {
                            if (Pipewire.defaultAudioSource)
                                Pipewire.defaultAudioSource.audio.volume = Math.max(0, Math.min(1, mx / width))
                        }
                        onClicked:          setVol(mouse.x)
                        onPositionChanged:  if (pressed) setVol(mouse.x)
                    }
                }

                Text {
                    text: Pipewire.defaultAudioSource ? Math.round(Pipewire.defaultAudioSource.audio.volume * 100) + "%" : "--"
                    color: "#c0caf5"; font.pixelSize: 12; font.family: "monospace"
                    Layout.preferredWidth: 38; horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
