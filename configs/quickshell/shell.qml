import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: shellRoot

    // Load Material Icons — registers "Material Icons" as font.family app-wide
    FontLoader { source: "fonts/MaterialIcons-Regular.ttf" }

    // The bar whose button was last clicked (or first bar as default for IPC)
    property var primaryBar: null
    property var activeBar: null

    property bool anyPanelOpen: appMenu.visible || powerMenu.visible ||
                                 calendarPopup.visible || cpuDetails.visible ||
                                 ramDetails.visible || audioPanel.visible

    // ── Dismiss overlays (one per screen, created first for z-ordering) ──
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

    // ── Bar — one instance per screen ────────────────────────────────────
    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData

            Component.onCompleted: {
                // First bar becomes the default for IPC keybinds
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

    // ── AppMenu — PanelWindow, screen set dynamically on open ────────────
    AppMenu { id: appMenu }

    // ── Remaining popups — anchored to whichever bar was last clicked ─────

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

    // ── Helpers ──────────────────────────────────────────────────────────
    function closeAll() {
        appMenu.visible       = false
        powerMenu.visible     = false
        calendarPopup.visible = false
        audioPanel.visible    = false
        cpuDetails.visible    = false
        ramDetails.visible    = false
    }

    // Open one panel exclusively; toggle off if already open
    function exclusive(panel) {
        const wasVisible = panel.visible
        closeAll()
        panel.visible = !wasVisible
    }

    // ── IPC handlers (Hyprland keybinds via `qs ipc call`) ──────────────
    // IPC has no screen context — opens on last-clicked bar (or primary)
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
