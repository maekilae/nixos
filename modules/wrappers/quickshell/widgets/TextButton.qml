import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import qs.widgets
import qs.config

Button {
    id: root
    required property int button_size
    property string button_text
    property string button_icon
    property int icon_size
    property color hover_color: Design.colors.surface
    property color hover_text_color: Design.colors.on_surface
    property color button_color: root.hovered ? hover_color : Design.colors.surface
    property color text_color: Design.colors.on_surface
    property color icon_color: Design.colors.on_surface
    property int icon_fill: 0
    property color border_color: Design.colors.outline
    property int rounding: Design.corner.medium
    property int pressed_rounding: Design.corner.medium
    property int button_spacing
    property int button_padding

    onClicked: {
        print("HELLO");
    }
    padding: 0

    implicitHeight: button_size ?? parent.height

    background: Rectangle {
        id: button_background
        anchors.fill: parent
        radius: root.down ? root.pressed_rounding : root.rounding ?? Design.corner.full
        color: root.button_color
        Material.elevation: root.hovered ? 0 : 3
        border {
            width: Design.button.extra_small.border
            color: root.hovered ? root.border_color : "transparent"
        }
        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.leftMargin: root.button_padding ?? 0
            Layout.rightMargin: root.button_padding ?? 0
            spacing: root.button_spacing ?? Design.button.extra_small.icon_padding
            Symbol {
                id: button_icon_widget
                visible: root.button_icon !== ""
                icon_size: root.icon_size
                text: root.button_icon
                text_color: root.icon_color
                fill: root.icon_fill
            }
            RichText {
                id: button_text_widget
                visible: root.button_text !== ""
                text: root.button_text ?? ""
                font {
                    family: Design.typescale.label.medium.font
                    pointSize: Design.typescale.label.medium.size
                }
                text_color: root.text_color
            }
        }
    }
}
