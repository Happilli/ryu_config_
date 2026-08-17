pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.Services.Theme
import qs.Services.Paths
import qs.Services.Shapes
import qs.utils

Rectangle {
    id: root
    required property var context
    signal animationDone

    property bool exiting: false

    color: Theme.backgroundColor

    Image {
        id: blurBg
        anchors.fill: parent
        source: "file://" + LockConfig.screenshotPath
        fillMode: Image.PreserveAspectCrop
        cache: false
        layer.enabled: true
    }

    MultiEffect {
        id: blurEffect
        anchors.fill: blurBg
        source: blurBg
        blurEnabled: true
        blur: 0.0
        blurMax: 32
        autoPaddingEnabled: false
    }

    Item {
        id: introContainer
        anchors.centerIn: parent
        width: 400
        height: childrenRect.height
        opacity: 0

        transform: Translate {
            id: introTranslate
            y: -60
        }

        Component.onCompleted: entrySequence.start()

        ParallelAnimation {
            id: entrySequence

            NumberAnimation {
                target: blurEffect
                property: "blur"
                to: 0.8
                duration: 900
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: introContainer
                property: "opacity"
                to: 1
                duration: 500
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: introTranslate
                property: "y"
                from: -60
                to: 0
                duration: 700
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: 400
                }
                NumberAnimation {
                    target: quoteLabel
                    property: "opacity"
                    to: 0.95
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
        }

        SequentialAnimation {
            id: exitSequence
            running: false

            PauseAnimation {
                duration: 180
            }

            ParallelAnimation {
                NumberAnimation {
                    target: introTranslate
                    property: "y"
                    to: -60
                    duration: 550
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: introContainer
                    property: "opacity"
                    to: 0
                    duration: 450
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: quoteLabel
                    property: "opacity"
                    to: 0
                    duration: 300
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: blurEffect
                    property: "blur"
                    to: 0.0
                    duration: 650
                    easing.type: Easing.InOutQuad
                }
            }

            ScriptAction {
                script: root.animationDone()
            }
        }

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 30

            Item {
                id: pfpItem
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                Layout.preferredHeight: 200

                Repeater {
                    model: passwordBox.text.length

                    delegate: Item {
                        id: kanjiChar
                        required property int index

                        readonly property real orbitRadius: 118 + (kanjiChar.index % 2) * 12
                        readonly property real baseAngle: kanjiChar.index * 360 / Math.max(passwordBox.text.length, 1)
                        readonly property real fontSize: kanjiChar.index % 2 === 0 ? 18 : 16

                        property real rotationOffset: 0

                        x: 100 + Math.cos((baseAngle + rotationOffset) * Math.PI / 180) * orbitRadius - 12
                        y: 100 + Math.sin((baseAngle + rotationOffset) * Math.PI / 180) * orbitRadius - 12
                        width: 24
                        height: 24
                        opacity: 0

                        Text {
                            anchors.centerIn: parent
                            text: {
                                const kanjis = ['雷', '龍', '火', '水', '風', '月', '星', '夢', '侍', '魂', '剣', '神', '虎', '鳳', '雲', '霊'];
                                return kanjis[kanjiChar.index % kanjis.length];
                            }
                            font.pointSize: kanjiChar.fontSize
                            color: Theme.primaryFixedDim
                            style: Text.Outline
                            styleColor: Theme.backgroundColor
                            opacity: kanjiChar.index % 2 === 0 ? 0.75 : 0.45
                        }

                        Component.onCompleted: opacity = 1

                        NumberAnimation on rotationOffset {
                            from: 0
                            to: kanjiChar.index % 2 === 0 ? 360 : -360
                            duration: 18000 + kanjiChar.index * 500
                            loops: Animation.Infinite
                            running: true
                            easing.type: Easing.Linear
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Rectangle {
                    id: pfpContainer
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"

                    ShapeCanvas {
                        id: pfpShape
                        anchors.fill: parent
                        roundedPolygon: root.context.showFailure ? GetMShapes.get(25) : GetMShapes.get(18)
                        instantMorph: root.context.showFailure
                        color: "transparent"
                        imageSource: "file://" + PathService.home + "/.cache/safalQuick/pfp.jpeg"
                        borderWidth: 2
                        borderColor: root.context.showFailure ? Theme.errorColor : Theme.primaryContainer

                        Behavior on borderColor {
                            ColorAnimation {
                                duration: root.context.showFailure ? 0 : 200
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "?"
                        font.pointSize: 64
                        font.weight: Font.Light
                        color: Theme.onPrimaryContainer
                        visible: !pfpShape.imageReady
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            passwordBox.forceActiveFocus();
                        }
                    }
                }
            }

            TextInput {
                id: passwordBox
                visible: false
                enabled: !root.context.unlockInProgress
                focus: true

                Component.onCompleted: {
                    forceActiveFocus();
                }

                onTextChanged: {
                    if (!root.exiting)
                        root.context.currentText = text;
                }

                onAccepted: root.context.tryUnlock()

                Connections {
                    target: root.context
                    function onShowFailureChanged() {
                        if (root.context.showFailure) {
                            passwordBox.text = "";
                            passwordBox.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }

    Text {
        id: quoteLabel
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 100
        }

        width: parent.width * 0.5
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap

        font.pointSize: 18
        font.italic: true
        color: Theme.primaryFixed
        opacity: 0

        property string lastNonEmptyText: "Do you love red panda?"
        property string liveText: passwordBox.text.length > 0 ? "hell yea!!" : "Do you love red panda?"

        onLiveTextChanged: {
            if (!root.exiting && passwordBox.text.length > 0)
                lastNonEmptyText = liveText;
        }

        text: root.exiting ? lastNonEmptyText : liveText

        Behavior on text {
            enabled: !root.exiting
            SequentialAnimation {
                NumberAnimation {
                    target: quoteLabel
                    property: "opacity"
                    to: 0
                    duration: 150
                }
                PropertyAction {
                    target: quoteLabel
                    property: "text"
                }
                NumberAnimation {
                    target: quoteLabel
                    property: "opacity"
                    to: 0.95
                    duration: 150
                }
            }
        }
    }
    Text {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 60
        }
        text: "Press Enter to unlock"
        font.pointSize: 11
        font.weight: Font.Light
        color: Theme.primaryFixedDim
        opacity: passwordBox.text.length > 0 ? 0.7 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }
    Connections {
        target: root.context
        function onUnlocked() {
            root.exiting = true;
            exitSequence.start();
        }
    }
}
