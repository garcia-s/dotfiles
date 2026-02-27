import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: shellRoot

    // Track which bar to use as anchor for popups (set by first bar that completes)
    property var primaryBar: null

    // True while any panel is open — drives the dismiss overlay
    property bool anyPanelOpen: appMenu.visible || powerMenu.visible ||
                                 calendarPopup.visible || cpuDetails.visible ||
                                 ramDetails.visible

    // ── Dismiss overlays (one per screen, created first for z-ordering) ──
    // Sits below the bar on each screen; intercepts clicks outside a popup
    // and closes everything.
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

            // First bar to complete becomes the popup anchor
            Component.onCompleted: {
                if (shellRoot.primaryBar === null) shellRoot.primaryBar = this

                // Wire each bar's toggle signals to the shared popup set
                toggleAppMenuRequested.connect(    function() { shellRoot.exclusive(appMenu) })
                togglePowerMenuRequested.connect(  function() { shellRoot.exclusive(powerMenu) })
                toggleCalendarRequested.connect(   function() { shellRoot.exclusive(calendarPopup) })
                toggleCpuDetailsRequested.connect( function() { shellRoot.exclusive(cpuDetails) })
                toggleRamDetailsRequested.connect( function() { shellRoot.exclusive(ramDetails) })
            }
        }
    }

    // ── AppMenu — PanelWindow, self-positioned below the bar's left edge ─
    AppMenu { id: appMenu }

    // ── Remaining popups (PopupWindow, anchored to primary bar) ──────────

    PowerMenu {
        id: powerMenu
        anchor.item: shellRoot.primaryBar ? shellRoot.primaryBar.powerMenuButtonRef : null
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
    }

    CalendarPopup {
        id: calendarPopup
        anchor.item: shellRoot.primaryBar ? shellRoot.primaryBar.clockRef : null
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
    }

    CpuDetails {
        id: cpuDetails
        anchor.item: shellRoot.primaryBar ? shellRoot.primaryBar.cpuRef : null
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
    }

    RamDetails {
        id: ramDetails
        anchor.item: shellRoot.primaryBar ? shellRoot.primaryBar.ramRef : null
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
    }

    // ── Helpers ──────────────────────────────────────────────────────────
    function closeAll() {
        appMenu.visible       = false
        powerMenu.visible     = false
        calendarPopup.visible = false
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
    IpcHandler {
        target: "toggleAppMenu"
        function toggle(): void { shellRoot.exclusive(appMenu) }
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
