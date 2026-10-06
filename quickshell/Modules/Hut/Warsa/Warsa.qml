pragma ComponentBehavior: Bound
import Ryu.Warsa
import QtQuick
import Ryu.Sqliter
import qs.Services.Theme
import qs.Components.common
import "." as LocalWarsa
import Ryu.Extraa

Item {
    id: root

    implicitWidth: calendarCard.width
    implicitHeight: calendarCard.height

    Warsa {
        id: calendar
        Component.onCompleted: calendar.setToday()
    }

    Card {
        id: calendarCard

        width: calendarContent.width + 40
        height: calendarContent.height + 32
        cardRadius: 20

        Behavior on width {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Column {
            id: calendarContent

            anchors.centerIn: parent
            spacing: 16

            Item {
                width: 280
                height: 40

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    text: calendar.monthName.charAt(0).toUpperCase() + calendar.monthName.slice(1) + " " + calendar.year
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Theme.onSurface
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    spacing: 6

                    MaterialIconButton {
                        width: 40
                        height: 40
                        type: MaterialIconButton.Tonal
                        shape: MaterialIconButton.Round
                        iconSize: 20
                        iconText: "<"
                        color: Theme.cardInner
                        iconColor: Theme.onSurface
                        enabled: !eventSheet.visible
                        onClicked: calendar.previousMonth()
                    }

                    MaterialIconButton {
                        width: 40
                        height: 40
                        type: MaterialIconButton.Tonal
                        shape: MaterialIconButton.Round
                        iconSize: 20
                        iconText: ">"
                        color: Theme.cardInner
                        iconColor: Theme.onSurface
                        enabled: !eventSheet.visible
                        onClicked: calendar.nextMonth()
                    }
                }
            }

            Grid {
                width: 280
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                columnSpacing: 3
                rowSpacing: 3

                Repeater {
                    model: ["Ai", "So", "Ma", "Bu", "Bi", "Su", "Sa"]

                    delegate: Item {
                        id: dayHeaderItem

                        required property string modelData
                        required property int index

                        width: 38
                        height: 24

                        Text {
                            anchors.centerIn: parent
                            text: dayHeaderItem.modelData
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: Theme.textSecondary
                        }
                    }
                }
            }

            Grid {
                id: daysGrid

                property var cachedModel: []
                property int activeIndex: -1

                function updateModel() {
                    const days = calendar.getMonthDays(calendar.month);
                    const firstDay = calendar.getFirstDayOfMonth(calendar.month);
                    const result = [];
                    for (let i = 0; i < firstDay; i++)
                        result.push({
                            day: 0,
                            isToday: false,
                            isSaturday: false,
                            hasEvent: false
                        });
                    for (let j = 0; j < days.length; j++) {
                        const d = days[j];
                        const event = EventsService.eventsGet(calendar.month, d.day);
                        const hasEvent = Object.keys(event).length > 0;
                        d.hasEvent = hasEvent;
                        d.eventData = hasEvent ? event : null;
                        result.push(d);
                    }
                    daysGrid.cachedModel = result;
                }

                width: 280
                anchors.horizontalCenter: parent.horizontalCenter
                columns: 7
                columnSpacing: 3
                rowSpacing: 3

                Component.onCompleted: daysGrid.updateModel()

                Connections {
                    target: calendar
                    function onMonthChanged() {
                        daysGrid.updateModel();
                    }
                }

                Repeater {
                    model: daysGrid.cachedModel

                    delegate: Rectangle {
                        id: dayRect

                        required property var modelData
                        required property int index

                        opacity: (eventSheet.visible && dayRect.index === daysGrid.activeIndex) ? 0 : 1
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }
                        width: 38
                        height: 38
                        radius: dayMouse.containsMouse ? 19 : 10
                        color: {
                            if (dayRect.modelData.day === 0)
                                return "transparent";
                            let base = Theme.cardInner;
                            if (dayRect.modelData.isToday)
                                base = Theme.primaryColor;
                            else if (dayRect.modelData.hasEvent)
                                base = Theme.tertiaryContainer;
                            else if (dayRect.modelData.isSaturday)
                                base = Theme.errorContainer;
                            return dayMouse.containsMouse ? Theme.hover(base) : base;
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: dayRect.modelData.day === 0 ? "" : dayRect.modelData.day
                            font.pixelSize: 12
                            font.weight: dayRect.modelData.isToday ? Font.Medium : Font.Normal
                            color: {
                                if (dayRect.modelData.isToday)
                                    return Theme.onPrimary;
                                if (dayRect.modelData.hasEvent)
                                    return Theme.onTertiaryContainer;
                                if (dayRect.modelData.isSaturday)
                                    return Theme.onErrorContainer;
                                return Theme.onSurface;
                            }
                        }

                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            enabled: dayRect.modelData.day !== 0 && !eventSheet.visible
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                calendar.setDate(calendar.year, calendar.month, dayRect.modelData.day);
                                daysGrid.activeIndex = dayRect.index;
                                const pos = dayMouse.mapToItem(calendarCard, 0, 0);
                                eventSheet.openFor(calendar.month, dayRect.modelData.day, pos.x + dayMouse.width / 2, pos.y + dayMouse.height / 2);
                            }
                            onEntered: {
                                if (!dayRect.modelData.hasEvent || !dayRect.modelData.eventData)
                                    return;
                                eventPopup.title = dayRect.modelData.eventData.title || "Event";
                                eventPopup.description = dayRect.modelData.eventData.description || "";
                                const pos = dayMouse.mapToItem(root, 0, 0);
                                eventPopup.x = Math.min(Math.max(pos.x + (dayMouse.width - eventPopup.width) / 2, 8), root.width - eventPopup.width - 8);
                                eventPopup.y = pos.y - eventPopup.height - 8 < 0 ? pos.y + dayMouse.height + 8 : pos.y - eventPopup.height - 8;
                                eventPopup.visible = true;
                                eventPopup.opacity = 1;
                            }
                            onExited: {
                                eventPopup.visible = false;
                                eventPopup.opacity = 0;
                            }
                        }
                    }
                }
            }

            Item {
                width: 280
                height: 36

                Rectangle {
                    width: 90
                    height: 36
                    radius: 18
                    anchors.right: parent.right
                    color: todayMouse.containsMouse ? Theme.hover(Theme.cardInner) : Theme.cardInner
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Today"
                        font.pixelSize: 11
                        font.weight: Font.Normal
                        color: Theme.onSurface
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    MouseArea {
                        id: todayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: !eventSheet.visible
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calendar.setToday()
                    }
                }
            }
        }

        Rectangle {
            id: scrim

            anchors.fill: parent
            radius: calendarCard.cardRadius
            color: Theme.card
            opacity: eventSheet.visible ? 0.6 : 0
            visible: opacity > 0
            z: 10

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.InOutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: parent.visible
            }
        }

        LocalWarsa.EventSheet {
            id: eventSheet

            monthName: calendar.monthName.charAt(0).toUpperCase() + calendar.monthName.slice(1)
            anchors.centerIn: parent
            width: calendarCard.width - 32
            z: 11

            onDone: daysGrid.updateModel()
            onClosing: daysGrid.activeIndex = -1
            onCloseRequested: {}
        }
    }

    Rectangle {
        id: eventPopup

        property string title: ""
        property string description: ""

        visible: false
        width: 220
        height: popupText.height + 16
        radius: 16
        color: Theme.cardInner
        z: 1000
        opacity: 0

        Text {
            id: popupText
            anchors.centerIn: parent
            width: 200
            textFormat: Text.StyledText
            text: eventPopup.title + " . " + eventPopup.description
            font.pixelSize: 11
            font.weight: Font.Medium
            color: Theme.onSurface
            wrapMode: Text.WordWrap
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
