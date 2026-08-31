pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.utils
import qs.Components.Wow
import qs.Components.Poketwo
import qs.Components.Artiqa
import qs.Components.Dancer
import qs.Components.Omnitrix
import qs.Modules.Screenshot
import qs.Configuration.Screenshot
import qs.Components.notification
import qs.Modules.Chernobyl
import qs.Services

Scope {
    Variants {
        model: Quickshell.screens
        Scope {
            id: screenScope
            required property var modelData
            property bool isPrimary: screenScope.modelData === Quickshell.screens[0]
            property int activeNotifs: 0
            Loader {
                active: ToggleConfigs.wow.isActive || screenScope.activeNotifs > 0 || ScreenshotConfig.isActive || NotificationService.count > 0 || ToggleConfigs.chernobyl.isActive || ToggleConfigs.artiqa.isActive || ToggleConfigs.poketwo.isActive || ToggleConfigs.dancer.isActive || ToggleConfigs.omnitrix.isActive

                sourceComponent: Component {
                    WlrLayershell {
                        id: oLay
                        screen: screenScope.modelData
                        layer: WlrLayer.Overlay
                        keyboardFocus: (ScreenshotConfig.isSelectingRegion || ToggleConfigs.artiqa.isActive) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
                        namespace: "quickshell-oppression-layer"
                        exclusiveZone: -1

                        color: "transparent"
                        anchors {
                            top: true
                            bottom: true
                            left: true
                            right: true
                        }
                        mask: Region {
                            Region {
                                width: (ToggleConfigs.wow.isActive || ScreenshotConfig.isActive || ToggleConfigs.artiqa.isActive) ? oLay.width : 0
                                height: (ToggleConfigs.wow.isActive || ScreenshotConfig.isActive || ToggleConfigs.artiqa.isActive) ? oLay.height : 0
                            }
                            Region {
                                x: notifWindow.x
                                y: notifWindow.y
                                width: notifWindow.visible ? notifWindow.width + 4 : 1
                                height: notifWindow.visible ? notifWindow.height + 4 : 1
                            }
                            Region {
                                x: (oLay.width - chernobylLoader.width) / 2
                                y: (oLay.height - chernobylLoader.height) / 2
                                width: ToggleConfigs.chernobyl.isActive ? chernobylLoader.width : 1
                                height: ToggleConfigs.chernobyl.isActive ? chernobylLoader.height : 1
                            }
                            Region {
                                x: (oLay.width - 600) / 2
                                y: (oLay.height - 600) / 2
                                width: ToggleConfigs.omnitrix.isActive ? 600 : 1
                                height: ToggleConfigs.omnitrix.isActive ? 600 : 1
                            }
                        }
                        Loader {
                            anchors.fill: parent
                            active: ToggleConfigs.wow.isActive
                            sourceComponent: Component {
                                Wow {}
                            }
                        }
                        Loader {
                            anchors.fill: parent
                            active: ToggleConfigs.artiqa.isActive
                            focus: active
                            sourceComponent: Component {
                                Artiqa {
                                    id: artiqaRef
                                    active: true
                                    focus: true
                                    Keys.onPressed: event => {
                                        if (event.key === Qt.Key_Escape) {
                                            ToggleConfigs.artiqa.hide();
                                            event.accepted = true;
                                        }
                                    }
                                }
                            }
                        }

                        Loader {
                            id: chernobylLoader
                            anchors.centerIn: parent
                            active: ToggleConfigs.chernobyl.isActive
                            sourceComponent: Component {
                                Chernobyl {}
                            }
                        }

                        Loader {
                            anchors.fill: parent
                            active: ToggleConfigs.poketwo.isActive
                            sourceComponent: Component {
                                Poketwo {}
                            }
                        }
                        Loader {
                            anchors.fill: parent
                            active: ToggleConfigs.dancer.isActive
                            focus: active
                            sourceComponent: Component {
                                BouncingDancer {
                                    anchors.fill: parent
                                    active: true
                                }
                            }
                        }
                        Loader {
                            id: omnitrixLoaderOppression
                            anchors.fill: parent
                            active: ToggleConfigs.omnitrix.isActive
                            focus: active
                            sourceComponent: Component {
                                OmnitrixLauncher {
                                    id: omnitrixRef
                                    anchors.fill: parent
                                    active: true
                                    focus: true
                                    onCloseRequested: ToggleConfigs.omnitrix.hide()
                                }
                            }
                        }
                        NotificationWindow {
                            id: notifWindow
                            anchors {
                                right: parent.right
                                top: parent.top
                                rightMargin: 4
                                topMargin: 4
                            }
                        }
                        Loader {
                            anchors.fill: parent
                            active: ScreenshotConfig.isActive && screenScope.isPrimary
                            sourceComponent: Component {
                                Screenshot {
                                    screen: screenScope.modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
