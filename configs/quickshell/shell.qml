import Quickshell
import Quickshell.Io
import QtQuick


ShellRoot {
    id: shellRoot
    FontLoader { source: "fonts/MaterialIcons-Regular.ttf" }

    property var primaryBar: null
    property var activeBar: null

    property bool anyPanelOpen: appMenu.visible || powerMenu.visible ||
                                 calendarPopup.visible || cpuDetails.visible ||
                                 ramDetails.visible || audioPanel.visible

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusiveZone: 0
            color: "transparent"
            visible: shellRoot.anyPanelOpen

            MouseArea {
                anchors.fill: parent
                onClicked: shellRoot.closeAll()
            }
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData

            Component.onCompleted: {
                if (shellRoot.primaryBar === null) {
                    shellRoot.primaryBar = this
                    shellRoot.activeBar  = this
                }

                const bar = this
                toggleAppMenuRequested.connect(function() {
                    shellRoot.activeBar = bar
                    appMenu.screen = bar.screen
                    shellRoot.exclusive(appMenu)
                })
                togglePowerMenuRequested.connect(function() {
                    shellRoot.activeBar = bar
                    shellRoot.exclusive(powerMenu)
                })
                toggleCalendarRequested.connect(function() {
                    shellRoot.activeBar = bar
                    shellRoot.exclusive(calendarPopup)
                })
                toggleAudioPanelRequested.connect(function() {
                    shellRoot.activeBar = bar
                    shellRoot.exclusive(audioPanel)
                })
                toggleCpuDetailsRequested.connect(function() {
                    shellRoot.activeBar = bar
                    shellRoot.exclusive(cpuDetails)
                })
                toggleRamDetailsRequested.connect(function() {
                    shellRoot.activeBar = bar
                    shellRoot.exclusive(ramDetails)
                })
            }
        }
    }

    AppMenu { id: appMenu }


    PowerMenu {
        id: powerMenu
        anchor.item: shellRoot.activeBar ? shellRoot.activeBar.powerMenuButtonRef : null
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
    }

    CalendarPopup {
        id: calendarPopup
        anchor.item: shellRoot.activeBar ? shellRoot.activeBar.clockRef : null
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
    }

    AudioPanel {
        id: audioPanel
        anchor.item: shellRoot.activeBar ? shellRoot.activeBar.audioRef : null
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
    }

    CpuDetails {
        id: cpuDetails
        anchor.item: shellRoot.activeBar ? shellRoot.activeBar.cpuRef : null
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
    }

    RamDetails {
        id: ramDetails
        anchor.item: shellRoot.activeBar ? shellRoot.activeBar.ramRef : null
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
    }

    function closeAll() {
        appMenu.visible       = false
        powerMenu.visible     = false
        calendarPopup.visible = false
        audioPanel.visible    = false
        cpuDetails.visible    = false
        ramDetails.visible    = false
    }

    function exclusive(panel) {
        const wasVisible = panel.visible
        closeAll()
        panel.visible = !wasVisible
    }

    IpcHandler {
        target: "toggleAppMenu"
        function toggle(): void {
            if (shellRoot.activeBar) appMenu.screen = shellRoot.activeBar.screen
            shellRoot.exclusive(appMenu)
        }
    }
    IpcHandler {
        target: "togglePowerMenu"
        function toggle(): void { shellRoot.exclusive(powerMenu) }
    }
    IpcHandler {
        target: "toggleCalendar"
        function toggle(): void { shellRoot.exclusive(calendarPopup) }
    }
    IpcHandler {
        target: "toggleCpuDetails"
        function toggle(): void { shellRoot.exclusive(cpuDetails) }
    }
    IpcHandler {
        target: "toggleRamDetails"
        function toggle(): void { shellRoot.exclusive(ramDetails) }
    }
}
