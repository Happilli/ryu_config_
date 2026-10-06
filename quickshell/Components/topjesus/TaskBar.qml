pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import qs.Services.Theme
import qs.Services.Toplevels
import qs.Components.common

Item {
    id: root

    readonly property var groups: Toplevels.enriched ?? []

    visible: root.groups.length > 0
    implicitWidth: visible ? pill.width : 0
    implicitHeight: visible ? pill.height : 0

    Card {
        id: pill

        height: 32
        cardRadius: 8
        width: iconStrip.implicitWidth + 20
        surface: Theme.card
        border.color: Theme.outlineVariant
        border.width: 0.5

        Row {
            id: iconStrip

            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: root.groups

                delegate: Item {
                    id: iconDelegate

                    required property var modelData
                    readonly property var instances: iconDelegate.modelData.toplevels ?? []
                    readonly property bool anyActive: iconDelegate.instances.some(inst => inst?.toplevel?.activated)

                    width: 32
                    height: 28

                    TapHandler {
                        onTapped: Toplevels.toggleGroup(iconDelegate.modelData)
                    }

                    IconImage {
                        id: appIcon
                        anchors.centerIn: parent
                        implicitSize: 18
                        source: iconDelegate.modelData.icon ?? ""
                        opacity: iconDelegate.anyActive ? 1.0 : 0.65

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }

                    Repeater {
                        model: iconDelegate.instances

                        delegate: Text {
                            id: orbitDot
                            required property var modelData
                            required property int index

                            readonly property int total: iconDelegate.instances.length
                            readonly property real angle: (Math.PI * 2 / Math.max(total, 1)) * index + Math.PI / 2
                            readonly property real orbitRadius: appIcon.implicitSize / 2 + 5

                            text: "\uf444"
                            font.pixelSize: 7
                            color: Theme.primaryColor
                            opacity: iconDelegate.anyActive ? 1.0 : 0.0

                            x: Math.round(appIcon.x + appIcon.width / 2 + Math.cos(orbitDot.angle) * orbitDot.orbitRadius - width / 2)
                            y: Math.round(appIcon.y + appIcon.height / 2 + Math.sin(orbitDot.angle) * orbitDot.orbitRadius - height / 2)

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutQuad
                                }
                            }
                        }
                    }
                }
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }
    }
}
