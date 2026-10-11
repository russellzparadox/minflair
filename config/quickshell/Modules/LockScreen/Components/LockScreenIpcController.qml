import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs.Core.Services

Item {
    id: root

    property bool authenticating: false
    property bool authFailed: false
    property bool unlocking: false
    // Set only when PAM is unusable or the account is locked out; a wrong password uses authFailed.
    property string authError: ""
    property string pendingPassword: ""

    signal authSucceeded()
    signal toggleLockRequested()
    signal unlockRequested()

    function reset() {
        if (pam.active)
            pam.abort();

        root.finishAttempt(false, "");
        root.unlocking = false;
    }

    // Ends the current attempt. failed = wrong password; errorText = backend or lockout message.
    function finishAttempt(failed, errorText) {
        root.authenticating = false;
        root.pendingPassword = "";
        root.authFailed = failed;
        root.authError = errorText;
    }

    function submitPassword(pwd) {
        if (root.authenticating)
            return ;

        root.authenticating = true;
        root.authFailed = false;
        root.authError = "";
        root.pendingPassword = pwd;
        if (!pam.start())
            root.finishAttempt(false, "Authentication error: PAM could not start");
    }

    Timer {
        id: socketRecoveryTimer

        interval: 350
        running: true
        repeat: false
        onTriggered: {
            server.active = false;
            server.active = true;
        }
    }

    IpcHandler {
        function toggle() {
            root.toggleLockRequested();
        }

        function unlock() {
            root.unlockRequested();
        }

        target: "lockScreen"
    }

    SocketServer {
        id: server

        path: "/tmp/quickshell_lockScreen"
        active: true

        handler: Component {
            Socket {
                onConnectedChanged: {
                    if (connected) {
                        root.toggleLockRequested();
                        Qt.callLater(() => {
                            connected = false;
                        });
                    }
                }
            }

        }

    }

    PamContext {
        id: pam

        // ponytail: password-only (no fingerprint). "login" runs pam_fprintd first and waits up to 30 s before the password prompt; switch config to "login" to add it.
        config: "system-auth"
        configDirectory: "/etc/pam.d"
        user: Quickshell.env("USER") || Quickshell.env("LOGNAME")
        onPamMessage: {
            if (!root.authenticating || !pam.responseRequired)
                return ;

            // Answer only the hidden "Password:" prompt. Any visible prompt must never receive the password.
            if (pam.responseVisible) {
                pam.abort();
                root.finishAttempt(false, "Authentication error: unexpected PAM prompt");
                return ;
            }
            pam.respond(root.pendingPassword);
        }
        onCompleted: (result) => {
            if (!root.authenticating)
                return ;

            if (result === PamResult.Success) {
                root.finishAttempt(false, "");
                root.unlocking = true;
                root.authSucceeded();
            } else if (result === PamResult.Failed) {
                root.finishAttempt(true, "");
            } else if (result === PamResult.MaxTries) {
                root.finishAttempt(false, "Too many failed attempts. Try again later.");
            } else {
                root.finishAttempt(false, "Authentication error: PAM failed");
            }
        }
        onError: (error) => {
            if (root.authenticating)
                root.finishAttempt(false, "Authentication error: " + PamError.toString(error));
        }
    }

}
