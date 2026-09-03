pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.UPower
import qs.Components.common

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 54

    readonly property int segCount: 3
    readonly property real baseW: (root.width - (segCount - 1) * 4) / segCount
    readonly property real growAmount: 14

    Row {
        id: profileRow
        property int hoveredIndex: -1
        property int activeIndex: {
            if (PowerProfiles.profile === PowerProfile.PowerSaver)
                return 0;
            if (PowerProfiles.profile === PowerProfile.Balanced)
                return 1;
            if (PowerProfiles.profile === PowerProfile.Performance)
                return 2;
            return 1;
        }
        anchors.fill: parent
        spacing: 4
        Repeater {
            model: [
                {
                    "profile": PowerProfile.PowerSaver,
                    "label": "\udb80\udf2a"
                },
                {
                    "profile": PowerProfile.Balanced,
                    "label": "\uf24e"
                },
                {
                    "profile": PowerProfile.Performance,
                    "label": "\udb85\udcde"
                }
            ]
            delegate: PillSegment {
                id: seg
                required property var modelData
                required property int index
                readonly property bool isActive: profileRow.activeIndex === seg.index
                readonly property bool isHovered2: profileRow.hoveredIndex === seg.index
                readonly property bool isExpanded: seg.isActive || seg.isHovered2
                readonly property int expandedCount: (profileRow.activeIndex !== profileRow.hoveredIndex && profileRow.hoveredIndex !== -1) ? 2 : 1
                readonly property int shrinkingCount: root.segCount - seg.expandedCount
                readonly property real shrinkAmount: shrinkingCount > 0 ? (root.growAmount * seg.expandedCount) / shrinkingCount : 0
                height: 54
                width: seg.isExpanded ? root.baseW + root.growAmount : root.baseW - seg.shrinkAmount
                opacity: seg.modelData.profile === PowerProfile.Performance && !PowerProfiles.hasPerformanceProfile ? 0.35 : 1.0
                enabled: seg.modelData.profile !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile
                active: seg.isActive
                label: seg.modelData.label
                contentPixelSize: 24
                topLeftRadius: seg.index === 0 ? 22 : 6
                bottomLeftRadius: seg.index === 0 ? 22 : 6
                topRightRadius: seg.index === 2 ? 22 : 6
                bottomRightRadius: seg.index === 2 ? 22 : 6
                activeBorderWidth: 1
                inactiveBorderWidth: 1
                onIsHoveredChanged: profileRow.hoveredIndex = isHovered ? index : (profileRow.hoveredIndex === index ? -1 : profileRow.hoveredIndex)
                onClicked: PowerProfiles.profile = seg.modelData.profile
                Behavior on width {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
