pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Extraa
import qs.Services.Theme
import qs.Components.common
import qs.utils

Item {
    id: root

    readonly property var configs: ({
            "dancer": ToggleConfigs.dancer,
            "omnitrix": ToggleConfigs.omnitrix,
            "paimonclock": PaimonClockConfig
        })

    readonly property var buttonModel: [
        {
            "icon": "\udb85\uddcf",
            "service": "dancer"
        },
        {
            "icon": "\udb81\udeb1",
            "service": "omnitrix"
        },
        {
            "icon": "\ue641",
            "service": "paimonclock"
        }
    ]

    readonly property var activeStates: [ToggleConfigs.dancer.isActive, ToggleConfigs.omnitrix.isActive, PaimonClockConfig.isActive]

    readonly property var activeIndices: {
        const out = [];
        for (let i = 0; i < root.activeStates.length; i++) {
            if (root.activeStates[i])
                out.push(i);
        }
        return out;
    }

    function toggle(service) {
        const config = root.configs[service];
        if (!config)
            return;
        config.toggle();
    }

    ThemedButtonGroup {
        id: group
        anchors.centerIn: parent
        sizeStyle: MaterialButtonGroup.Medium
        selectionMode: MaterialButtonGroup.Multiple
        icons: root.buttonModel.map(b => b.icon)
        checkedIndices: root.activeIndices
        onClicked: index => root.toggle(root.buttonModel[index].service)
    }
}
