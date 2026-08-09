pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import qs.Services.Theme
import qs.Services.Sliders
import qs.utils
import qs.Components.common

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 220

    component ColorBehavior: ColorAnimation {
        duration: 200
    }

    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 7
        spacing: 6

        MediaSlider {
            width: 46
            height: parent.height
            value: Math.round(OsdConfig.sinkVolume)
            muted: OsdConfig.sinkMuted
            accentFill: "transparent"
            accentOnFill: Theme.onPrimaryContainer
            trackFill: Theme.primaryContainer
            icons: ["\uf026", "\uf027", "\uf027", "\uf028"]
            onScrub: (delta) => adjustVolume(delta)

            function adjustVolume(delta) {
                OsdConfig.adjustVolume(delta > 0 ? "2%+" : "2%-");
            }
        }

        MediaSlider {
            id: brightSlider
            width: 46
            height: parent.height
            value: brightnessVal
            animate: ready
            accentFill: "transparent"
            accentOnFill: Theme.onPrimaryContainer
            trackFill: Theme.primaryContainer
            icons: ["", "\udb80\udcde", "\udb80\udcdd", "\udb80\udce0"]
            onScrub: (delta) => applyScrub(delta)

            property int brightnessVal: 0
            property bool ready: false

            function applyScrub(delta) {
                brightnessVal = Math.max(0, Math.min(100, brightnessVal + delta));
                OsdConfig.adjustBrightness(delta > 0 ? "2%+" : "2%-");
            }

            Connections {
                target: OsdConfig

                function onBrightnessRead(value) {
                    brightSlider.brightnessVal = value;
                    brightSlider.ready = true;
                }

                function onCurrentValueChanged() {
                    if (OsdConfig.mode === "brightness"){
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
            icon: OsdConfig.sinkMuted ? "\uf026" : OsdConfig.sinkVolume >= 66 ? "\uf028" : OsdConfig.sinkVolume >= 33 ? "\uf027" : "\uf026"
            onClicked: OsdConfig.toggleMute()
        }

        IconButton {
            active: CommunicationConfig.hyprsunsetActive
            activeColor: Theme.primaryContainer
            inactiveColor: Theme.surfaceContainer
            activeIconColor: Theme.onPrimaryContainer
            inactiveIconColor: Theme.onSurfaceVariant
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
                    color: Theme.onSurfaceVariant
                }

                M3Slider {
                    id: gammaSlider
                    width: parent.width - 22
                    height: parent.height
                    value: smoothVal
                    minVal: CommunicationConfig.gammaMin
                    maxVal: CommunicationConfig.gammaMax
                    accentFill: Theme.primaryContainer
                    trackFill: Theme.surfaceBright
                    onScrub: (delta) => scrubGamma(delta)

                    property real smoothVal: CommunicationConfig.gamma

                    Behavior on smoothVal {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutCubic
                        }
                    }

                    function scrubGamma(delta) {
                        if (delta > 0) CommunicationConfig.increaseGamma();
                        else CommunicationConfig.decreaseGamma();
                    }

                    Connections {
                        target: CommunicationConfig
                        function onGammaChanged() {
                            gammaSlider.smoothVal = CommunicationConfig.gamma;
                        }
                    }
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
                    color: Theme.onSurfaceVariant
                }

                M3Slider {
                    id: tempSlider
                    width: parent.width - 22
                    height: parent.height
                    value: smoothVal
                    minVal: CommunicationConfig.tempMin
                    maxVal: CommunicationConfig.tempMax
                    accentFill: Theme.primaryContainer
                    trackFill: Theme.surfaceBright
                    onScrub: (delta) => scrubTemperature(delta)

                    property real smoothVal: CommunicationConfig.temperature

                    Behavior on smoothVal {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutCubic
                        }
                    }

                    function scrubTemperature(delta) {
                        if (delta > 0) CommunicationConfig.increaseTemperature();
                        else CommunicationConfig.decreaseTemperature();
                    }

                    Connections {
                        target: CommunicationConfig
                        function onTemperatureChanged() {
                            tempSlider.smoothVal = CommunicationConfig.temperature;
                        }
                    }
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
            Behavior on color { ColorBehavior {} }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: iconButton.clicked()
        }
    }

    component MediaSlider: Item {
        id: ms
        required property real value
        required property var icons
        property bool muted: false
        required property color accentFill
        required property color accentOnFill
        required property color trackFill
        property bool animate: true
        signal scrub(int delta)

        readonly property real fillFrac: muted ? 0 : value / 100
        readonly property string currentIcon: muted && icons[0] ? icons[0] : value >= 66 ? icons[3] : value >= 33 ? icons[2] : icons[1]

        function scrubBy(delta) {
            scrub(delta > 0 ? 2 : -2);
        }

        ClippingRectangle {
            id: track
            anchors.fill: parent
            radius: 14
            color: Theme.surfaceContainer
            border.width: 1
            border.color: Theme.outlineVariant

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: track.height * ms.fillFrac
                color: ms.trackFill
                Behavior on height {
                    enabled: ms.animate
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.min(track.height - 28, track.height - track.height * ms.fillFrac + 6)
                text: ms.currentIcon
                font.pixelSize: 16
                color: ms.fillFrac > 0.15 ? ms.accentOnFill : Theme.onSurfaceVariant
                Behavior on color { ColorAnimation { duration: 80 } }
                Behavior on y {
                    enabled: ms.animate
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                id: scrubArea
                anchors.fill: parent
                property real startY: 0
                property real startVal: 0

                onPressed: (mouse) => { startY = mouse.y; startVal = ms.value; }
                onPositionChanged: (mouse) => handleDrag(mouse)
                onWheel: (wheel) => handleWheel(wheel)

                function handleDrag(mouse) {
                    const delta = Math.round((startY - mouse.y) / ms.height * 100);
                    const newVal = Math.max(0, Math.min(100, Math.round(startVal + delta)));
                    if (newVal !== ms.value){
                        ms.scrubBy(newVal - ms.value);
                    }
                    if (newVal > 0 && newVal < 100) {
                        startY = mouse.y;
                        startVal = ms.value;
                    }
                }

                function handleWheel(wheel) {
                    const d = wheel.angleDelta.y || -wheel.angleDelta.x;
                    ms.scrubBy(d);
                }
            }
        }
    }
}
