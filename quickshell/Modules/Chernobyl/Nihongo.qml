pragma ComponentBehavior: Bound
import QtQuick
import Ryu.Sqliter
import qs.Services.Theme
import qs.Components.common

Item {
    id: root

    property var chernobylRoot: null

    property string currentTab: "Hiragana"
    readonly property var tabs: ["Hiragana", "Katakana", "Kanji"]

    CharacterModel {
        id: charModel
        category: root.currentTab
        pageSize: 60
    }

    onCurrentTabChanged: charModel.category = root.currentTab

    implicitWidth: 480
    implicitHeight: 800

    SlidingTabBar {
        id: tabBar
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 12
        }
        tabs: root.tabs
        currentIndex: root.tabs.indexOf(root.currentTab)
        onTabSelected: function (index) {
            root.currentTab = root.tabs[index];
        }
    }

    Text {
        anchors.centerIn: gridView
        visible: charModel.count === 0
        text: "No entries for " + root.currentTab
        font.pixelSize: 13
        color: Theme.onSurface
    }

    GridView {
        id: gridView
        cellWidth: width / 5
        cellHeight: 95
        clip: true
        model: charModel
        boundsBehavior: Flickable.DragAndOvershootBounds
        interactive: true

        cacheBuffer: 200
        reuseItems: true

        anchors {
            top: tabBar.bottom
            topMargin: 10
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            leftMargin: 12
            rightMargin: 12
            bottomMargin: 12
        }

        delegate: Item {
            id: gridItem

            required property string kanji
            required property string meaning

            width: GridView.view.cellWidth
            height: GridView.view.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                color: Theme.card
                radius: 10

                Column {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gridItem.kanji
                        color: Theme.onSurface
                        font.pixelSize: 38
                        font.weight: Font.Medium
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gridItem.meaning
                        color: Theme.textSecondary
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
