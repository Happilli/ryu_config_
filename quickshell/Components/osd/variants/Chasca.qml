pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    width: 120
    height: width * 1.42

    property real normalizedValue: 0

    property url spriteCache: Qt.resolvedUrl("../../../Assets/nightsoul/Chasca")

    FlameShader {
        anchors.centerIn: parent
        width: parent.width * 1.4
        anchors.horizontalCenterOffset: -15
        anchors.verticalCenterOffset: -25
        height: parent.height * 1.6
        z: -1
        running: root.visible
        source: Image {
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_EffColor_02.png"
        }
    }

    Image {
        anchors.fill: parent
        source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarBg.png"
        fillMode: Image.PreserveAspectFit
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * root.normalizedValue
        clip: true

        Image {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: root.width
            height: root.height
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarFill.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    Image {
        anchors.fill: parent
        source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarMask.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        anchors.fill: parent
        source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarBg02.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        anchors.fill: parent
        source: root.spriteCache + "/UI_NyxStateBar_Chasca_Mask_02.png"
        fillMode: Image.PreserveAspectFit
    }
}
