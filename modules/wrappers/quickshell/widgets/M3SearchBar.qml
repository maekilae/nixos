import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.config

Rectangle {
    id: root
    property bool isFocused: false
    property QtObject typescale: Design.typescale.body.large

    property alias text: textInput.text
    property string search_placeholder: "Search"
    property string left_symbol: "Search"
    property string right_symbol: "Backspace"

    property alias textInput: textInput

    property var onTextChanged
    property var onAccepted
    //anchors.fill: parent

    color: Design.colors.surface_container_high
    radius: Design.search_bar.corner

    RowLayout {
        id: row_layout
        focus: true
        anchors.fill: parent
        spacing: 0
        M3Symbol {
            Layout.leftMargin: Design.search_bar.padding
            icon_size: typescale.size
            icon_weight: typescale.weight
            color: Design.colors.on_surface_variant
            text: root.left_symbol
        }
        TextInput {
            id: textInput
            Layout.fillWidth: true
            Layout.rightMargin: Design.search_bar.padding
            Layout.leftMargin: Design.search_bar.padding
            renderType: Text.QtRendering
            color: Design.colors.on_surface_variant
            selectedTextColor: Design.colors.primary
            selectionColor: Design.colors.primary
            font.family: root.typescale.font
            font.pointSize: root.typescale.size
            selectByMouse: true
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    textInput.forceActiveFocus();
                    if (mouse.button === Qt.LeftButton) {
                        const pos = textInput.positionAt(mouse.x - root.leftPadding, mouse.y - root.topPadding);
                        textInput.cursorPosition = pos;
                    }
                }
                onDoubleClicked: {
                    textInput.selectAll();
                }
            }
        }
        M3Symbol {
            Layout.rightMargin: Design.search_bar.padding
            icon_size: root.typescale.size
            icon_weight: root.typescale.weight
            color: Design.colors.on_surface_variant
            text: root.right_symbol
        }
    }
}
