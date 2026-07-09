import SwiftUI

@MainActor
final class UpdaterViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var logText = "Bereit. Drücke den Button, um den Update-Lauf zu starten."
    @Published var statusText = "Noch kein Update-Lauf gestartet."

    private let runner = ShellCommandRunner()

    func startUpdates() {
        guard !isRunning else { return }
        isRunning = true
        statusText = "Updates werden ausgeführt…"
        logText = "Starte Update-Lauf…\n"

        Task {
            let command = UpdateCommandBuilder.updateCommand()
            append("$ /bin/zsh -lc '\(command)'\n")
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
