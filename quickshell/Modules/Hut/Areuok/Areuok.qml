pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell.Io
import qs.Services.Theme
import qs.Services.Shapes
import qs.Components.common

Item {
    id: root
    implicitWidth: inner.width + 24
    implicitHeight: 50

    readonly property var serviceList: ["docker", "mariadb", "cloudflared"]
    property var services: ({})
    property bool componentActive: true

    Component.onCompleted: startupDelay.start()

    Component.onDestruction: {
        root.componentActive = false;
        serviceCheckTimer.running = false;
    }

    Timer {
        id: serviceCheckTimer
        interval: 5000
        running: root.componentActive
        repeat: true
        onTriggered: {
            if (root.componentActive)
                root.checkAllServices();
        }
    }

    Timer {
        id: startupDelay
        interval: 400
        repeat: false
        onTriggered: root.checkAllServices()
    }

    function checkAllServices() {
        if (!root.componentActive || checkProcess.running)
            return;
        checkProcess.running = true;
    }

    Process {
        id: checkProcess
        command: ["systemctl", "is-active", ...root.serviceList]

        stdout: StdioCollector {
            id: checkStdout
        }

        onExited: {
            if (!root.componentActive) {
                return;
            }

            const lines = checkStdout.text.trim().split('\n');
            const s = {};
            for (let i = 0; i < root.serviceList.length; i++) {
                s[root.serviceList[i]] = (lines[i] ?? "").trim() === "active";
            }
            root.services = s;
        }
    }

    Card {
        anchors.fill: parent
        cardRadius: 20

        Row {
            id: inner
            spacing: 8
            anchors.centerIn: parent

            Repeater {
                model: [
                    {
                        name: "docker",
                        icon: "\uF308",
                        display: "Docker",
                        shapeIdx: 22
                    },
                    {
                        name: "mariadb",
                        icon: "\ue828",
                        display: "MariaDB",
                        shapeIdx: 13
                    },
                    {
                        name: "cloudflared",
                        icon: "\ue792",
                        display: "Cloudflared",
                        shapeIdx: 14
                    }
                ]

                delegate: Item {
                    id: chip
                    required property var modelData
                    required property int index

                    width: 38
                    height: 38

                    readonly property bool running: root.services[chip.modelData.name] === true
                    readonly property bool hovered: hoverArea.containsMouse

                    ShapeCanvas {
                        anchors.fill: parent
                        roundedPolygon: GetMShapes.get(chip.modelData.shapeIdx)
                        color: {
                            if (chip.hovered) {
                                return chip.running ? Theme.primaryContainer : Theme.errorContainer;
                            }
                            return chip.running ? Theme.primaryColor : Theme.surfaceContainerHigh;
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: chip.modelData.icon
                        font.pixelSize: 24
                        color: {
                            if (chip.hovered) {
                                return chip.running ? Theme.onPrimaryContainer : Theme.onErrorContainer;
                            }
                            return chip.running ? Theme.surfaceContainer : Theme.onSurfaceVariant;
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 300
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    ToolTip {
                        id: tooltip
                        visible: chip.hovered
                        delay: 300
                        text: chip.modelData.display + (chip.running ? " running" : " stopped")
                        background: Rectangle {
                            color: Theme.surfaceContainer
                            radius: 8
                            border.width: 1
                            border.color: Theme.outlineVariant
                        }
                        contentItem: Text {
                            text: tooltip.text
                            color: Theme.onSurface
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }
        }
    }
}
