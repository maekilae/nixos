pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    id: root
    property QtObject colors: QtObject {
        property bool is_dark_mode: true
        property string background: "#1a1110"
        property string surface: "#1a1110"
        property string surface_bright: "#423735"
        property string surface_dim: "#1a1110"
        property string surface_variant: "#534341"
        property string surface_tint: "#ffb4ab"
        property string surface_container: "#271d1c"
        property string surface_container_high: "#322826"
        property string surface_container_highest: "#3d3231"
        property string surface_container_low: "#231918"
        property string surface_container_lowest: "#140c0b"
        property string primary: "#ffb4ab"
        property string primary_container: "#73332e"
        property string primary_fixed: "#ffdad6"
        property string primary_fixed_dim: "#ffb4ab"
        property string secondary: "#e7bdb8"
        property string secondary_container: "#5d3f3c"
        property string secondary_fixed: "#ffdad6"
        property string secondary_fixed_dim: "#e7bdb8"
        property string tertiary: "#e0c38c"
        property string tertiary_container: "#584419"
        property string tertiary_fixed: "#fedfa6"
        property string tertiary_fixed_dim: "#e0c38c"
        property string on_background: "#f1dedc"
        property string on_surface: "#f1dedc"
        property string on_surface_variant: "#d8c2bf"
        property string on_primary: "#561e1a"
        property string on_primary_container: "#ffdad6"
        property string on_primary_fixed: "#3b0907"
        property string on_primary_fixed_variant: "#73332e"
        property string on_secondary: "#442927"
        property string on_secondary_container: "#ffdad6"
        property string on_secondary_fixed: "#2c1513"
        property string on_secondary_fixed_variant: "#5d3f3c"
        property string on_tertiary: "#3f2e04"
        property string on_tertiary_container: "#fedfa6"
        property string on_tertiary_fixed: "#261900"
        property string on_tertiary_fixed_variant: "#584419"
        property string error: "#ffb4ab"
        property string error_container: "#93000a"
        property string on_error: "#690005"
        property string on_error_container: "#ffdad6"
        property string inverse_surface: "#f1dedc"
        property string inverse_primary: "#904a44"
        property string inverse_on_surface: "#392e2d"
        property string outline: "#a08c8a"
        property string outline_variant: "#534341"
        property string scrim: "#000000"
        property string shadow: "#000000"
        property string source: "#560f0d"
    }

    property QtObject typeface: QtObject {
        property string brand: "Roboto"
        property string plain: "Roboto"
        property string icon_material: "Material Symbols Rounded"
        property QtObject weight: QtObject {
            property int regular: 400
            property int medium: 500
            property int bold: 700
        }
    }

    property QtObject typescale: QtObject {
        property QtObject headline: QtObject {
            property QtObject large: QtObject {
                property string font: typeface.brand
                property string weight: typeface.weight.regular
                property int size: 32
            }
            property QtObject medium: QtObject {
                property string font: typeface.brand
                property string weight: typeface.weight.regular
                property int size: 28
            }
            property QtObject small: QtObject {
                property string font: typeface.brand
                property string weight: typeface.weight.regular
                property int size: 24
            }
        }
        property QtObject body: QtObject {
            property QtObject large: QtObject {
                property string font: typeface.plain
                property string weight: typeface.weight.regular
                property int size: 16
            }
            property QtObject medium: QtObject {
                property string font: typeface.plain
                property string weight: typeface.weight.regular
                property int size: 14
            }
            property QtObject small: QtObject {
                property string font: typeface.plain
                property string weight: typeface.weight.regular
                property int size: 12
            }
        }
        property QtObject label: QtObject {
            property QtObject large: QtObject {
                property string font: typeface.plain
                property string weight: typeface.weight.regular
                property int size: 15
            }
            property QtObject medium: QtObject {
                property string font: typeface.plain
                property string weight: typeface.weight.regular
                property int size: 13
            }
            property QtObject small: QtObject {
                property string font: typeface.plain
                property string weight: typeface.weight.regular
                property int size: 11
            }
        }
    }

    property QtObject button: QtObject {
        property QtObject extra_small: QtObject {
            property int size: 32
            property int padding: 12
            property int icon_size: 20
            property int icon_padding: 8
            property int border: 1
            property QtObject font: typescale.body.small
            property QtObject corner: QtObject {
                property int round: corner.full
                property int square: corner.small
                property int pressed: corner.small
            }
        }
        property QtObject small: QtObject {
            property int size: 40
            property int padding: 16
            property int icon_size: 20
            property int icon_padding: 8
            property int border: 1
            property QtObject corner: QtObject {
                property int round: corner.full
                property int square: corner.small
                property int pressed: corner.small
            }
        }
        property QtObject medium: QtObject {
            property int size: 56
            property int padding: 24
            property int icon_size: 24
            property int icon_padding: 8
            property int border: 1
            property QtObject corner: QtObject {
                property int round: corner.full
                property int square: corner.small
                property int pressed: corner.small
            }
        }
        property QtObject large: QtObject {
            property int size: 96
            property int padding: 48
            property int icon_size: 32
            property int icon_padding: 12
            property int border: 2
        }
        property QtObject extra_large: QtObject {
            property int size: 136
            property int padding: 64
            property int icon_size: 40
            property int icon_padding: 16
            property int border: 3
        }
    }

    property QtObject fab: QtObject {}
    property QtObject extended_fab: QtObject {}
    property QtObject icon_button: QtObject {}
    property QtObject split_button: QtObject {}

    property QtObject search_bar: QtObject {
        property int size: 56
        property int padding: 16
        property int icon_size: 30
        property int symbol_size: 24
        property int corner: root.corner.full
    }

    property QtObject card: QtObject {
        property int padding: 16
        property int icon_size: 24
        property int symbol_size: 24
        property int corner: root.corner.medium
    }

    property QtObject corner: QtObject {
        property int extra_small: 4
        property int small: 8
        property int medium: 12
        property int large: 16
        property int large_increased: 20
        property int extra_large: 28
        property int extra_large_increased: 32
        property int extra_extra_large: 48
        property int full: 999
    }

    property QtObject elevation: QtObject {
        property int level0: 0
        property int level1: 1
        property int level2: 3
        property int level3: 6
        property int level4: 8
        property int level5: 12
    }

    property QtObject state_layer: QtObject {
        property double dragged: 0.16
        property double hovered: 0.08
        property double pressed: 0.1
    }

    property QtObject animation_curves: QtObject {
        readonly property list<real> expressive_fastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
        readonly property list<real> expressive_defaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
        readonly property list<real> expressive_slowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
        readonly property list<real> expressive_effects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasized_firstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
        readonly property list<real> emphasized_lastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasized_accel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasized_decel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standard_accel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standard_decel: [0, 0, 0, 1, 1, 1]
        readonly property real expressive_fastSpatialDuration: 350
        readonly property real expressive_defaultSpatialDuration: 500
        readonly property real expressive_slowSpatialDuration: 650
        readonly property real expressive_effectsDuration: 200
    }

    property QtObject animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animation_curves.expressive_defaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation_curves.expressive_defaultSpatial
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.element_move.duration
                    easing.type: root.animation.element_move.type
                    easing.bezierCurve: root.animation.element_move.bezierCurve
                }
            }
        }

        property QtObject element_move_enter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation_curves.emphasized_decel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.element_move_enter.duration
                    easing.type: root.animation.element_move_enter.type
                    easing.bezierCurve: root.animation.element_move_enter.bezierCurve
                }
            }
        }

        property QtObject element_move_exit: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation_curves.emphasized_accel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.element_move_exit.duration
                    easing.type: root.animation.element_move_exit.type
                    easing.bezierCurve: root.animation.element_move_exit.bezierCurve
                }
            }
        }

        property QtObject element_move_fast: QtObject {
            property int duration: animation_curves.expressive_effectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation_curves.expressive_effects
            property int velocity: 850
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.element_move_fast.duration
                    easing.type: root.animation.element_move_fast.type
                    easing.bezierCurve: root.animation.element_move_fast.bezierCurve
                }
            }
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.element_move_fast.duration
                    easing.type: root.animation.element_move_fast.type
                    easing.bezierCurve: root.animation.element_move_fast.bezierCurve
                }
            }
        }

        property QtObject element_move_slow: QtObject {
            property int duration: animation_curves.expressive_effectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation_curves.expressive_effects
            property int velocity: 650
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.element_move_slow.duration
                    easing.type: root.animation.element_move_slow.type
                    easing.bezierCurve: root.animation.element_move_slow.bezierCurve
                }
            }
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.element_move_slow.duration
                    easing.type: root.animation.element_move_slow.type
                    easing.bezierCurve: root.animation.element_move_slow.bezierCurve
                }
            }
        }

        property QtObject element_resize: QtObject {
            property int duration: 300
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation_curves.emphasized
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.element_resize.duration
                    easing.type: root.animation.element_resize.type
                    easing.bezierCurve: root.animation.element_resize.bezierCurve
                }
            }
        }

        property QtObject click_bounce: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation_curves.expressive_defaultSpatial
            property int velocity: 850
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.click_bounce.duration
                    easing.type: root.animation.click_bounce.type
                    easing.bezierCurve: root.animation.click_bounce.bezierCurve
                }
            }
        }

        property QtObject scroll: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animation_curves.standard_decel
        }

        property QtObject menuDecel: QtObject {
            property int duration: 350
            property int type: Easing.OutExpo
        }
    }
}
