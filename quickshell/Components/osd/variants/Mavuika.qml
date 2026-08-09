pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root
    width: 140
    height: width * 1.8

    property real normalizedValue: 0
    property int currentStep: Math.round(normalizedValue * 10)

    property url spriteCache: Qt.resolvedUrl("../../../Assets/nightsoul/Mavuika")

    readonly property var positions: ({
            "UI_NyxStateBar_Mavuika_Scale00.png": {
                x: 110,
                y: 159,
                r: -8
            },
            "UI_NyxStateBar_Mavuika_Scale01.png": {
                x: 118,
                y: 247,
                r: -6
            },
            "UI_NyxStateBar_Mavuika_Scale02.png": {
                x: 103,
                y: 324,
                r: -5
            },
            "UI_NyxStateBar_Mavuika_Scale03.png": {
                x: 121,
                y: 395,
                r: -5
            },
            "UI_NyxStateBar_Mavuika_Scale04.png": {
                x: 160,
                y: 459,
                r: -5
            },
            "UI_NyxStateBar_Mavuika_Scale05.png": {
                x: 171,
                y: 492,
                r: -5
            },
            "UI_NyxStateBar_Mavuika_Scale06.png": {
                x: 206,
                y: 521,
                r: -5
            },
            "UI_NyxStateBar_Mavuika_Scale07.png": {
                x: 255,
                y: 556,
                r: -2
            },
            "UI_NyxStateBar_Mavuika_Scale08.png": {
                x: 318,
                y: 564,
                r: -3
            },
            "UI_NyxStateBar_Mavuika_Scale09.png": {
                x: 360,
                y: 618,
                r: 0
            }
        })

    Item {
        id: canvas
        width: 512
        height: 660
        transformOrigin: Item.TopLeft
        scale: root.width / 512
        x: 0
        y: -40

        Item {
            anchors.fill: barBg
            z: 1

            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.effect: FlameShader {
                    running: root.visible
                }

                Image {
                    anchors.fill: parent
                    source: root.spriteCache + "/UI_NyxStateBar_Mavuika_EffColorShadow.png"
                }
                Image {
                    anchors.fill: parent
                    source: root.spriteCache + "/UI_NyxStateBar_Mavuika_EffColor.png"
                }
                Image {
                    anchors.fill: parent
                    source: root.spriteCache + "/UI_NyxStateBar_Mavuika_EffColor02.png"
                }
            }
        }

        Image {
            id: barBg
            x: 0
            y: 0
            width: 512
            height: 660
            source: root.spriteCache + "/UI_NyxStateBar_Mavuika_BarBg.png"
            z: 2
        }

        Repeater {
            model: 10

            Item {
                id: chip
                required property int index

                property string fname: "UI_NyxStateBar_Mavuika_Scale0" + chip.index + ".png"
                property var p: root.positions[chip.fname] ?? {
                    x: 0,
                    y: 0,
                    r: 0
                }

                x: chip.p.x
                y: chip.p.y
                rotation: chip.p.r
                z: 4
                visible: chip.index >= (10 - root.currentStep)
                width: img.implicitWidth
                height: img.implicitHeight

                Image {
                    id: img
                    source: root.spriteCache + "/" + chip.fname
                    fillMode: Image.Pad
                }
            }
        }
    }
}
