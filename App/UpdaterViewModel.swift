import SwiftUI

@MainActor
final class UpdaterViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var logText = "Bereit. Wähle aus, was aktualisiert werden soll, und starte den Update-Lauf."
    @Published var statusText = "Noch kein Update-Lauf gestartet."
    @Published var selection = UpdateSelection()

    private let runner = ShellCommandRunner()

    var canStartUpdates: Bool {
        !isRunning && selection.hasAnySelection
    }

    var selectedSteps: [String] {
        UpdateCommandBuilder.displaySteps(for: selection)
    }

    func startUpdates() {
        guard canStartUpdates else {
            statusText = "Bitte wähle mindestens einen Update-Bereich aus."
            return
        }

        isRunning = true
        statusText = "Terminal wird geöffnet…"
        logText = "Starte Update-Lauf im Terminal…\n"

        Task {
            let command = UpdateCommandBuilder.updateCommand(selection: selection)
            append("$ open -a Terminal '<UpdatePilot-Skript>'\n\n")
            append(command)
            append("\n\n--- Hinweis ---\n")

            let exitCode = await runner.run(command: command) { [weak self] output in
                Task { @MainActor in
                    self?.append(output)
                }
            }

            if exitCode == 0 {
                statusText = "Update-Lauf läuft im Terminal."
                append("\nDas Terminalfenster ist offen. Bitte dort weiterarbeiten, falls ein Passwort abgefragt wird.\n")
            } else {
                statusText = "Terminal konnte nicht geöffnet werden."
                append("\nBeendet mit Exit-Code: \(exitCode)\n")
            }

            isRunning = false
        }
    }

    private func append(_ text: String) {
        logText += text
    }
}
