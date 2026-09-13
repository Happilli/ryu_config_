pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import qs.utils
import qs.Components.common

Item {
    id: root
    readonly property var configs: ({
            "dancer": ToggleConfigs.dancer,
            "omnitrix": ToggleConfigs.omnitrix,
            "paimonclock": PaimonClockConfig
        })
    function toggle(service) {
        const config = root.configs[service];
        if (!config)
            return;
        config.toggle();
    }

    readonly property int btnHeight: 56
    readonly property int btnNormal: 56
    readonly property int btnExpanded: 80
    readonly property int btnCompressed: 46
    readonly property int outerRadius: 28
    readonly property int innerRadius: 4
    readonly property int groupSpacing: 4

    readonly property var activeStates: [ToggleConfigs.dancer.isActive, ToggleConfigs.omnitrix.isActive, PaimonClockConfig.isActive]

    readonly property var buttonModel: [
        {
            "icon": "\udb85\uddcf",
            "activeColor": Theme.primaryContainer,
            "activeBorder": Theme.primaryColor,
            "activeText": Theme.onPrimaryContainer,
            "service": "dancer"
        },
        {
            "icon": "\udb81\udeb1",
            "activeColor": Theme.secondaryContainer,
            "activeBorder": Theme.secondaryColor,
            "activeText": Theme.onSecondaryContainer,
            "service": "omnitrix"
        },
        {
            "icon": "\ue641",
            "activeColor": Theme.primaryContainer,
            "activeBorder": Theme.primaryColor,
            "activeText": Theme.onPrimaryContainer,
            "service": "paimonclock"
        }
    ]

    property real w0: btnNormal
    property real w1: btnNormal
    property real w2: btnNormal

    readonly property real totalWidth: w0 + w1 + w2 + groupSpacing * 2

    Item {
        anchors.centerIn: parent
        width: root.totalWidth
        height: root.btnHeight

        Repeater {
            model: root.buttonModel

            delegate: Item {
                id: btn

                required property var modelData
                required property int index

                readonly property bool isActive: root.configs[btn.modelData.service].isActive
                readonly property bool leftActive: btn.index > 0 && root.activeStates[btn.index - 1]
                readonly property bool rightActive: btn.index < 2 && root.activeStates[btn.index + 1]
                readonly property bool isCompressed: !btn.isActive && (btn.leftActive || btn.rightActive)

                readonly property real targetWidth: btn.isActive ? root.btnExpanded : btn.isCompressed ? root.btnCompressed : root.btnNormal

                property real animWidth: root.btnNormal
                onTargetWidthChanged: animWidth = targetWidth

                Behavior on animWidth {
                    SpringAnimation {
                        spring: 5.0
                        damping: 0.7
                        epsilon: 0.5
                    }
                }

                onAnimWidthChanged: {
                    if (btn.index === 0)
                        root.w0 = btn.animWidth;
                    else if (btn.index === 1)
                        root.w1 = btn.animWidth;
                    else if (btn.index === 2)
                        root.w2 = btn.animWidth;
                }

                readonly property real naturalX: {
                    if (btn.index === 0)
                        return 0;
                    if (btn.index === 1)
                        return root.w0 + root.groupSpacing;
                    return root.w0 + root.w1 + root.groupSpacing * 2;
                }

                readonly property real inactiveLeftR: btn.index === 0 ? root.outerRadius : root.innerRadius
                readonly property real inactiveRightR: btn.index === 2 ? root.outerRadius : root.innerRadius

                x: btn.naturalX
                y: 0
                width: btn.animWidth
                height: root.btnHeight

                PillSegment {
                    anchors.fill: parent
                    active: btn.isActive
                    icon: btn.modelData.icon
                    contentPixelSize: 26
                    activeBorderWidth: 2
                    inactiveBorderWidth: 1
                    topLeftRadius: btn.isActive ? root.outerRadius : btn.inactiveLeftR
                    bottomLeftRadius: btn.isActive ? root.outerRadius : btn.inactiveLeftR
                    topRightRadius: btn.isActive ? root.outerRadius : btn.inactiveRightR
                    bottomRightRadius: btn.isActive ? root.outerRadius : btn.inactiveRightR
                    onClicked: root.toggle(btn.modelData.service)
                }
            }
        }
    }
}
