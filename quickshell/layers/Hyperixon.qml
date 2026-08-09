pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components.osd
import qs.Components.Blend
import qs.Modules.Hut
import qs.Modules.TopJesus
import qs.Services.Theme
import qs.utils

Scope {
    Variants {
        model: Quickshell.screens

        Scope {
            id: screenScope
            required property var modelData

            WlrLayershell {
                id: hyperixonLayer
                screen: screenScope.modelData
                layer: WlrLayer.Top
                keyboardFocus: WlrKeyboardFocus.OnDemand
                namespace: "quickshell-hyperixon"
                visible: true
                exclusiveZone: -1
                color: "transparent"

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                Item {
                    id: hyperixonContent
                    anchors.fill: parent

                    EdgeBlend {
                        id: edgeBlend
                        anchors.fill: parent
                        z: -1
                        active: hutRef.isHovered || hutRef.isPinned
                        fillColor: Theme.surfaceContainer
                        rectA: {
                            const p = topJesusRef.mapToItem(hyperixonContent, 0, 0);
                            const probeWidth = 120;
                            return Qt.rect(p.x + topJesusRef.width - probeWidth, p.y, probeWidth, topJesusRef.visibleBarHeight);
                        }
                        rectB: {
                            const p = hutRef.mapToItem(hyperixonContent, 0, 0);
                            return Qt.rect(p.x, p.y, hutRef.width, hutRef.height);
                        }
                    }

                    TopJesus {
                        id: topJesusRef
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        parentScreen: hyperixonLayer.screen
                    }

                    Hut {
                        id: hutRef
                        barColor: Theme.surfaceContainer
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                        }
                    }

                    Loader {
                        id: osdWindow
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: 20
                        anchors.topMargin: 20
                        active: OsdConfig.isVisible
                        sourceComponent: Component {
                            Osd {}
                        }
                    }
                }

                WlrLayershell {
                    id: pinLayer
                    screen: screenScope.modelData
                    layer: WlrLayer.Top
                    namespace: "quickshell-hyperixon-pin"
                    visible: topJesusRef.isPinned
                    anchors.top: true
                    implicitWidth: 0
                    implicitHeight: 0
                    exclusiveZone: 40
                }

                readonly property rect blendBounds: {
                    if (!edgeBlend.visible) {
                        return Qt.rect(0, 0, 0, 0);
                    }
                    const smooth = edgeBlend.smoothness;
                    const rA = edgeBlend.rectA;
                    const rB = edgeBlend.rectB;

                    const minX = Math.min(rA.x, rB.x) - smooth;
                    const minY = Math.min(rA.y, rB.y) - smooth;
                    const maxX = Math.max(rA.x + rA.width, rB.x + rB.width) + smooth;
                    const maxY = Math.max(rA.y + rA.height, rB.y + rB.height) + smooth;

                    return Qt.rect(minX, minY, maxX - minX, maxY - minY);
                }

                mask: Region {
                    Region {
                        x: (hyperixonLayer.width / 2) - (topJesusRef.width / 2)
                        y: 0
                        width: topJesusRef.width
                        height: (topJesusRef.isHovered || topJesusRef.isPinned) ? topJesusRef.interactiveHeight : 1
                    }
                    Region {
                        x: hyperixonLayer.width - hutRef.maskWidth
                        y: 0
                        width: hutRef.maskWidth
                        height: hyperixonLayer.height
                    }
                    Region {
                        x: hyperixonLayer.blendBounds.x
                        y: hyperixonLayer.blendBounds.y
                        width: hyperixonLayer.blendBounds.width
                        height: hyperixonLayer.blendBounds.height
                    }
                }
            }
        }
    }
}
