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
            "poketwo": ToggleConfigs.poketwo,
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

    readonly property var activeStates: [ToggleConfigs.dancer.isActive, ToggleConfigs.omnitrix.isActive, ToggleConfigs.poketwo.isActive, PaimonClockConfig.isActive]

    property real w0: btnNormal
    property real w1: btnNormal
    property real w2: btnNormal
    property real w3: btnNormal

    readonly property real totalWidth: w0 + w1 + w2 + w3 + groupSpacing * 3

    Item {
        anchors.centerIn: parent
        width: root.totalWidth
        height: root.btnHeight

        Repeater {
            model: [
                {
                    "icon": "\udb85\uddcf",
                    "active": ToggleConfigs.dancer.isActive,
                    "activeColor": Theme.primaryContainer,
                    "activeBorder": Theme.primaryColor,
                    "activeText": Theme.onPrimaryContainer,
                    "service": "dancer"
                },
                {
                    "icon": "\udb81\udeb1",
                    "active": ToggleConfigs.omnitrix.isActive,
                    "activeColor": Theme.secondaryContainer,
                    "activeBorder": Theme.secondaryColor,
                    "activeText": Theme.onSecondaryContainer,
                    "service": "omnitrix"
                },
                {
                    "icon": "\udb84\udf93",
                    "active": ToggleConfigs.poketwo.isActive,
                    "activeColor": Theme.tertiaryContainer,
                    "activeBorder": Theme.tertiaryColor,
                    "activeText": Theme.onTertiaryContainer,
                    "service": "poketwo"
                },
                {
                    "icon": "\ue641",
                    "active": PaimonClockConfig.isActive,
                    "activeColor": Theme.primaryContainer,
                    "activeBorder": Theme.primaryColor,
                    "activeText": Theme.onPrimaryContainer,
                    "service": "paimonclock"
                }
            ]

            delegate: Item {
                id: btn

                required property var modelData
                required property int index

                readonly property bool isActive: modelData.active
                readonly property bool leftActive: index > 0 && root.activeStates[index - 1]
                readonly property bool rightActive: index < 3 && root.activeStates[index + 1]
                readonly property bool isCompressed: !isActive && (leftActive || rightActive)

                readonly property real targetWidth: isActive ? root.btnExpanded : isCompressed ? root.btnCompressed : root.btnNormal

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
                    if (index === 0)
                        root.w0 = animWidth;
                    else if (index === 1)
                        root.w1 = animWidth;
                    else if (index === 2)
                        root.w2 = animWidth;
                    else if (index === 3)
                        root.w3 = animWidth;
                }

                readonly property real naturalX: {
                    if (index === 0)
                        return 0;
                    if (index === 1)
                        return root.w0 + root.groupSpacing;
                    if (index === 2)
                        return root.w0 + root.w1 + root.groupSpacing * 2;
                    return root.w0 + root.w1 + root.w2 + root.groupSpacing * 3;
                }

                readonly property real inactiveLeftR: index === 0 ? root.outerRadius : root.innerRadius
                readonly property real inactiveRightR: index === 3 ? root.outerRadius : root.innerRadius

                x: naturalX
                y: 0
                width: animWidth
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
