import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls

import qs.config
import qs.utils

Item {
    id: root
    property color color: Design.colors.surface_container_high
    property real radius: Design.card.corner

    Rectangle {
        anchors.fill: parent
        color: root.color
        radius: root.radius
    }
}
