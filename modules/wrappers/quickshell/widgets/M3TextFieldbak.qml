import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.config

TextField {
    id: root
    property QtObject typescale: Design.typescale.headline.large

    renderType: Text.QtRendering

    placeholderTextColor: Design.colors.on_surface_variant
    color: Design.colors.on_surface_variant
    selectedTextColor: Design.colors.primary
    selectionColor: Design.colors.primary

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
    }

    background: Rectangle {
        color: "Transparent"
    }

    font {
        family: typescale.font
        pointSize: typescale.size
        hintingPreference: Font.PreferFullHinting
    }
}
