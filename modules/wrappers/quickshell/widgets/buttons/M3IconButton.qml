import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

import qs.widgets
import qs.config

Button {
    id: root
    //is_square ? button_spec.corner.square : (down ? button_spec.corner.pressed : button_spec.corner.round)
    required property QtObject button_spec
    property string button_icon
    property alias icon_path: button_icon.iconFolder
    property string icon_color: Design.colors.on_surface
    property color icon_color_toggled: Design.colors.on_primary
    property color toggle_color: Design.colors.primary
    property bool is_toggled: false
    property bool is_square: false
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
    //property alias content: content

    property bool disabled: false

    property color color: Design.colors.surface_container_low

    implicitHeight: button_spec.size
    implicitWidth: button_spec.size

    padding: 0

    background: Rectangle {
        id: button_background
        anchors.fill: parent
        radius: root.radius
        color: is_toggled ? root.toggle_color : root.color
    }

    Rectangle {
        id: state_layer
        anchors.fill: parent
        radius: root.radius
        color: Qt.alpha(Design.colors.on_surface, root.down ? Design.state_layer.pressed : root.hovered ? Design.state_layer.hovered : 0)
    }

    contentItem: RowLayout {
        id: content
        anchors {
            fill: parent
        }
        spacing: 0
        Rectangle {
            color: "transparent"
            Layout.alignment: {
                horizontal: Qt.AlignCenter;
                vertical: Qt.AlignCenter;
            }
            Layout.margins: root.button_spec["padding"] ?? 0

            M3Icon {
                id: button_icon
                anchors {
                    centerIn: parent
                }
                color: root.is_toggled ? root.icon_color_toggled : root.icon_color
                source: root.button_icon
                icon_size: root.button_spec.icon_size
            }
        }
    }
}
