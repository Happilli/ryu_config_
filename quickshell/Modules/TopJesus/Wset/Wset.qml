pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.Services.Theme
import qs.utils

Item {
    id: root

    readonly property var modes: ["wallpaper", "minimal", "disabled"]
    readonly property var trans: ["bubble", "instant"]

    function callIpc(method, arg) {
        if (method === "setMode")
            WallpaperConfig.displayMode = arg;
        else if (method === "setTransition")
            WallpaperConfig.transitionType = arg;
        else if (method === "setPanning")
            WallpaperConfig.enablePanning = (arg === "true" || arg === "1");
        WallpaperConfig.saveConfig();
    }

    Column {
        anchors.centerIn: parent
        spacing: 12

        MaterialButtonGroup {
            anchors.horizontalCenter: parent.horizontalCenter
            variant: MaterialButtonGroup.Connected
            sizeStyle: MaterialButtonGroup.Small
            selectionMode: MaterialButtonGroup.Single
            labels: ["Wallpaper", "Minimal", "Disabled"]
            currentIndex: root.modes.indexOf(WallpaperConfig.displayMode)
            borderWidth: 1
            borderColor: Theme.outlineVariant
            color: Theme.surfaceContainerHigh
            textColor: Theme.onSurface
            checkedColor: Theme.primaryColor
            checkedTextColor: Theme.onPrimary
            onToggled: (index, on) => root.callIpc("setMode", root.modes[index])
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            MaterialButtonGroup {
                variant: MaterialButtonGroup.Connected
                sizeStyle: MaterialButtonGroup.Small
                selectionMode: MaterialButtonGroup.Single
                labels: ["Bubble", "Instant"]
                currentIndex: root.trans.indexOf(WallpaperConfig.transitionType)
                enabled: WallpaperConfig.displayMode === "wallpaper"
                borderWidth: 1
                borderColor: Theme.outlineVariant
                color: Theme.surfaceContainerHigh
                textColor: Theme.onSurface
                checkedColor: Theme.primaryColor
                checkedTextColor: Theme.onPrimary
                onToggled: (index, on) => root.callIpc("setTransition", root.transitions[index])
            }

            MaterialButtonGroup {
                variant: MaterialButtonGroup.Connected
                sizeStyle: MaterialButtonGroup.Small
                selectionMode: MaterialButtonGroup.Multiple
                labels: ["Pan"]
                checkedIndices: WallpaperConfig.enablePanning ? [0] : []
                enabled: WallpaperConfig.displayMode === "wallpaper"
                borderWidth: 1
                borderColor: Theme.outlineVariant
                color: Theme.surfaceContainerHigh
                textColor: Theme.onSurface
                checkedColor: Theme.primaryColor
                checkedTextColor: Theme.onPrimary
                onToggled: (index, on) => root.callIpc("setPanning", on ? "true" : "false")
            }
        }
    }
}
