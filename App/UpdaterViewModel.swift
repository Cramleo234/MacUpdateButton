import SwiftUI

enum DashboardPhase: Equatable {
    case ready
    case running
    case completed
    case failed
}

@MainActor
final class UpdaterViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var logText = "Bereit. Wähle aus, was aktualisiert werden soll, und starte den Update-Lauf."
    @Published var statusText = "UpdatePilot ist bereit."
    @Published var selection = UpdateSelection() {
        didSet { refreshPlan() }
    }
    @Published var updatePlan: UpdatePlan
    @Published var progress: UpdateProgress = .idle
    @Published var phase: DashboardPhase = .ready
    @Published var friendlyError: FriendlyUpdateError?

    private let runner = ShellCommandRunner()

    init() {
        self.updatePlan = Self.previewPlan(for: UpdateSelection())
    }

    var canStartUpdates: Bool {
        !isRunning && selection.hasAnySelection
    }

    var selectedSteps: [String] {
        UpdateCommandBuilder.displaySteps(for: selection)
    }

    var heroTitle: String {
        switch phase {
        case .ready:
            return updatePlan.headline
        case .running:
            return "Update läuft"
        case .completed:
            return "Update abgeschlossen."
        case .failed:
            return friendlyError?.title ?? "Ein Update braucht Aufmerksamkeit."
        }
    }

    var heroSubtitle: String {
        switch phase {
        case .ready:
            return updatePlan.isEmpty ? "Keine Bereiche ausgewählt." : "Prüfe den Plan und starte, wenn alles passt."
        case .running:
            return "Bitte lasse UpdatePilot geöffnet, bis der Lauf fertig ist."
        case .completed:
            return "Alle ausgewählten Schritte wurden beendet."
        case .failed:
            return friendlyError?.message ?? "Details findest du im Protokoll."
        }
    }

    func startUpdates() {
        guard canStartUpdates else {
            statusText = "Bitte wähle mindestens einen Update-Bereich aus."
            updatePlan = .empty
            return
        }

        refreshPlan()
        isRunning = true
        phase = .running
        friendlyError = nil
        progress = UpdateProgress(currentStep: .checkingHomebrew)
        statusText = "Update-Lauf läuft…"
        logText = "Starte Update-Lauf…\n\n"

        Task {
            for step in UpdateStep.allCases {
                progress = UpdateProgress(currentStep: step, completedSteps: progress.completedSteps)
                append("\n== \(step.title) ==\n")

                let command = command(for: step)
                let exitCode = await runner.run(command: command) { [weak self] output in
                    Task { @MainActor in
                        self?.append(output)
                    }
                }

                if exitCode == 0 {
                    progress = progress.completingCurrent(andStarting: nil)
                } else {
                    let error = FriendlyUpdateError(exitCode: exitCode, log: logText)
                    friendlyError = error
                    phase = .failed
                    statusText = error.title
                    append("\n\(error.title)\n\(error.recoverySuggestion)\n")
                    isRunning = false
                    return
                }
            }

            progress = UpdateProgress(currentStep: nil, completedSteps: Set(UpdateStep.allCases))
            phase = .completed
            statusText = "Update-Lauf abgeschlossen."
            append("\nUpdate-Lauf abgeschlossen.\n")
            isRunning = false
        }
    }

    func retryUpdates() {
        startUpdates()
    }

    private func refreshPlan() {
        updatePlan = Self.previewPlan(for: selection)
    }

    private static func previewPlan(for selection: UpdateSelection) -> UpdatePlan {
        guard selection.hasAnySelection else { return .empty }

        let apps = selection.includeMas
            ? [UpdateItem(name: "Mac App Store Apps", detail: "Aktualisierung über mas, wenn verfügbar")]
            : []
        let tools = selection.includeHomebrew
            ? [UpdateItem(name: "Homebrew Pakete und Casks", detail: "Aktualisieren, upgraden und aufräumen")]
            : []
        let selectedAreaCount = [selection.includeHomebrew, selection.includeMas, selection.includeSystemUpdateCheck].filter { $0 }.count

        return UpdatePlan(
            apps: apps,
            tools: tools,
            homebrewUpdateAvailable: selection.includeHomebrew,
            estimatedDurationMinutes: max(2, selectedAreaCount * 2)
        )
    }

    private func command(for step: UpdateStep) -> String {
        switch step {
        case .checkingHomebrew:
            return """
set -o pipefail
if command -v brew >/dev/null 2>&1; then
  brew --version | head -n 1
else
  echo 'Homebrew nicht gefunden – Homebrew-Schritte werden übersprungen.'
fi
"""
        case .loadingPlan:
            let steps = selectedSteps.map { "• \($0)" }.joined(separator: "\n")
            return """
echo 'Geplanter Ablauf:'
printf '%s\n' '\(steps)'
"""
        case .updatingApps:
            guard selection.includeMas else {
                return "echo 'Mac-App-Store-Updates wurden abgewählt – überspringe mas.'"
            }
            return UpdateCommandBuilder.masCommand()
        case .updatingTools:
            guard selection.includeHomebrew else {
                return "echo 'Homebrew wurde abgewählt – überspringe Paket-Updates.'"
            }
            return """
set -o pipefail
if command -v brew >/dev/null 2>&1; then
  echo '== Homebrew: update =='
  brew update && \
  echo '== Homebrew: upgrade ==' && \
  brew upgrade
else
  echo 'Homebrew nicht gefunden – überspringe Homebrew-Updates.'
fi
"""
        case .cleanup:
            guard selection.includeHomebrew else {
                return "echo 'Homebrew wurde abgewählt – kein Aufräumen nötig.'"
            }
            return """
if command -v brew >/dev/null 2>&1; then
  echo '== Homebrew: cleanup =='
  brew cleanup
else
  echo 'Homebrew nicht gefunden – kein Aufräumen nötig.'
fi
"""
        case .finishing:
            guard selection.includeSystemUpdateCheck else {
                return "echo 'macOS-Systemupdate-Anzeige wurde abgewählt.'"
            }
            return UpdateCommandBuilder.systemUpdateCheckCommand()
        }
    }

    private func append(_ text: String) {
        logText += text
    }
}
