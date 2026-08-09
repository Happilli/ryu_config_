pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import qs.Services.Wow
import qs.utils
import qs.Services.Theme

Item {
    id: root

    property int workspacesShown: 10
    property real workspaceWidth: 300
    property real workspaceHeight: 166
    property real gridSpacing: 24
    readonly property var jpN: ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

    visible: ToggleConfigs.wow.isActive
    enabled: ToggleConfigs.wow.isActive
    clip: false
    anchors.fill: parent

    Component.onCompleted: {
        Hyprland.refreshMonitors();
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();
    }

    readonly property int columns: 5
    readonly property int rows: 2
    readonly property real gridWidth: root.columns * root.workspaceWidth + (root.columns - 1) * root.gridSpacing
    readonly property real gridHeight: root.rows * root.workspaceHeight + (root.rows - 1) * root.gridSpacing
    readonly property real gridX: (root.width - root.gridWidth) / 2
    readonly property real gridY: (root.height - root.gridHeight) / 2

    Repeater {
        model: root.workspacesShown

        Item {
            id: workspaceWrapper

            required property int index
            readonly property int workspaceId: index + 1
            readonly property bool isActive: WowService.activeWorkspaceId === workspaceId
            property bool isDropTarget: false
            readonly property HyprlandWorkspace wsp: Hyprland.workspaces.values.find(s => {
                return s.id === workspaceId;
            }) || null
            readonly property var geo: WowService.workspaceGeometry(wsp)
            readonly property var geoScale: WowService.scaleFactors(geo, root.workspaceWidth, root.workspaceHeight)
            readonly property var validToplevels: geo.valid

            readonly property int col: index % root.columns
            readonly property int row: Math.floor(index / root.columns)

            x: root.gridX + col * (root.workspaceWidth + root.gridSpacing)
            y: root.gridY + row * (root.workspaceHeight + root.gridSpacing)
            width: root.workspaceWidth
            height: root.workspaceHeight
            z: isActive ? 10 : 1
            ClippingRectangle {
                anchors.fill: parent
                radius: 12
                color: workspaceWrapper.isDropTarget ? Theme.accentColor : workspaceWrapper.isActive ? Theme.surfaceContainerHigh : Theme.surfaceColor

                Text {
                    anchors.centerIn: parent
                    text: root.jpN[workspaceWrapper.workspaceId - 1] || workspaceWrapper.workspaceId
                    color: Theme.textColor
                    font.pixelSize: 48
                    font.weight: Font.DemiBold
                    opacity: 0.1
                }

                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 6
                    text: workspaceWrapper.workspaceId
                    color: Theme.textColor
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    opacity: 0.45
                }

                Connections {
                    function onObjectInsertedPre() {
                        Hyprland.refreshToplevels();
                    }
                    function onObjectInsertedPost() {
                        Hyprland.refreshToplevels();
                    }
                    function onObjectRemovedPre() {
                        Hyprland.refreshToplevels();
                    }
                    function onObjectRemovedPost() {
                        Hyprland.refreshToplevels();
                    }
                    target: workspaceWrapper.wsp ? workspaceWrapper.wsp.toplevels : null
                }

                Repeater {
                    model: workspaceWrapper.validToplevels

                    Item {
                        id: windowItem

                        required property HyprlandToplevel modelData
                        readonly property string address: modelData.lastIpcObject.address ?? ""
                        readonly property var ipc: modelData.lastIpcObject
                        readonly property var rect: WowService.windowCellRect(ipc, workspaceWrapper.geo, workspaceWrapper.geoScale)
                        property bool isClosing: false
                        property bool isDragging: false
                        property bool isOutOfBounds: false

                        x: isDragging ? x : rect.x
                        y: isDragging ? y : rect.y
                        width: rect.w
                        height: rect.h
                        z: isDragging ? 999 : 2
                        opacity: isClosing ? 0 : 1
                        scale: isClosing ? 0.85 : 1
                        onIsClosingChanged: {
                            if (isClosing)
                                closeTimer.start();
                        }
                        Drag.active: dragHandler.active
                        Drag.source: windowItem
                        Drag.supportedActions: Qt.MoveAction
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2

                        Timer {
                            id: closeTimer
                            interval: 230
                            onTriggered: Quickshell.execDetached(["hyprctl", "eval", `local w = hl.get_window("address:${windowItem.address}"); hl.dispatch(hl.dsp.window.close({ window = w }))`])
                        }

                        ScreencopyView {
                            anchors.fill: parent
                            captureSource: windowItem.modelData.wayland
                            live: workspaceWrapper.isActive
                            Component.onCompleted: Hyprland.refreshToplevels()
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.errorColor
                            radius: 4
                            visible: windowItem.isOutOfBounds
                            border.color: Theme.outlineColor
                            border.width: 2
                            opacity: 0.4
                        }

                        HoverHandler {
                            cursorShape: windowItem.isDragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        }

                        DragHandler {
                            id: dragHandler
                            target: windowItem
                            onActiveChanged: {
                                if (active) {
                                    windowItem.isDragging = true;
                                    windowItem.isOutOfBounds = false;
                                } else {
                                    if (windowItem.Drag.target === null) {
                                        windowItem.isDragging = false;
                                        windowItem.isOutOfBounds = false;
                                        windowItem.isClosing = true;
                                    } else {
                                        windowItem.Drag.drop();
                                        windowItem.isDragging = false;
                                        windowItem.isOutOfBounds = false;
                                    }
                                }
                            }

                            onTranslationChanged: {
                                if (dragHandler.active) {
                                    windowItem.isOutOfBounds = (windowItem.Drag.target === null);
                                }
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.OutQuad
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 350
                                easing.type: Easing.OutQuad
                            }
                        }

                        states: State {
                            when: windowItem.isDragging
                            ParentChange {
                                target: windowItem
                                parent: root
                            }
                        }
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 12
                border.width: (workspaceWrapper.isDropTarget || workspaceWrapper.isActive) ? 2 : 1
                border.color: (workspaceWrapper.isDropTarget || workspaceWrapper.isActive) ? Theme.accentColor : Qt.rgba(Theme.textColor.r, Theme.textColor.g, Theme.textColor.b, 0.35)

                Behavior on border.color {
                    ColorAnimation {
                        duration: 300
                    }
                }

                Behavior on border.width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                }
            }

            property string pendingDropAddress: ""

            DropArea {
                anchors.fill: parent
                onEntered: function (drag) {
                    workspaceWrapper.isDropTarget = true;
                    const src = drag.source;
                    workspaceWrapper.pendingDropAddress = src ? (src.address ?? "") : "";
                }
                onExited: {
                    workspaceWrapper.isDropTarget = false;
                    workspaceWrapper.pendingDropAddress = "";
                }
                onDropped: function (drop) {
                    workspaceWrapper.isDropTarget = false;
                    const addr = workspaceWrapper.pendingDropAddress;
                    workspaceWrapper.pendingDropAddress = "";
                    if (addr) {
                        Quickshell.execDetached(["hyprctl", "eval", `local w = hl.get_window("address:${addr}"); hl.dispatch(hl.dsp.window.move({ workspace = ${workspaceWrapper.workspaceId}, window = w, silent = true }))`]);
                        Hyprland.refreshWorkspaces();
                        Hyprland.refreshMonitors();
                        Hyprland.refreshToplevels();
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                z: 1
                onClicked: {
                    let ws = Hyprland.workspaces.values.find(w => w.id === workspaceWrapper.workspaceId);
                    if (ws) {
                        ws.activate();
                    } else {
                        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", String(workspaceWrapper.workspaceId)]);
                    }
                }
            }
        }
    }
}
