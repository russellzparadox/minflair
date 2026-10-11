import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Core.Components
import qs.Core.Services
import qs.Core.Utils
import qs.Modules.Settings.Components

AppContainer {
    id: barSettingsRoot

    AppGroup {
        title: "Bar Style"
        icon: "bar"

        SettingSegmented {
            label: "Style"
            description: "Choose between Convex or Island"
            model: [{
                "text": "Convex",
                "value": "convex"
            }, {
                "text": "Island",
                "value": "island"
            }]
            currentValue: SettingsService.barStyle
            onActivated: (value) => {
                SettingsService.barStyle = value;
            }
        }

    }

    // ISLAND MODE WIDGETS
    AppGroup {
        title: "Island Bar Widgets"
        icon: "widgets"
        visible: SettingsService.barIslandMode

        SettingSegmented {
            label: "Right Circular Island"
            description: "Choose what to display in the right circular island (Music cover or Control Center)"
            model: [{
                "text": "Auto (Music or Tune)",
                "value": "auto"
            }, {
                "text": "Always Music",
                "value": "music"
            }, {
                "text": "Always Control Center",
                "value": "control_center"
            }]
            currentValue: SettingsService.islandRightMode
            onActivated: (value) => {
                SettingsService.islandRightMode = value;
            }
        }

    }

    AppGroup {
        title: "Clock Format"
        icon: "clock"

        SettingToggle {
            label: "24-Hour Time"
            description: "Use 24-hour time format instead of 12-hour AM/PM"
            checked: SettingsService.clock24h
            onCheckedChanged: {
                SettingsService.clock24h = checked;
            }
        }

        SettingToggle {
            label: "Show Seconds"
            description: "Display seconds on the main clock"
            checked: SettingsService.clockSeconds
            onCheckedChanged: {
                SettingsService.clockSeconds = checked;
            }
        }

        SettingToggle {
            label: "Show Date"
            description: "Display the current date next to the clock"
            checked: SettingsService.clockShowDate
            onCheckedChanged: {
                SettingsService.clockShowDate = checked;
            }
        }

    }

    AppGroup {
        title: "System Usage"
        icon: "cpu"

        SettingToggle {
            label: "Show System Usage"
            description: "Display CPU and memory readings in the Convex and Gaming bars"
            checked: SettingsService.barSysUsageEnabled
            onCheckedChanged: {
                SettingsService.barSysUsageEnabled = checked;
            }
        }

        SettingToggle {
            label: "CPU Usage"
            description: "Show the CPU load percentage"
            enabled: SettingsService.barSysUsageEnabled
            checked: SettingsService.barSysUsageCpu
            onCheckedChanged: {
                SettingsService.barSysUsageCpu = checked;
            }
        }

        SettingToggle {
            label: "RAM Usage"
            description: "Show the share of memory in use"
            enabled: SettingsService.barSysUsageEnabled
            checked: SettingsService.barSysUsageRam
            onCheckedChanged: {
                SettingsService.barSysUsageRam = checked;
            }
        }

        SettingToggle {
            label: "CPU Temperature"
            description: "Show the CPU sensor temperature"
            enabled: SettingsService.barSysUsageEnabled
            checked: SettingsService.barSysUsageTemp
            onCheckedChanged: {
                SettingsService.barSysUsageTemp = checked;
            }
        }

        SettingToggle {
            label: "GPU Usage"
            description: "Show GPU utilization when a GPU is detected"
            enabled: SettingsService.barSysUsageEnabled
            checked: SettingsService.barSysUsageGpu
            onCheckedChanged: {
                SettingsService.barSysUsageGpu = checked;
            }
        }

        SettingSegmented {
            label: "Display Style"
            description: "Percentage text or a compact mini bar"
            enabled: SettingsService.barSysUsageEnabled
            model: [{
                "text": "Percentage",
                "value": "text"
            }, {
                "text": "Mini Bar",
                "value": "bar"
            }]
            currentValue: SettingsService.barSysUsageStyle
            onActivated: (value) => {
                SettingsService.barSysUsageStyle = value;
            }
        }

        SettingSpinBox {
            label: "Update Interval"
            description: "How often the readings refresh"
            enabled: SettingsService.barSysUsageEnabled
            from: 1
            to: 60
            stepSize: 1
            value: SettingsService.barSysUsageInterval
            defaultValue: 2
            suffix: "s"
            onMoved: (val) => {
                SettingsService.barSysUsageInterval = Math.round(val);
            }
        }

        SettingSegmented {
            label: "Position"
            description: "Bar section that shows the readings"
            enabled: SettingsService.barSysUsageEnabled
            model: [{
                "text": "Left",
                "value": "left"
            }, {
                "text": "Right",
                "value": "right"
            }]
            currentValue: SettingsService.barSysUsagePosition
            onActivated: (value) => {
                SettingsService.barSysUsagePosition = value;
            }
        }

    }

}
