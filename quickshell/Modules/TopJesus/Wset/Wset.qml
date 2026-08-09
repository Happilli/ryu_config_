pragma ComponentBehavior: Bound
import QtQuick
import qs.Components.common
import qs.Services.Theme
import qs.utils

Item {
    id: root

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

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: ["wallpaper", "minimal", "disabled"]

                delegate: OptionButton {
                    required property string modelData

                    active: WallpaperConfig.displayMode === modelData
                    label: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                    ipcMethod: "setMode"
                    ipcArg: modelData
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Repeater {
                model: ["bubble", "instant"]

                delegate: OptionButton {
                    required property string modelData

                    active: WallpaperConfig.transitionType === modelData
                    isEnabled: WallpaperConfig.displayMode === "wallpaper"
                    label: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                    ipcMethod: "setTransition"
                    ipcArg: modelData
                }
            }

            OptionButton {
                active: WallpaperConfig.enablePanning
                isEnabled: WallpaperConfig.displayMode === "wallpaper"
                label: WallpaperConfig.enablePanning ? "Pan On" : "Pan Off"
                ipcMethod: "setPanning"
                ipcArg: WallpaperConfig.enablePanning ? "false" : "true"
            }
        }
    }

    component OptionButton: MorphButton {
        id: btn
        property string ipcMethod: ""
        property string ipcArg: ""

        width: 80
        height: 80
        baseRadius: 12
        hoverRadius: 40
        contentPixelSize: 12
        inactiveColor: Theme.surfaceContainerLow
        hoverColor: Theme.surfaceContainerHigh
        inactiveBorder: Theme.outlineVariant
        inactiveBorderWidth: 1
        hoverBorderWidth: 1
        activeBorderWidth: 2
        onClicked: root.callIpc(btn.ipcMethod, btn.ipcArg)
    }
}
