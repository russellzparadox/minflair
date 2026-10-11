import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Core
import qs.Core.Components
import qs.Core.Services

Item {
    id: root

    property var widget: null
    property alias initialFocusItem: input
    readonly property int preferredContentWidth: 400
    readonly property int maxVisibleItems: 8
    readonly property int itemHeight: 40
    readonly property int listSpacing: Constants.sizeXs
    // Keeps room for the empty state, then grows with the list up to maxVisibleItems and scrolls.
    readonly property int visibleRows: Math.min(Math.max(TodoService.model.count, 3), maxVisibleItems)
    readonly property int visibleListHeight: (visibleRows * itemHeight) + ((visibleRows - 1) * listSpacing)

    function closeWidget() {
        if (root.widget && typeof root.widget.close === "function")
            root.widget.close();
        else if (root.widget && root.widget.isOpen !== undefined)
            root.widget.isOpen = false;
        else
            AppState.activeWidget = "";
    }

    function resetTodo() {
        input.text = "";
        todoView.positionViewAtBeginning();
        input.forceActiveFocus();
    }

    function addTask() {
        if (input.text.trim() === "")
            return ;

        TodoService.add(input.text);
        input.text = "";
        Qt.callLater(todoView.positionViewAtEnd);
    }

    implicitWidth: preferredContentWidth
    implicitHeight: mainColumn.implicitHeight
    width: parent && parent.width > 0 ? parent.width : implicitWidth
    height: parent && parent.height > 0 ? parent.height : implicitHeight

    ColumnLayout {
        id: mainColumn

        anchors.fill: parent
        spacing: Constants.sizeMd

        RowLayout {
            Layout.fillWidth: true
            spacing: Constants.sizeXs

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Constants.size3Xs

                ThemedText {
                    text: "Todo"
                    customSize: Constants.sizeLg
                    font.bold: true
                    color: Theme.fg
                }

                ThemedText {
                    text: TodoService.model.count === 0 ? "Nothing to do" : (TodoService.remainingCount === 0 ? "All done" : TodoService.remainingCount + " left")
                    customSize: Constants.sizeXs + 2
                    color: Theme.muted
                }

            }

            Item {
                Layout.fillWidth: true
            }

            SvgIconButton {
                icon: "trash"
                iconSize: Constants.sizeSm
                iconColor: Theme.accent
                textIcon: "Clear done"
                textIconSize: Constants.sizeSm
                useCustomWidth: true
                disabled: TodoService.doneCount === 0
                onClicked: TodoService.clearDone()
            }

        }

        Divider {
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: root.visibleListHeight
            clip: true

            GhostEmptyState {
                anchors.centerIn: parent
                visible: opacity > 0.001
                opacity: TodoService.model.count === 0 ? 1 : 0
                text: "No tasks yet"
                isAnimating: visible

                Behavior on opacity {
                    NumberAnimation {
                        duration: Constants.animFast
                        easing.type: Easing.OutCubic
                    }

                }

            }

            ListView {
                id: todoView

                anchors.fill: parent
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: TodoService.model
                spacing: root.listSpacing
                visible: TodoService.model.count > 0

                add: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        from: 0
                        to: 1
                        duration: Constants.animFast
                        easing.type: Easing.OutQuint
                    }

                }

                remove: Transition {
                    NumberAnimation {
                        properties: "opacity"
                        to: 0
                        duration: Constants.animFast
                    }

                }

                displaced: Transition {
                    NumberAnimation {
                        properties: "y"
                        duration: Constants.animNormal
                        easing.type: Easing.OutQuint
                    }

                }

                delegate: Item {
                    id: delegateRoot

                    width: ListView.view ? ListView.view.width : 400
                    height: root.itemHeight

                    HoverHandler {
                        id: hoverHandler
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Constants.sizeLg
                        color: Theme.bgSecondary
                        visible: hoverHandler.hovered
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Constants.sizeSm
                        anchors.rightMargin: Constants.sizeSm
                        spacing: Constants.sizeMd

                        Item {
                            Layout.preferredWidth: Constants.sizeXl
                            Layout.preferredHeight: Constants.sizeXl
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                anchors.fill: parent
                                visible: !model.done
                                color: "transparent"
                                radius: Constants.size2Xs
                                border.width: 2
                                border.color: Theme.muted
                            }

                            SvgIcon {
                                anchors.centerIn: parent
                                visible: model.done
                                icon: "square-rounded-check"
                                iconSize: Constants.sizeXl
                                iconColor: Theme.accent
                                flat: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: TodoService.toggle(index)
                            }

                        }

                        ThemedText {
                            text: model.text
                            customSize: Constants.sizeMd
                            color: model.done ? Theme.muted : Theme.fg
                            font.strikeout: model.done
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }

                        SvgIconButton {
                            icon: "trash"
                            iconColor: Theme.muted
                            iconSize: Constants.sizeMd
                            flat: true
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: TodoService.remove(index)
                        }

                    }

                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                    active: true
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Constants.size4Xl
            radius: Constants.sizeMd
            color: Theme.bgSecondary

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Constants.sizeLg
                anchors.rightMargin: Constants.sizeSm
                spacing: Constants.sizeXs

                TextField {
                    id: input

                    Layout.fillWidth: true
                    placeholderText: "Add a task..."
                    placeholderTextColor: Theme.muted
                    font.family: Constants.fontFamily
                    font.pixelSize: Math.round(Constants.sizeMd * SettingsService.fontScale)
                    color: Theme.fg
                    selectByMouse: true
                    background: null
                    onAccepted: root.addTask()
                    Keys.onEscapePressed: root.closeWidget()
                }

                SvgIconButton {
                    icon: "check"
                    iconColor: Theme.accent
                    iconSize: Constants.sizeMd
                    flat: true
                    visible: input.text.trim() !== ""
                    onClicked: root.addTask()
                }

            }

        }

    }

}
