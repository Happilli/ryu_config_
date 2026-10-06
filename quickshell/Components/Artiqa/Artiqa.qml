pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import Ryu.Drawness
import Ryu.Extraa
import "./tools/"
import qs.Components.common

Item {
    id: artiqa

    property bool active: false
    property var currentTool: pencilTool

    visible: active

    property var pencilTool: PencilTool {
        id: pencilTool
        canvas: drawCanvas
    }

    property var jiggleTool: JiggleTool {
        id: jiggleTool
        canvas: drawCanvas
        jiggleLayer: jiggleLayer
    }

    readonly property bool isJiggleMode: artiqa.currentTool === jiggleTool

    onActiveChanged: {
        if (!active) {
            if (isJiggleMode) {
                currentTool = pencilTool;
                jiggleTool.deactivate();
            }
            drawCanvas.clear();
        }
    }

    Drawness {
        id: drawCanvas
        anchors.fill: parent
        drawColor: colorSection.currentColor
        brushSize: sizeSection.currentSize
    }

    JiggleLayer {
        id: jiggleLayer
        anchors.fill: parent
        z: 1
    }

    MouseArea {
        anchors.fill: parent
        z: 2
        hoverEnabled: true
        cursorShape: artiqa.isJiggleMode ? Qt.OpenHandCursor : (containsMouse ? Qt.CrossCursor : Qt.ArrowCursor)
        onPressed: mouse => artiqa.currentTool?.handlePress(mouse)
        onPositionChanged: mouse => artiqa.currentTool?.handleMove(mouse)
        onReleased: mouse => artiqa.currentTool?.handleRelease(mouse)
    }

    Card {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        z: 10
        visible: artiqa.active
        width: 620
        height: 80
        cardRadius: 16
        surface: Theme.surfaceContainer

        Row {
            anchors.centerIn: parent
            spacing: 12

            ColorSection {
                id: colorSection
                currentColor: Theme.primaryColor
                opacity: artiqa.isJiggleMode ? 0.3 : 1.0
                enabled: !artiqa.isJiggleMode
                onColorSelected: c => colorSection.currentColor = c
            }

            SizeSection {
                id: sizeSection
                currentSize: 2.0
                opacity: artiqa.isJiggleMode ? 0.3 : 1.0
                enabled: !artiqa.isJiggleMode
                onSizeSelected: size => {
                    sizeSection.currentSize = size;
                    sizeDropdownOverlay.visible = false;
                }
                onDropdownToggled: (open, gx, gy) => {
                    if (open) {
                        sizeDropdownOverlay.anchorX = gx;
                        sizeDropdownOverlay.anchorY = gy;
                        sizeDropdownOverlay.visible = true;
                    }
                }
            }

            ActionsSection {
                canUndo: drawCanvas.canUndo
                canRedo: drawCanvas.canRedo
                opacity: artiqa.isJiggleMode ? 0.3 : 1.0
                enabled: !artiqa.isJiggleMode
                onUndoClicked: drawCanvas.undo()
                onRedoClicked: drawCanvas.redo()
                onClearClicked: drawCanvas.clear()
            }

            MaterialIconButton {
                id: jiggleBtn
                width: 52
                height: 52
                type: MaterialIconButton.Outlined
                sizeStyle: MaterialIconButton.Medium
                shape: artiqa.isJiggleMode ? MaterialIconButton.Round : MaterialIconButton.Square
                iconSize: 22
                iconText: "\ued71"
                color: artiqa.isJiggleMode ? Theme.primaryContainer : Theme.surfaceContainerHigh
                iconColor: artiqa.isJiggleMode ? Theme.onPrimaryContainer : Theme.onSurface
                borderColor: artiqa.isJiggleMode ? Theme.primaryColor : Theme.outlineVariant
                borderWidth: 1
                onClicked: {
                    if (artiqa.isJiggleMode) {
                        artiqa.currentTool = artiqa.pencilTool;
                        jiggleTool.deactivate();
                    } else {
                        artiqa.currentTool = artiqa.jiggleTool;
                        jiggleTool.activate();
                    }
                }
            }
        }
    }

    Card {
        id: sizeDropdownOverlay

        property real anchorX: 0
        property real anchorY: 0

        visible: false
        z: 20
        x: anchorX - width / 2
        y: anchorY - height - 8
        width: 84
        height: sizeDropdownColumn.implicitHeight + 16
        surface: Theme.surfaceContainer

        opacity: visible ? 1.0 : 0.0
        scale: visible ? 1.0 : 0.95

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }

        Column {
            id: sizeDropdownColumn
            anchors.centerIn: parent
            spacing: 6

            Repeater {
                model: [2, 4, 6, 8, 10]

                delegate: MaterialIconButton {
                    id: sizeItem
                    required property int modelData
                    readonly property bool selected: sizeSection.currentSize === sizeItem.modelData

                    width: 68
                    height: 36
                    type: MaterialIconButton.Filled
                    shape: sizeItem.selected ? MaterialIconButton.Round : MaterialIconButton.Square
                    iconSize: 18
                    iconText: String(sizeItem.modelData)
                    color: sizeItem.selected ? Theme.primaryContainer : Theme.surfaceContainerHigh
                    iconColor: sizeItem.selected ? Theme.onPrimaryContainer : Theme.onSurface
                    onClicked: {
                        sizeSection.currentSize = sizeItem.modelData;
                        sizeDropdownOverlay.visible = false;
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 15
        visible: sizeDropdownOverlay.visible
        onClicked: sizeDropdownOverlay.visible = false
    }
}
