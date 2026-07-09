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
        statusText = "Updates werden ausgeführt…"
        logText = "Starte Update-Lauf…\n"

        Task {
            let command = UpdateCommandBuilder.updateCommand(selection: selection)
            append("$ /bin/zsh -lc '<UpdatePilot-Skript>'\n\n")
            append(command)
            append("\n\n--- Ausgabe ---\n")

            let exitCode = await runner.run(command: command) { [weak self] output in
                Task { @MainActor in
                    self?.append(output)
                }
            }

            if exitCode == 0 {
                statusText = "Update-Lauf abgeschlossen."
                append("\nFertig. Exit-Code: 0\n")
            } else {
                statusText = "Update-Lauf mit Fehler beendet."
                append("\nBeendet mit Exit-Code: \(exitCode)\n")
            }

            isRunning = false
        }
    }

    private func append(_ text: String) {
        logText += text
    }
}
