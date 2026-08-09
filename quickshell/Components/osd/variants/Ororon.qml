pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    width: 180
    height: 300

    property real normalizedValue: 0
    property url spriteCache: Qt.resolvedUrl("../../../Assets/nightsoul/Ororon")

    Item {
        id: barContainer
        anchors.centerIn: parent
        width: childrenRect.width
        height: childrenRect.height

        Item {
            id: barContent
            width: barBg.implicitWidth
            height: barBg.implicitHeight

            FlameShader {
                width: parent.width
                height: parent.height
                z: -1
                running: root.visible
                source: effColorImg
            }

            Image {
                id: effColorImg
                source: root.spriteCache + "/UI_NyxStateBar_Olorun_EffColor.png"
                visible: false
            }

            Image {
                id: barMask
                width: parent.width
                height: parent.height
                source: root.spriteCache + "/UI_NyxStateBar_Olorun_BarMask.png"
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: barBg
                width: implicitWidth
                height: implicitHeight
                source: root.spriteCache + "/UI_NyxStateBar_Olorun_BarBg.png"
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
                    width: barBg.width
                    height: barBg.height
                    source: root.spriteCache + "/UI_NyxStateBar_Olorun_BarFill.png"
                    fillMode: Image.PreserveAspectFit
                }
            }
        }
    }
}
