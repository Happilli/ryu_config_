pragma ComponentBehavior: Bound
import "./Callgorl/"
import "./ControlRoom/"
import "./Wset/"
import QtQuick
import qs.Services.Shapes
import qs.Services.Theme

Item {
    id: subRoot

    required property var popoutIcons
    required property int activePopout
    required property bool isPinned
    required property real parentWidth

    signal nestedHoverChanged(bool hovered)

    readonly property var popoutComponents: [null, controlRoomComp, wsetComp, callgorlComp]

    implicitWidth: parentWidth
    implicitHeight: nestedPopout.height

    onActivePopoutChanged: updatePosition()

    function updatePosition() {
        if (subRoot.activePopout > 0) {
            nestedPopout.lastActive = subRoot.activePopout;
            const c = subRoot.popoutIcons.find(p => {
                return p.id === subRoot.activePopout;
            });
            const tx = subRoot.parentWidth - c.w - c.xOff;
            if (!nestedPopout.hasOpenedOnce) {
                xBehavior.enabled = false;
                widthBehavior.enabled = false;
                nestedPopout.x = tx;
                nestedPopout.width = c.w;
                xBehavior.enabled = true;
                widthBehavior.enabled = true;
                nestedPopout.hasOpenedOnce = true;
            }
            nestedPopout.x = tx;
            nestedPopout.width = c.w;
            nestedPopout.height = c.h;
        } else {
            nestedPopout.height = 0;
        }
    }

    Component {
        id: controlRoomComp

        ControlRoom {}
    }

    Component {
        id: wsetComp

        Wset {}
    }

    Component {
        id: callgorlComp

        Callgorl {}
    }

    PopoutShape {
        id: nestedPopout

        property int lastActive: 1
        property bool isOpen: false
        property real targetW: 580
        property real targetH: 0
        property real targetX: 0
        property bool hasOpenedOnce: false
        property bool isAnimating: heightAnim.running || widthAnim.running || xAnim.running

        clip: true
        width: targetW
        height: targetH
        x: targetX
        alignment: 0
        radius: 15
        color: Theme.surfaceContainer
        visible: height > 1 || isAnimating
        onHeightChanged: {
            if (height > 0 && !isOpen && !heightAnim.running) {
                isOpen = true;
                hasOpenedOnce = true;
            }
            if (height === 0 && isOpen)
                isOpen = false;
        }

        HoverHandler {
            onHoveredChanged: subRoot.nestedHoverChanged(hovered)
        }

        Loader {
            id: popoutLoader

            anchors.fill: parent
            active: subRoot.isPinned && subRoot.activePopout > 0
            asynchronous: true
            sourceComponent: subRoot.activePopout > 0 ? subRoot.popoutComponents[subRoot.activePopout] : null
            opacity: item ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Behavior on width {
            id: widthBehavior

            NumberAnimation {
                id: widthAnim

                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on height {
            NumberAnimation {
                id: heightAnim

                duration: 300
                easing.type: Easing.InOutQuad
                onFinished: {
                    if (nestedPopout.height > 0) {
                        nestedPopout.isOpen = true;
                    } else {
                        nestedPopout.isOpen = false;
                    }
                }
            }
        }

        Behavior on x {
            id: xBehavior

            NumberAnimation {
                id: xAnim

                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }
}
