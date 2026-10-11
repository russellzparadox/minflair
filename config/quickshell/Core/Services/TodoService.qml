import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
import qs.Core.Services
pragma Singleton

Item {
    id: root

    readonly property string filePath: Quickshell.env("HOME") + "/.cache/quickshell/todos.json"
    property alias model: todoModel
    property int remainingCount: 0
    property int doneCount: 0
    property bool loaded: false

    // Called once from ShellModules so the saved list is ready before the panel opens.
    function load() {
        loadProc.running = true;
    }

    function add(text) {
        let trimmed = text.trim();
        if (trimmed === "")
            return ;

        todoModel.append({
            "text": trimmed,
            "done": false
        });
        changed();
    }

    function toggle(index) {
        if (index < 0 || index >= todoModel.count)
            return ;

        todoModel.setProperty(index, "done", !todoModel.get(index).done);
        changed();
    }

    function remove(index) {
        if (index < 0 || index >= todoModel.count)
            return ;

        todoModel.remove(index);
        changed();
    }

    function clearDone() {
        for (let i = todoModel.count - 1; i >= 0; i--) {
            if (todoModel.get(i).done)
                todoModel.remove(i);

        }
        changed();
    }

    function refreshCounts() {
        let done = 0;
        for (let i = 0; i < todoModel.count; i++) {
            if (todoModel.get(i).done)
                done++;

        }
        doneCount = done;
        remainingCount = todoModel.count - done;
    }

    function changed() {
        refreshCounts();
        saveTimer.restart();
    }

    ListModel {
        id: todoModel
    }

    Process {
        id: loadProc

        command: ["cat", root.filePath]
        onExited: function(exitCode) {
            // A missing or corrupt file starts the list empty; the next change rewrites it.
            let saved = [];
            if (exitCode === 0) {
                try {
                    let parsed = JSON.parse(loadOutput.text);
                    if (Array.isArray(parsed))
                        saved = parsed;

                } catch (e) {
                    console.warn("TodoService: ignoring unreadable " + root.filePath + ": " + e);
                }
            }
            todoModel.clear();
            for (let i = 0; i < saved.length; i++) {
                let item = saved[i];
                if (!item || typeof item.text !== "string" || item.text.trim() === "")
                    continue;

                todoModel.append({
                    "text": item.text.trim(),
                    "done": item.done === true
                });
            }
            root.refreshCounts();
            root.loaded = true;
        }

        stdout: StdioCollector {
            id: loadOutput
        }

    }

    Timer {
        id: saveTimer

        interval: 100
        repeat: false
        onTriggered: {
            if (!root.loaded)
                return ;

            if (saveProc.running) {
                saveTimer.restart();
                return ;
            }
            let data = [];
            for (let i = 0; i < todoModel.count; i++) {
                let item = todoModel.get(i);
                data.push({
                    "text": item.text,
                    "done": item.done
                });
            }
            // Write a temp file and rename it, so a crash mid-write cannot leave a truncated todos.json.
            // ponytail: rewrites the whole list on each save; fine at todo size, switch to per-item rows if it grows large.
            saveProc.command = ["sh", "-c", "mkdir -p ~/.cache/quickshell && cat << 'EOF' > ~/.cache/quickshell/todos.json.tmp && mv ~/.cache/quickshell/todos.json.tmp ~/.cache/quickshell/todos.json\n" + JSON.stringify(data) + "\nEOF"];
            saveProc.running = true;
        }
    }

    Process {
        id: saveProc
    }

}
