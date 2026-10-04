pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.Services.Theme
import qs.utils
import qs.Components.common

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 220

    readonly property int volumeLevel: {
        if (OsdConfig.sinkMuted || OsdConfig.sinkVolume <= 0)
            return 0;
        if (OsdConfig.sinkVolume >= 66)
            return 3;
        if (OsdConfig.sinkVolume >= 33)
            return 2;
        return 1;
    }

    component ColorBehavior: ColorAnimation {
        duration: 200
    }

    component ThinSlider: MaterialSlider {
        showStops: false
        showValueIndicator: false
        trackHeight: 4
        handleHeight: 18
        handleWidth: 3
        handleGap: 4
        innerRadius: 2
        color: Theme.primaryColor
        handleColor: Theme.primaryColor
        trackColor: Theme.surfaceBright
    }

    component VSlider: Item {
        id: vs
        property real value: 0
        property bool muted: false
        required property var icons
        signal moved(real value)

        readonly property real shownValue: vs.muted ? 0 : vs.value

        property int level: {
            if (vs.shownValue <= 0)
                return 0;
            if (vs.shownValue >= 66)
                return 3;
            if (vs.shownValue >= 33)
                return 2;
            return 1;
        }

        readonly property string currentIcon: vs.level === 0 && vs.icons[0] ? vs.icons[0] : vs.icons[Math.max(vs.level, 1)]

        MaterialSlider {
            id: slider
            orientation: MaterialSlider.Vertical
            width: vs.width
            height: vs.height
            from: 0
            to: 100
            stepSize: 2
            value: vs.shownValue
            showStops: false
            showValueIndicator: false
            trackHeight: 40
            handleHeight: 46
            handleWidth: 4
            handleGap: 5
            outerRadius: 12
            innerRadius: 4
            borderWidth: 1
            borderColor: Theme.outlineVariant
            color: Theme.primaryContainer
            handleColor: Theme.primaryColor
            trackColor: Theme.surfaceContainer
            iconText: vs.currentIcon
            iconSize: 16
            iconColor: Theme.onPrimaryContainer
            onMoved: vs.moved(slider.value)
        }
    }

    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 7
        spacing: 6

        VSlider {
            id: volSlider
            width: 46
            height: parent.height
            value: volumeVal
            muted: OsdConfig.sinkMuted
            level: root.volumeLevel
            icons: ["\udb81\udd81", "\udb81\udd7f", "\udb81\udd80", "\udb81\udd7e"]
            onMoved: v => {
                volumeVal = Math.max(0, Math.min(100, Math.round(v)));
                OsdConfig.setVolume(volumeVal);
            }

            property int volumeVal: Math.round(OsdConfig.sinkVolume)

            Connections {
                target: OsdConfig

                function onSinkVolumeChanged() {
                    volSlider.volumeVal = Math.round(OsdConfig.sinkVolume);
                }
            }
        }

        VSlider {
            id: brightSlider
            width: 46
            height: parent.height
            value: brightnessVal
            icons: ["", "\udb80\udcde", "\udb80\udcdd", "\udb80\udce0"]
            onMoved: v => applyBrightness(v)

            property int brightnessVal: 0

            function applyBrightness(v) {
                brightnessVal = Math.max(0, Math.min(100, Math.round(v)));
                OsdConfig.adjustBrightness(brightnessVal + "%");
            }

            Connections {
                target: OsdConfig

                function onBrightnessRead(value) {
                    brightSlider.brightnessVal = value;
                }

                function onCurrentValueChanged() {
                    if (OsdConfig.mode === "brightness") {
                        brightSlider.brightnessVal = OsdConfig.currentValue;
                    }
                }
            }

            Component.onCompleted: OsdConfig.readBrightness()
        }
    }

    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        spacing: 6

        IconButton {
            active: !OsdConfig.sinkMuted
            activeColor: Theme.primaryContainer
            inactiveColor: Theme.errorContainer
            activeIconColor: Theme.onPrimaryContainer
            inactiveIconColor: Theme.onErrorContainer
            icon: ["\uf026", "\uf027", "\uf027", "\uf028"][root.volumeLevel]
            onClicked: OsdConfig.toggleMute()
        }

        IconButton {
            active: CommunicationConfig.hyprsunsetActive
            activeColor: Theme.primaryContainer
            inactiveColor: Theme.surfaceContainer
            activeIconColor: Theme.onPrimaryContainer
            inactiveIconColor: Theme.onSurface
            icon: "\ueeef"
            onClicked: CommunicationConfig.toggle()
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 116 + 12
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 54

        Card {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: _sliders.top
            anchors.bottomMargin: 6
            cardRadius: 20
            surface: Theme.surfaceContainer
            borderColor: Theme.outlineVariant
            borderWidth: 1

            Uptime {
                anchors.fill: parent
            }
        }

        Column {
            id: _sliders
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 6

            Row {
                width: parent.width
                height: 28
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "G"
                    font.pixelSize: 14
                    color: Theme.onSurface
                }

                ThinSlider {
                    id: gammaSlider
                    width: parent.width - 22
                    height: parent.height
                    from: CommunicationConfig.gammaMin
                    to: CommunicationConfig.gammaMax
                    stepSize: CommunicationConfig.gammaStep
                    value: CommunicationConfig.gamma
                    onMoved: CommunicationConfig.setGamma(gammaSlider.value)
                }
            }

            Row {
                width: parent.width
                height: 28
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "T"
                    font.pixelSize: 14
                    color: Theme.onSurface
                }

                ThinSlider {
                    id: tempSlider
                    width: parent.width - 22
                    height: parent.height
                    from: CommunicationConfig.tempMin
                    to: CommunicationConfig.tempMax
                    stepSize: CommunicationConfig.tempStep
                    value: CommunicationConfig.temperature
                    onMoved: CommunicationConfig.setTemperature(tempSlider.value)
                }
            }
        }
    }

    component IconButton: Item {
        id: iconButton
        width: 48
        height: 48
        required property bool active
        required property color activeColor
        required property color inactiveColor
        required property color activeIconColor
        required property color inactiveIconColor
        required property string icon
        signal clicked

        Card {
            anchors.fill: parent
            cardRadius: 14
            surface: iconButton.active ? iconButton.activeColor : iconButton.inactiveColor
            borderColor: Theme.outlineVariant
            borderWidth: 1
        }

        Text {
            anchors.centerIn: parent
            text: iconButton.icon
            font.pixelSize: 15
            color: iconButton.active ? iconButton.activeIconColor : iconButton.inactiveIconColor
            Behavior on color {
                ColorBehavior {}
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: iconButton.clicked()
        }
    }
}
