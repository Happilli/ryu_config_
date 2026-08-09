pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.utils

Item {
    id: root
    clip: true

    readonly property string assetBase: Qt.resolvedUrl("../../Assets/paimonclock/").toString()

    x: PaimonClockConfig.clockX
    y: PaimonClockConfig.clockY

    width: root.dataLoaded ? clockDial.implicitWidth * clockDial.scale : 0
    height: root.dataLoaded ? clockDial.implicitHeight * clockDial.scale : 0

    Behavior on x {
        NumberAnimation {
            duration: 800
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on y {
        NumberAnimation {
            duration: 800
            easing.type: Easing.InOutQuad
        }
    }

    readonly property var spriteData: ({
            "UI_Clock_Circle.png": {
                x: 194.34975460082092,
                y: 194.2438886121093,
                scale: 0.3
            },
            "UI_Clock_Dial_NoTag.png": {
                x: 0,
                y: 0,
                scale: 0.4
            },
            "UI_Clock_HourHand.png": {
                x: 190.1150108328518,
                y: 144.32800529616134,
                scale: 0.3
            },
            "UI_ClockIcon_Dusk.png": {
                x: 311.8812895520598,
                y: 187.13721382624544,
                scale: 0.4
            },
            "UI_ClockIcon_Morning.png": {
                x: 51.58378545471112,
                y: 182.51512625612332,
                scale: 0.4
            },
            "UI_ClockIcon_Night.png": {
                x: 180.50355685179056,
                y: 309.3298132812154,
                scale: 0.4
            },
            "UI_ClockIcon_Noon.png": {
                x: 179.62513931921922,
                y: 52.37634370962826,
                scale: 0.4
            },
            "UI_Clock_MinuteHand.png": {
                x: 194.81012012526458,
                y: 209.3969975749382,
                scale: 0.3
            },
            "UI_Img_Horoscope03.png": {
                x: 151.97310918401502,
                y: 128.39730794723403,
                scale: 0.3
            },
            "UI_Img_Horoscope04.png": {
                x: 127.83710956071218,
                y: 156.71717651705836,
                scale: 0.3
            },
            "UI_Img_Horoscope05.png": {
                x: 220.25737950355347,
                y: 225.1942831117184,
                scale: 0.3
            },
            "UI_Img_Horoscope06.png": {
                x: 187.98889922928606,
                y: 187.0747844393042,
                scale: 0.3
            }
        })

    readonly property real horoscopeX: 124.45002448875334
    readonly property real horoscopeY: 125.85402613776864
    readonly property real horoscopeSize: 159.4725552479834
    readonly property bool dataLoaded: true

    property int currentHour: clock.hours
    property int currentMinute: clock.minutes
    property int currentSecond: clock.seconds

    function sp(name) {
        return root.spriteData[name] || null;
    }

    function asset(name) {
        return root.assetBase + name;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Component.onCompleted: {
        PaimonClockConfig.clockWidth = root.width;
        PaimonClockConfig.clockHeight = root.height;
    }

    Item {
        id: contentItem
        visible: root.dataLoaded

        ClippingRectangle {
            x: root.horoscopeX
            y: root.horoscopeY
            width: root.horoscopeSize
            height: root.horoscopeSize
            radius: root.horoscopeSize / 2

            Item {
                x: -root.horoscopeX
                y: -root.horoscopeY

                Image {
                    id: horoscopeBg
                    x: root.horoscopeX + root.horoscopeSize / 2 - width / 2
                    y: root.horoscopeY + root.horoscopeSize / 2 - height / 2
                    width: root.horoscopeSize * 1.5
                    height: root.horoscopeSize * 1.5
                    source: root.asset("UI_Img_HoroscopeBg.png")
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    z: -1
                }

                Image {
                    id: horoscope06
                    x: root.sp("UI_Img_Horoscope06.png") ? root.sp("UI_Img_Horoscope06.png").x : 0
                    y: root.sp("UI_Img_Horoscope06.png") ? root.sp("UI_Img_Horoscope06.png").y : 0
                    source: root.asset("UI_Img_Horoscope06.png")
                    scale: root.sp("UI_Img_Horoscope06.png") ? root.sp("UI_Img_Horoscope06.png").scale : 0.3
                    transformOrigin: Item.TopLeft
                    smooth: true
                    transform: Rotation {
                        origin.x: horoscope06.width * horoscope06.scale / 2
                        origin.y: horoscope06.height * horoscope06.scale / 2
                        angle: -(root.currentSecond * 12) % 360
                        Behavior on angle {
                            RotationAnimation {
                                duration: 1000
                                direction: RotationAnimation.Counterclockwise
                            }
                        }
                    }
                }

                Image {
                    id: horoscope03
                    x: root.sp("UI_Img_Horoscope03.png") ? root.sp("UI_Img_Horoscope03.png").x : 0
                    y: root.sp("UI_Img_Horoscope03.png") ? root.sp("UI_Img_Horoscope03.png").y : 0
                    source: root.asset("UI_Img_Horoscope03.png")
                    scale: root.sp("UI_Img_Horoscope03.png") ? root.sp("UI_Img_Horoscope03.png").scale : 0.3
                    transformOrigin: Item.TopLeft
                    smooth: true
                    transform: Rotation {
                        origin.x: horoscope03.width * horoscope03.scale / 2
                        origin.y: horoscope03.height * horoscope03.scale / 2
                        angle: (root.currentSecond * 6) % 360
                        Behavior on angle {
                            RotationAnimation {
                                duration: 1000
                                direction: RotationAnimation.Clockwise
                            }
                        }
                    }
                }

                Image {
                    id: horoscope04
                    x: root.sp("UI_Img_Horoscope04.png") ? root.sp("UI_Img_Horoscope04.png").x : 0
                    y: root.sp("UI_Img_Horoscope04.png") ? root.sp("UI_Img_Horoscope04.png").y : 0
                    source: root.asset("UI_Img_Horoscope04.png")
                    scale: root.sp("UI_Img_Horoscope04.png") ? root.sp("UI_Img_Horoscope04.png").scale : 0.3
                    transformOrigin: Item.TopLeft
                    smooth: true
                    transform: Rotation {
                        origin.x: horoscope04.width * horoscope04.scale / 2
                        origin.y: horoscope04.height * horoscope04.scale / 2
                        angle: -(root.currentSecond * 6) % 360
                        Behavior on angle {
                            RotationAnimation {
                                duration: 1000
                                direction: RotationAnimation.Counterclockwise
                            }
                        }
                    }
                }

                Image {
                    id: horoscope05
                    x: root.sp("UI_Img_Horoscope05.png") ? root.sp("UI_Img_Horoscope05.png").x : 0
                    y: root.sp("UI_Img_Horoscope05.png") ? root.sp("UI_Img_Horoscope05.png").y : 0
                    source: root.asset("UI_Img_Horoscope05.png")
                    scale: root.sp("UI_Img_Horoscope05.png") ? root.sp("UI_Img_Horoscope05.png").scale : 0.3
                    transformOrigin: Item.TopLeft
                    smooth: true
                    transform: Rotation {
                        origin.x: horoscope05.width * horoscope05.scale / 2
                        origin.y: horoscope05.height * horoscope05.scale / 2
                        angle: (root.currentSecond * 12) % 360
                        Behavior on angle {
                            RotationAnimation {
                                duration: 1000
                                direction: RotationAnimation.Clockwise
                            }
                        }
                    }
                }

                Image {
                    id: clockCircle
                    x: root.sp("UI_Clock_Circle.png") ? root.sp("UI_Clock_Circle.png").x : 0
                    y: root.sp("UI_Clock_Circle.png") ? root.sp("UI_Clock_Circle.png").y : 0
                    source: root.asset("UI_Clock_Circle.png")
                    scale: root.sp("UI_Clock_Circle.png") ? root.sp("UI_Clock_Circle.png").scale : 0.3
                    transformOrigin: Item.TopLeft
                    smooth: true
                }

                Image {
                    id: minuteHand
                    x: root.sp("UI_Clock_MinuteHand.png") ? root.sp("UI_Clock_MinuteHand.png").x : 0
                    y: root.sp("UI_Clock_MinuteHand.png") ? root.sp("UI_Clock_MinuteHand.png").y : 0
                    source: root.asset("UI_Clock_MinuteHand.png")
                    scale: root.sp("UI_Clock_MinuteHand.png") ? root.sp("UI_Clock_MinuteHand.png").scale : 0.3
                    transformOrigin: Item.TopLeft
                    smooth: true
                    transform: Rotation {
                        origin.x: (clockCircle.x + clockCircle.width * clockCircle.scale / 2) - minuteHand.x
                        origin.y: (clockCircle.y + clockCircle.height * clockCircle.scale / 2) - minuteHand.y
                        angle: (root.currentMinute * 6) + (root.currentSecond * 0.1) - 175
                        Behavior on angle {
                            RotationAnimation {
                                duration: 500
                                direction: RotationAnimation.Clockwise
                            }
                        }
                    }
                }

                Image {
                    id: hourHand
                    x: root.sp("UI_Clock_HourHand.png") ? root.sp("UI_Clock_HourHand.png").x : 0
                    y: root.sp("UI_Clock_HourHand.png") ? root.sp("UI_Clock_HourHand.png").y : 0
                    source: root.asset("UI_Clock_HourHand.png")
                    scale: root.sp("UI_Clock_HourHand.png") ? root.sp("UI_Clock_HourHand.png").scale : 0.3
                    transformOrigin: Item.TopLeft
                    smooth: true
                    transform: Rotation {
                        origin.x: (clockCircle.x + clockCircle.width * clockCircle.scale / 2) - hourHand.x
                        origin.y: (clockCircle.y + clockCircle.height * clockCircle.scale / 2) - hourHand.y
                        angle: ((root.currentHour % 12) * 30) + (root.currentMinute * 0.5) - 10
                        Behavior on angle {
                            enabled: false
                        }
                    }
                }
            }
        }

        Image {
            id: clockDial
            x: 0
            y: 0
            source: root.asset("UI_Clock_Dial_NoTag.png")
            scale: root.sp("UI_Clock_Dial_NoTag.png") ? root.sp("UI_Clock_Dial_NoTag.png").scale : 0.4
            transformOrigin: Item.TopLeft
            smooth: true
            z: 100
        }

        Image {
            x: root.sp("UI_ClockIcon_Morning.png") ? root.sp("UI_ClockIcon_Morning.png").x : 0
            y: root.sp("UI_ClockIcon_Morning.png") ? root.sp("UI_ClockIcon_Morning.png").y : 0
            source: root.asset("UI_ClockIcon_Morning.png")
            scale: root.sp("UI_ClockIcon_Morning.png") ? root.sp("UI_ClockIcon_Morning.png").scale : 0.4
            transformOrigin: Item.TopLeft
            smooth: true
            visible: root.dataLoaded && root.currentHour >= 6 && root.currentHour < 12
            z: 200
        }

        Image {
            x: root.sp("UI_ClockIcon_Noon.png") ? root.sp("UI_ClockIcon_Noon.png").x : 0
            y: root.sp("UI_ClockIcon_Noon.png") ? root.sp("UI_ClockIcon_Noon.png").y : 0
            source: root.asset("UI_ClockIcon_Noon.png")
            scale: root.sp("UI_ClockIcon_Noon.png") ? root.sp("UI_ClockIcon_Noon.png").scale : 0.4
            transformOrigin: Item.TopLeft
            smooth: true
            visible: root.dataLoaded && root.currentHour >= 12 && root.currentHour < 18
            z: 200
        }

        Image {
            x: root.sp("UI_ClockIcon_Dusk.png") ? root.sp("UI_ClockIcon_Dusk.png").x : 0
            y: root.sp("UI_ClockIcon_Dusk.png") ? root.sp("UI_ClockIcon_Dusk.png").y : 0
            source: root.asset("UI_ClockIcon_Dusk.png")
            scale: root.sp("UI_ClockIcon_Dusk.png") ? root.sp("UI_ClockIcon_Dusk.png").scale : 0.4
            transformOrigin: Item.TopLeft
            smooth: true
            visible: root.dataLoaded && root.currentHour >= 18 && root.currentHour < 21
            z: 200
        }

        Image {
            x: root.sp("UI_ClockIcon_Night.png") ? root.sp("UI_ClockIcon_Night.png").x : 0
            y: root.sp("UI_ClockIcon_Night.png") ? root.sp("UI_ClockIcon_Night.png").y : 0
            source: root.asset("UI_ClockIcon_Night.png")
            scale: root.sp("UI_ClockIcon_Night.png") ? root.sp("UI_ClockIcon_Night.png").scale : 0.4
            transformOrigin: Item.TopLeft
            smooth: true
            visible: root.dataLoaded && (root.currentHour >= 21 || root.currentHour < 6)
            z: 200
        }
    }
}
