import QtQuick
import qs.Core.Components
import qs.Core.Services
import qs.Modules.Clipboard
import qs.Modules.KeybindsCheatSheet
import qs.Modules.Launcher
import qs.Modules.LockScreen
import qs.Modules.PackageManager
import qs.Modules.Settings
import qs.Modules.Todo
import qs.Modules.WallpaperSelector

Item {
    id: root

    // Loads the saved todo list at shell start, before the panel is ever opened
    Component.onCompleted: TodoService.load()

    // Bar & media sockets
    WidgetLoader {
        widgetId: "dashboard"
    }

    WidgetLoader {
        widgetId: "controlCenter"
    }

    WidgetLoader {
        widgetId: "notificationsCenter"
    }

    WidgetLoader {
        widgetId: "music"
    }

    // Application & drawer widgets
    WidgetLoader {
        widgetId: "launcher"

        sourceComponent: Component {
            Launcher {
            }

        }

    }

    WidgetLoader {
        widgetId: "clipboard"

        sourceComponent: Component {
            Clipboard {
            }

        }

    }

    WidgetLoader {
        widgetId: "todo"

        sourceComponent: Component {
            Todo {
            }

        }

    }

    WidgetLoader {
        widgetId: "wallpaper"

        sourceComponent: Component {
            WallpaperSelector {
            }

        }

    }

    WidgetLoader {
        widgetId: "screenshot"
    }

    WidgetLoader {
        widgetId: "powerMenu"
    }

    // Standalone application windows
    WidgetLoader {
        widgetId: "minflair_keybinds"
        exclusive: false

        sourceComponent: Component {
            KeybindsCheatSheet {
            }

        }

    }

    WidgetLoader {
        widgetId: "minflair_settings"
        exclusive: false

        sourceComponent: Component {
            Settings {
            }

        }

    }

    WidgetLoader {
        widgetId: "packagemanager"
        exclusive: false

        sourceComponent: Component {
            PackageManager {
            }

        }

    }

    LockScreen {
        id: lockScreen
    }

}
