Item {
    FontLoader {
        id: materialIcons
        source: "fonts/MaterialIcons-Regular.ttf"
    }

    SoundPanel {
        id: soundPanel
        screen: mainBar.screen
        isOpen: activePanel === "sound"
    }
}
