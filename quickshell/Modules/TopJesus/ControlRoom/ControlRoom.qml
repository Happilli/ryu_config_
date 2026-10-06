pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Ryu.Extraa
import qs.Services.Theme

Item {
    id: root

    property int cpuTemp: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0
    property real cpuPerc: 0
    property real usedMemoryPerc: 0
    property bool componentActive: true

    readonly property var memTotalRegex: /MemTotal:\s+(\d+)/
    readonly property var memAvailRegex: /MemAvailable:\s+(\d+)/
    readonly property var cpuRegex: /^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/

    Component.onDestruction: {
        root.componentActive = false;
        updateTimer.running = false;
    }

    FileView {
        id: hwmonReader
        path: "file:///sys/class/hwmon/hwmon5/temp1_input"
        onLoaded: {
            if (root.componentActive) {
                root.cpuTemp = (parseInt(hwmonReader.text().trim(), 10) || 0) / 1000;
            }
        }
    }

    FileView {
        id: procStat
        path: "file:///proc/stat"
        onLoaded: {
            if (!root.componentActive)
                return;

            const match = procStat.text().match(root.cpuRegex);
            if (!match)
                return;

            const user = parseInt(match[1], 10);
            const nice = parseInt(match[2], 10);
            const system = parseInt(match[3], 10);
            const idle = parseInt(match[4], 10);
            const iowait = parseInt(match[5], 10);
            const irq = parseInt(match[6], 10);
            const softirq = parseInt(match[7], 10);

            const currentIdle = idle + iowait;
            const currentTotal = user + nice + system + currentIdle + irq + softirq;

            const di = currentIdle - root.lastCpuIdle;
            const dt = currentTotal - root.lastCpuTotal;

            if (root.lastCpuTotal > 0 && dt > 0) {
                root.cpuPerc = 1.0 - (di / dt);
            }

            root.lastCpuIdle = currentIdle;
            root.lastCpuTotal = currentTotal;
        }
    }

    FileView {
        id: procMemInfo
        path: "file:///proc/meminfo"
        onLoaded: {
            if (!root.componentActive)
                return;

            const fileText = procMemInfo.text();
            const matchTotal = fileText.match(root.memTotalRegex);
            const matchAvail = fileText.match(root.memAvailRegex);

            if (matchTotal && matchAvail) {
                const total = parseInt(matchTotal[1], 10);
                const available = parseInt(matchAvail[1], 10);

                if (total > 0) {
                    root.usedMemoryPerc = 1.0 - (available / total);
                }
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 1000
        running: root.componentActive
        repeat: true
        onTriggered: {
            if (!root.componentActive)
                return;
            hwmonReader.reload();
            procStat.reload();
            procMemInfo.reload();
        }
    }

    RowLayout {
        anchors.fill: parent

        Repeater {
            model: [
                {
                    "label": "RAM",
                    "idx": 0
                },
                {
                    "label": "CPU",
                    "idx": 1
                },
                {
                    "label": "TEMP",
                    "idx": 2
                }
            ]

            delegate: Item {
                id: card

                required property var modelData

                readonly property real val: modelData.idx === 0 ? root.usedMemoryPerc : modelData.idx === 1 ? root.cpuPerc : Math.min(root.cpuTemp / 100, 1)

                readonly property color accent: modelData.idx === 0 ? Theme.secondaryColor : modelData.idx === 1 ? Theme.primaryColor : Theme.tertiaryColor

                readonly property string valueText: modelData.idx === 2 ? Math.round(root.cpuTemp) + "°" : Math.round(val * 100) + "%"

                property real animatedVal: 0

                Behavior on animatedVal {
                    NumberAnimation {
                        duration: 700
                        easing.type: Easing.OutCubic
                    }
                }

                onValChanged: card.animatedVal = card.val

                Layout.fillWidth: true
                Layout.fillHeight: true

                Item {
                    id: ring

                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) * 0.9
                    height: width

                    WavyProgress {
                        anchors.fill: parent
                        style: WavyProgress.Circular
                        indeterminate: false
                        progress: card.animatedVal
                        color: card.accent
                        trackColor: Qt.rgba(card.accent.r, card.accent.g, card.accent.b, 0.18)
                        amplitude: 0
                        wavelength: 20
                        waveSpeed: 0.6
                        strokeWidth: 3
                        gap: 10
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: card.valueText
                            color: Theme.onSurface
                            font.pixelSize: Math.max(12, ring.width * 0.2)
                            font.bold: true
                            renderType: Text.NativeRendering
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: card.modelData.label
                            color: Theme.textSecondary
                            font.pixelSize: Math.max(9, ring.width * 0.11)
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }
        }
    }
}
