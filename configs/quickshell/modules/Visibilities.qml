pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    property var states: ({})

    function getForScreen(screenName) {
        return states[screenName] ?? null
    }

    function register(screenName, state) {
        let s = Object.assign({}, states)
        s[screenName] = state
        states = s
    }

    function unregister(screenName) {
        let s = Object.assign({}, states)
        delete s[screenName]
        states = s
    }
}
