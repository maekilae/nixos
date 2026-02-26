import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

import qs.widgets
import qs.config

Button {
    id: root
    required property QtObject button_spec
    property bool is_disabled: false
    property string button_text
    property string button_icon
    property string button_symbol
    property color text_color: Design.colors.primary
    property color symbol_color: Design.colors.primary
    property color toggle_color: Design.colors.primary
    property color toggle_text_color: Design.colors.on_primary
    property color symbol_color_toggled: Design.colors.on_primary
    property bool is_toggled: false
    property bool is_square: false
    property bool isSelected: false
    property int radius: {
        if (is_square || is_toggled) {
            return button_spec.corner.square;
        } else {
            if (down) {
                return button_spec.corner.pressed;
            } else {
                return button_spec.corner.round;
            }
        }
    }
    property int icon_fill: 0
    property alias content: content

    property color color: Design.colors.surface_container_low

    implicitHeight: button_spec.size
    implicitWidth: implicitContentWidth

    background: Rectangle {
        id: button_background
        anchors.fill: parent
        radius: root.down ? root.button_spec.corner.pressed : root.button_spec.corner.round
        color: root.color
    }

    Rectangle {
        id: state_layer
        anchors.fill: parent
        radius: root.radius
        color: Qt.alpha(root.text_color, root.down || root.isSelected ? Design.state_layer.pressed : root.hovered ? Design.state_layer.hovered : 0)
    }

    contentItem: RowLayout {
        id: content
        anchors {
            fill: parent
        }
        RowLayout {
            id: row_content
            Layout.leftMargin: root.button_spec["padding"] ?? 0
            Layout.rightMargin: root.button_spec["padding"] ?? 0
            spacing: root.button_spec["icon_padding"]
            Loader {
                active: root.button_symbol !== ""
                sourceComponent: button_symbol_widget
            }
            Loader {
                active: root.button_text !== ""
                sourceComponent: button_text_widget
            }
        }
    }
    Component {
        id: button_symbol_widget
        M3Symbol {
            icon_size: root.button_spec.font.size
            text: root.button_symbol
            fill: root.button_spec["border"]
            color: root.symbol_color
        }
    }
    Component {
        id: button_text_widget
        RichText {
            text: root.button_text
            font {
                family: Design.typescale.label.medium.font
                pointSize: root.button_spec.font.size
            }
            color: root.text_color
        }
    }
}
