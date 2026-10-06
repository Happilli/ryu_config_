pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.UPower
import Ryu.Extraa
import qs.Services.Theme
import qs.Components.common

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 56

    readonly property var profiles: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
    readonly property int activeIndex: Math.max(0, root.profiles.indexOf(PowerProfiles.profile))
    ThemedButtonGroup {
        id: group
        anchors.fill: parent
        fillWidth: true
        sizeStyle: MaterialButtonGroup.Medium
        selectionMode: MaterialButtonGroup.Single
        icons: ["\udb80\udf2a", "\uf24e", "\udb85\udcde"]
        currentIndex: root.activeIndex
        onToggled: (index, on) => {
            if (root.profiles[index] === PowerProfile.Performance && !PowerProfiles.hasPerformanceProfile) {
                group.setChecked(root.activeIndex, true);
                return;
            }
            PowerProfiles.profile = root.profiles[index];
        }
    }
}
