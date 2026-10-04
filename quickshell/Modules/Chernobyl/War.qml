pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Kraken
import qs.Services.Theme
import qs.Services.Paths
import qs.Components.common

Item {
    id: root

    property var chernobylRoot: null

    property string warFile: PathService.home + "/.cache/safalQuick/todaywarpick.json"
    property var war: ({})
    property bool loaded: false
    signal warLoaded

    Kraken {
        id: warReader
        filePath: root.warFile
        watchChanges: true

        onDataLoaded: {
            root.war = warReader.data;
            root.loaded = true;
            root.warLoaded();
        }
    }

    implicitWidth: 400
    implicitHeight: mainCol.implicitHeight

    Column {
        id: mainCol
        width: parent.width
        topPadding: 20
        bottomPadding: 20
        leftPadding: 20
        rightPadding: 20
        spacing: 0

        Row {
            width: parent.width - parent.leftPadding - parent.rightPadding
            spacing: 8

            Column {
                spacing: 4
                width: parent.width - dateChip.width - 8

                Text {
                    text: "Daily Coding War"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.letterSpacing: 1.1
                    color: Theme.onSurface
                }

                Text {
                    text: "Today's challenge"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: Theme.onSurface
                }
            }

            Card {
                id: dateChip
                height: 26
                width: dateText.width + 20
                cardRadius: 8
                surface: Theme.surfaceContainerLow
                borderColor: Theme.outlineVariant
                borderWidth: 1
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: dateText
                    anchors.centerIn: parent
                    text: root.war.date || Qt.formatDate(new Date(), "MMM d, yyyy")
                    font.pixelSize: 11
                    color: Theme.onSurface
                }
            }
        }

        Item {
            width: 1
            height: 16
        }

        Card {
            id: challengeCard
            width: parent.width - parent.leftPadding - parent.rightPadding
            height: cardContent.implicitHeight + 32
            cardRadius: 12
            surface: Theme.surfaceContainerLow
            borderColor: Theme.outlineVariant
            borderWidth: 1

            Column {
                id: cardContent
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 16
                }
                spacing: 10

                Text {
                    text: root.war.challenge?.title || (root.loaded ? "No challenge today" : "Loading...")
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Theme.onSurface
                    width: parent.width
                    wrapMode: Text.Wrap
                    lineHeight: 1.35
                }

                Text {
                    text: root.war.challenge?.description || ""
                    font.pixelSize: 12
                    color: Theme.onSurface
                    width: parent.width
                    wrapMode: Text.WordWrap
                    lineHeight: 1.5
                    visible: text.length > 0
                }

                Row {
                    spacing: 8
                    topPadding: 2

                    Rectangle {
                        height: 24
                        width: diffLabel.width + 16
                        radius: 6
                        color: Theme.tertiaryContainer
                        visible: root.war.challenge?.difficulty !== undefined

                        Text {
                            id: diffLabel
                            anchors.centerIn: parent
                            text: root.war.challenge?.difficulty || ""
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Theme.onTertiaryContainer
                        }
                    }

                    Rectangle {
                        height: 24
                        width: langLabel.width + 16
                        radius: 6
                        color: Theme.secondaryContainer
                        visible: root.war.language !== undefined

                        Text {
                            id: langLabel
                            anchors.centerIn: parent
                            text: root.war.language || ""
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Theme.onSecondaryContainer
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: warReader.reload()
}
