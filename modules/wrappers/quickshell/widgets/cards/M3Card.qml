// TODO: Implement M3Card component
// https://m3.material.io/components/cards/specs
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.config
import qs.widgets

Control {
    id: root
    property color color: Design.colors.surface_container

    padding: Design.card.padding

    background: M3Ripple {
        anchors.fill: parent
        color: root.color
    }
}
