import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.config

Item {
    id: root
    property QtObject typescale: Design.typescale.headline.large
    property alias font: input.font

    property color placeholderTextColor: Design.colors.on_surface_variant
    property string placeholderText: "text"
    property alias text: input.text
    property alias input: input

    signal textEdited
    signal editingFinished
    signal accepted
    signal focusStateChanged(bool hasFocus)

    function getActiveFocus() {
        return input.activeFocus;
    }
    function setFocus(value) {
        input.focus = value;
    }
    function forceActiveFocus() {
        input.forceActiveFocus();
    }
    function selectAll() {
        input.selectAll();
    }
    function clear() {
        input.clear();
    }
    function insertText(str) {
        input.insert(input.cursorPosition, str);
    }

    TextInput {
        id: input
        anchors.fill: parent
        renderType: Text.QtRendering
        color: Design.colors.on_surface_variant
        selectedTextColor: Design.colors.primary
        selectionColor: Design.colors.primary
        font.family: root.typescale.font
        font.pointSize: root.typescale.size
        selectByMouse: true
        clip: true
        activeFocusOnTab: true
        onTextChanged: root.textEdited()
        onEditingFinished: root.editingFinished()
        onAccepted: root.accepted()
        onActiveFocusChanged: {
            console.log("M3TextField activeFocus changed:", activeFocus);
            console.log("M3TextField input.readOnly:", input.readOnly);
            root.focusStateChanged(activeFocus);
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                input.forceActiveFocus();
                if (mouse.button === Qt.LeftButton) {
                    const pos = input.positionAt(mouse.x - root.leftPadding, mouse.y - root.topPadding);
                    input.cursorPosition = pos;
                }
            }
            onDoubleClicked: {
                input.selectAll();
            }
        }
    }
    RichText {
        id: text
        anchors.fill: input
        color: root.placeholderTextColor
        text: root.placeholderText
        visible: input.text.length === 0 && !input.activeFocus
    }
}
