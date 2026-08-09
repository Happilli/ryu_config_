pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    width: 150
    height: 450
    y: -120

    property real normalizedValue: 0
    property url spriteCache: Qt.resolvedUrl("../../../Assets/nightsoul/Skirk")
    readonly property int zBarBg: 1
    readonly property int zBarFillOutline: 2
    readonly property int zBarFill: 3
    readonly property int zBarFillLight: -10
    readonly property int zBarShadow: -1
    readonly property int zBarEffMask: 6
    readonly property int zDots: 7

    readonly property var dotModel: [
        {
            x: 2,
            y: 288,
            z: root.zDots,
            threshold: 0.25,
            lightSuffix: ""
        },
        {
            x: -15,
            y: 190,
            z: root.zDots + 1,
            threshold: 0.50,
            lightSuffix: ""
        },
        {
            x: 34,
            y: 97,
            z: root.zDots + 2,
            threshold: 0.75,
            lightSuffix: "02"
        }
    ]

    FlameShader {
        x: 40
        y: 150
        width: 48
        height: 140
        z: root.zBarFillLight
        running: root.visible
        source: Image {
            source: root.spriteCache + "/UI_NyxStateBar_SKK_BarFill_Light.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    Image {
        id: barBg
        x: 26
        y: 150
        width: 80
        source: root.spriteCache + "/UI_NyxStateBar_SKK_BarBg.png"
        fillMode: Image.PreserveAspectFit
        z: root.zBarBg
    }

    Item {
        id: barClipContainer
        x: 23
        anchors.bottom: barBg.bottom
        width: 80
        height: 140
        clip: true
        z: root.zBarFillOutline

        Item {
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.height * root.normalizedValue

            Image {
                anchors.bottom: parent.bottom
                width: barClipContainer.width
                source: root.spriteCache + "/UI_NyxStateBar_SKK_BarFill.png"
                fillMode: Image.PreserveAspectFit
            }
            Image {
                anchors.bottom: parent.bottom
                x: 16
                width: 48
                source: root.spriteCache + "/UI_NyxStateBar_SKK_BarFill_Outline.png"
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    Item {
        x: -11
        anchors.bottom: barBg.bottom
        width: 150
        clip: true
        height: 150 * root.normalizedValue
        z: root.zBarEffMask

        Image {
            anchors.bottom: parent.bottom
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_BarEff_Mask.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    component Dot: Item {
        id: dot

        required property real dotX
        required property real dotY
        required property int dotZ
        required property real threshold
        required property string lightSuffix

        readonly property bool active: root.normalizedValue >= dot.threshold

        x: dot.dotX
        y: dot.dotY
        width: 35
        height: 35
        z: dot.dotZ

        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg02.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg.png"
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotBg_Light.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot.active ? 1 : 0.3
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.centerIn: parent
            width: parent.width
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotFill.png"
            fillMode: Image.PreserveAspectFit
            opacity: dot.active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Image {
            anchors.centerIn: parent
            width: parent.width * 1.5
            source: root.spriteCache + "/UI_NyxStateBar_SKK_DotFill_Light" + dot.lightSuffix + ".png"
            fillMode: Image.PreserveAspectFit
            opacity: dot.active ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
    }

    Repeater {
        model: root.dotModel

        delegate: Dot {
            required property var modelData
            dotX: modelData.x
            dotY: modelData.y
            dotZ: modelData.z
            threshold: modelData.threshold
            lightSuffix: modelData.lightSuffix
        }
    }
}
