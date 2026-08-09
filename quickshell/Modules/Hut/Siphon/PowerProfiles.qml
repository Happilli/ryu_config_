pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.UPower
import qs.Components.common
import qs.Services.Theme

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 54

    readonly property int btnW: Math.floor((root.implicitWidth - 8) / 3)
    readonly property int btnH: 54
    readonly property int pillH: 38

    readonly property int activeIdx: {
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return 0;
        if (PowerProfiles.profile === PowerProfile.Balanced)
            return 1;
        if (PowerProfiles.profile === PowerProfile.Performance)
            return 2;
        return 1;
    }

    Card {
        anchors.fill: parent
        cardRadius: 20
        surface: Theme.surfaceContainer
        borderColor: Theme.outlineVariant
        borderWidth: 1

        Rectangle {
            id: pill
            width: root.btnW - 8
            height: root.pillH
            y: (root.btnH - root.pillH) / 2
            x: 4 + root.activeIdx * root.btnW + (root.btnW - pill.width) / 2
            radius: 13
            color: Theme.primaryContainer
            border.width: 0

            Behavior on x {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.4
                }
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4

            ProfileButton {
                width: root.btnW
                height: root.btnH
                profile: PowerProfile.PowerSaver
                icon: "\udb80\udf2a"
                tipLabel: "power-saver"
            }
            ProfileButton {
                width: root.btnW
                height: root.btnH
                profile: PowerProfile.Balanced
                icon: "\uf24e"
                tipLabel: "balanced"
            }
            ProfileButton {
                width: root.btnW
                height: root.btnH
                profile: PowerProfile.Performance
                icon: "\udb85\udcde"
                tipLabel: "performance"
                opacity: PowerProfiles.hasPerformanceProfile ? 1.0 : 0.35
                isEnabled: PowerProfiles.hasPerformanceProfile
            }
        }
    }

    component ProfileButton: MorphButton {
        id: btn
        required property int profile
        required property string tipLabel

        contentPixelSize: 20
        baseRadius: 0
        hoverRadius: 0
        activeBorderWidth: 0
        hoverBorderWidth: 0
        activeColor: "transparent"
        hoverColor: "transparent"
        active: PowerProfiles.profile === btn.profile
        activeText: Theme.onPrimaryContainer
        inactiveText: Theme.onSurfaceVariant
        hoverText: Theme.onSurfaceVariant

        property real tipOpacity: 0.0

        function showTip() {
            btn.tipOpacity = 1.0;
            tipFade.restart();
        }

        onClicked: {
            PowerProfiles.profile = btn.profile;
            btn.showTip();
        }

        SequentialAnimation {
            id: tipFade
            PauseAnimation {
                duration: 1000
            }
            NumberAnimation {
                target: btn
                property: "tipOpacity"
                to: 0.0
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: 4
            width: tipText.implicitWidth + 14
            height: tipText.implicitHeight + 6
            opacity: btn.tipOpacity
            visible: opacity > 0.01

            Card {
                anchors.fill: parent
                cardRadius: 8
                surface: Theme.surfaceContainer
                borderColor: Theme.outlineVariant
                borderWidth: 1
            }

            Text {
                id: tipText
                anchors.centerIn: parent
                text: btn.tipLabel
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.onSurface
            }
        }
    }
}
