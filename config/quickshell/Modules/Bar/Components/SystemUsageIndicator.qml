import QtQuick
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services

// Compact CPU / RAM / temperature / GPU readout. It reads the shared SystemStats
// daemon, so it adds no polling of its own. Each bar section holds one instance;
// only the one whose side matches barSysUsagePosition is shown.
Rectangle {
    id: root

    property string side: "right"
    readonly property var metrics: [{
        "id": "cpu",
        "label": "CPU",
        "unit": "%"
    }, {
        "id": "ram",
        "label": "RAM",
        "unit": "%"
    }, {
        "id": "temp",
        "label": "TEMP",
        "unit": "°C"
    }, {
        "id": "gpu",
        "label": "GPU",
        "unit": "%"
    }]
    readonly property bool anyMetric: SettingsService.barSysUsageCpu || SettingsService.barSysUsageRam || SettingsService.barSysUsageTemp || SettingsService.barSysUsageGpu
    readonly property bool shown: SettingsService.barSysUsageEnabled && anyMetric && SettingsService.barSysUsagePosition === side
    readonly property bool useBars: SettingsService.barSysUsageStyle === "bar"
    readonly property string details: {
        let lines = [];
        lines.push("CPU " + Math.round(SystemStats.cpuUsage) + "%");
        lines.push("RAM " + Math.round(SystemStats.memUsage) + "% (" + SystemStats.memUsed.toFixed(1) + " / " + SystemStats.memTotal + ")");
        lines.push("CPU temp " + (SystemStats.cpuTemp >= 0 ? SystemStats.cpuTemp + "°C" : "unavailable"));
        lines.push("GPU " + (SystemStats.gpuUsage >= 0 ? SystemStats.gpuUsage + "%" : "unavailable"));
        lines.push("Uptime " + SystemStats.uptime);
        return lines.join("\n");
    }

    function isOn(id) {
        switch (id) {
        case "cpu":
            return SettingsService.barSysUsageCpu;
        case "ram":
            return SettingsService.barSysUsageRam;
        case "temp":
            return SettingsService.barSysUsageTemp;
        case "gpu":
            return SettingsService.barSysUsageGpu;
        }
        return false;
    }

    // Raw reading for a metric id, or -1 when it is unavailable.
    function readingOf(id) {
        switch (id) {
        case "cpu":
            return SystemStats.cpuUsage;
        case "ram":
            return SystemStats.memUsage;
        case "temp":
            return SystemStats.cpuTemp;
        case "gpu":
            return SystemStats.gpuUsage;
        }
        return -1;
    }

    visible: shown
    implicitWidth: contentRow.implicitWidth + Constants.sizeXs * 2
    implicitHeight: SettingsService.barWidgetHeight
    width: implicitWidth
    height: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: DisplayProfileService.gameModeActive ? 0 : height / 2
    color: hoverHandler.hovered ? Theme.bgTertiary : Theme.bgSecondary

    HoverHandler {
        id: hoverHandler
    }

    ThemedTooltip {
        text: root.details
        visible: hoverHandler.hovered
    }

    RowLayout {
        id: contentRow

        anchors.centerIn: parent
        spacing: Constants.sizeXs

        Repeater {
            model: root.metrics

            RowLayout {
                required property var modelData
                readonly property real reading: root.readingOf(modelData.id)

                visible: root.isOn(modelData.id)
                spacing: Constants.size3Xs

                ThemedText {
                    text: modelData.label
                    color: Theme.muted
                    customSize: 11
                    Layout.alignment: Qt.AlignVCenter
                }

                ThemedText {
                    visible: !root.useBars
                    text: reading < 0 ? "--" : Math.round(reading) + modelData.unit
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Rectangle {
                    visible: root.useBars
                    implicitWidth: Constants.sizeXl
                    implicitHeight: Constants.size2Xs
                    Layout.alignment: Qt.AlignVCenter
                    radius: height / 2
                    color: Theme.border

                    Rectangle {
                        width: parent.width * Math.min(1, Math.max(0, reading / 100))
                        height: parent.height
                        radius: height / 2
                        color: Theme.accent

                        Behavior on width {
                            NumberAnimation {
                                duration: Constants.animNormal
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

            }

        }

    }

    Behavior on color {
        ColorAnimation {
            duration: Constants.animFast
        }

    }

}
