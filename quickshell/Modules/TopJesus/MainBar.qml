pragma ComponentBehavior: Bound
import "./Tunes/"
import QtQuick
import qs.Components.common
import qs.Components.topjesus
import qs.Services.Shapes
import qs.Services.Theme
import qs.Configuration.Cleave

Item {
    id: barRoot

    required property var parentScreen
    required property bool isHovered
    required property bool isPinned
    required property int activePopout
    required property var popoutIcons

    readonly property alias barHeight: popout.height

    signal pinToggled
    signal iconHovered(int id)
    signal iconRowHoverChanged(bool hovered)
    signal bridgeHoverChanged(bool hovered)

    implicitWidth: 1360
    implicitHeight: popout.height

    PopoutShape {
        id: popout

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: 1360
        height: (barRoot.isHovered || barRoot.isPinned) ? 40 : 0
        alignment: 0
        clip: true
        radius: 20
        color: Theme.shell

        Item {
            anchors.fill: parent
            anchors.margins: 10
            opacity: (barRoot.isHovered || barRoot.isPinned) ? 1 : 0

            Workspace {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                parentScreen: barRoot.parentScreen
                workspaceSize: 40
                spacing: 0
            }

            Row {
                spacing: 10
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter

                Loader {
                    id: tunerLoader

                    anchors.verticalCenter: parent.verticalCenter
                    active: barRoot.isHovered || barRoot.isPinned

                    sourceComponent: Component {
                        Tuner {
                            id: tuner

                            Component.onCompleted: {
                                if (tuner.isPlaying) {
                                    CleaveConfig.activate();
                                }
                            }

                            onPlayingChanged: {
                                if (tuner.isPlaying) {
                                    CleaveConfig.activate();
                                } else {
                                    CleaveConfig.deactivate();
                                }
                            }
                        }
                    }

                    onActiveChanged: {
                        if (!active) {
                            CleaveConfig.deactivate();
                        }
                    }
                }

                Pin {
                    anchors.verticalCenter: parent.verticalCenter
                    pinned: barRoot.isPinned
                    onClicked: barRoot.pinToggled()
                }

                Loader {
                    active: barRoot.isHovered || barRoot.isPinned
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: Component {
                        Battery {}
                    }
                }

                Loader {
                    active: barRoot.isHovered || barRoot.isPinned
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: Component {
                        TaskBar {}
                    }
                }

                Item {
                    height: 28
                    width: iconRow.width
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: iconRow

                        height: 32
                        radius: 8
                        width: iconRowContent.width + 20
                        anchors.centerIn: parent
                        color: barRoot.activePopout > 0 ? Theme.cardInner : Theme.card
                        border.color: barRoot.activePopout > 0 ? Theme.primaryColor : Theme.outlineVariant
                        border.width: barRoot.activePopout > 0 ? 1 : 0.5

                        Row {
                            id: iconRowContent

                            anchors.centerIn: parent

                            Repeater {
                                model: barRoot.popoutIcons

                                Rectangle {
                                    id: iconRect

                                    required property var modelData
                                    readonly property bool isGear: iconRect.modelData.id === 2

                                    width: 36
                                    height: 28
                                    radius: 6
                                    color: "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: iconRect.modelData.icon
                                        font.pixelSize: 20
                                        color: barRoot.activePopout === iconRect.modelData.id ? Theme.primaryColor : iMouse.containsMouse ? Theme.onSurface : Theme.textSecondary
                                        rotation: iconRect.isGear && iMouse.containsMouse ? 90 : 0

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 200
                                            }
                                        }

                                        Behavior on rotation {
                                            NumberAnimation {
                                                duration: 500
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: iMouse

                                        anchors.fill: parent
                                        hoverEnabled: barRoot.isPinned
                                        enabled: barRoot.isPinned
                                        cursorShape: barRoot.isPinned ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onEntered: barRoot.iconHovered(iconRect.modelData.id)
                                    }

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 300
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Behavior on border.width {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }

                    Rectangle {
                        anchors.top: iconRow.bottom
                        anchors.horizontalCenter: iconRow.horizontalCenter
                        width: iconRow.width
                        height: 20
                        color: "transparent"

                        HoverHandler {
                            enabled: barRoot.isPinned
                            onHoveredChanged: barRoot.bridgeHoverChanged(hovered)
                        }
                    }

                    HoverHandler {
                        enabled: barRoot.isPinned
                        onHoveredChanged: barRoot.iconRowHoverChanged(hovered)
                    }
                }

                DayWidget {
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.onSurface
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter

                    ClockWidget {
                        font.pixelSize: 14
                        color: Theme.onSurface
                    }

                    DateWidget {
                        font.pixelSize: 14
                        color: Theme.onSurface
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
