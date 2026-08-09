pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Components.ContextMenu
import qs.Components.Wallski
import qs.Services
import qs.Components.PaimonClock
import qs.utils

Scope {
    // background layer [wallpaper]
    Variants {
        model: Quickshell.screens

        Scope {
            id: screenScope

            required property var modelData

            readonly property var monitor: Hyprland.monitorFor(screenScope.modelData)
            readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? -1

            readonly property var activeWorkspaceObj: {
                if (screenScope.activeWorkspaceId === -1) {
                    return null;
                }
                return Hyprland.workspaces.values.find(w => w.id === screenScope.activeWorkspaceId) ?? null;
            }

            readonly property int windowCount: screenScope.activeWorkspaceObj?.toplevels?.values?.length ?? 0
            readonly property bool workspaceIsEmpty: screenScope.windowCount === 0

            Loader {
                active: screenScope.workspaceIsEmpty

                sourceComponent: Component {
                    WlrLayershell {
                        id: homeLayer

                        Component.onCompleted: {
                            PaimonClockConfig.screenWidth = homeLayer.screen.width;
                            PaimonClockConfig.screenHeight = homeLayer.screen.height;
                        }

                        screen: screenScope.modelData
                        layer: WlrLayer.Background
                        keyboardFocus: WlrKeyboardFocus.OnDemand // this one when left commented we can't basically filter in our wallski, if opened, wont let the window to grab toe keyboard for certain amount of time [feature xD]
                        namespace: "quickshell-home"
                        visible: true
                        exclusiveZone: ExclusionMode.Ignore
                        color: "transparent"

                        anchors {
                            top: true
                            bottom: true
                            left: true
                            right: true
                        }

                        //wallpaperService
                        WallpaperService {
                            anchors.fill: parent
                        }

                        Loader {
                            id: paimonClockLoader
                            active: PaimonClockConfig.isActive
                            sourceComponent: PaimonClock {}
                        }
                        //touchpad gestured right click contextmenu [Just like Windows]
                        ContextMenu {}

                        // wallski direct
                        Wallski {
                            id: wallskiRef

                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}
