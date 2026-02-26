import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ToolTip {
    id: root

    property bool extra_visible: true
    property bool alt_visible: false

    readonly property bool is_visible: (extra_visible && (parent.hovered === undefined || parent?.hovered)) || alt_visible
    topPadding: 12
    horizontalPadding: 16
    bottomPadding: 8
}
