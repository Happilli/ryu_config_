pragma ComponentBehavior: Bound
import QtQuick
import qs.Configuration.Cleave

Item {
    id: root

    required property var parentScreen
    // readonly property real interactiveHeight: mainBar.height + subPanel.height
    readonly property real interactiveHeight: mainBar.height + subPanel.height
    readonly property alias visibleBarHeight: mainBar.barHeight
    property bool isHovered: false
    property bool isPinned: false
    property int activePopout: 0
    property var hoveredWayland: null
    property bool iconRowHovered: false
    property bool bridgeHovered: false
    property bool nestedHovered: false

    readonly property var popoutIcons: [
        {
            "id": 1,
            "icon": "\udb81\udfea",
            "xOff": 75,
            "w": 510,
            "h": 180
        },
        {
            "id": 2,
            "icon": "\uefa7",
            "xOff": 200,
            "w": 320,
            "h": 200
        },
        {
            "id": 3,
            "icon": "\udb81\udce0",
            "xOff": 100,
            "w": 450,
            "h": 110
        }
    ]

    function checkClose() {
        closeTimer.restart();
    }

    implicitWidth: 1400
    implicitHeight: mainBar.height + subPanel.height + cleaveLoader.height
    width: implicitWidth
    height: implicitHeight

    Timer {
        id: closeTimer

        interval: 250
        repeat: false
        onTriggered: {
            if (!root.iconRowHovered && !root.bridgeHovered && !root.nestedHovered)
                root.activePopout = 0;
        }
    }

    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        hoverEnabled: true
        onEntered: root.isHovered = true
    }

    MainBar {
        id: mainBar

        parentScreen: root.parentScreen
        isHovered: root.isHovered
        isPinned: root.isPinned
        activePopout: root.activePopout
        popoutIcons: root.popoutIcons

        onPinToggled: root.isPinned = !root.isPinned
        onIconHovered: id => root.activePopout = id
        onIconRowHoverChanged: hovered => {
            root.iconRowHovered = hovered;
            if (!hovered)
                root.checkClose();
        }
        onBridgeHoverChanged: hovered => {
            root.bridgeHovered = hovered;
            if (!hovered)
                root.checkClose();
        }
    }

    Loader {
        id: cleaveLoader

        anchors.top: mainBar.bottom
        anchors.topMargin: -1
        anchors.horizontalCenter: parent.horizontalCenter
        active: CleaveConfig.isActive && root.isPinned
        asynchronous: true
        source: "CleaveViz/CleaveViz.qml"
        height: active ? 50 : 0
        onLoaded: item.targetWidth = 1250
    }

    SubPanelManager {
        id: subPanel

        anchors.top: mainBar.bottom
        parentWidth: root.width
        popoutIcons: root.popoutIcons
        activePopout: root.activePopout
        isPinned: root.isPinned

        onNestedHoverChanged: hovered => {
            root.nestedHovered = hovered;
            if (!hovered)
                root.checkClose();
        }
    }

    HoverHandler {
        onHoveredChanged: {
            root.isHovered = hovered;
            if (!hovered)
                root.hoveredWayland = null;
        }
    }
}
