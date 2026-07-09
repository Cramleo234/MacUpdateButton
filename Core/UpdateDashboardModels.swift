import Foundation

public struct UpdateItem: Equatable, Identifiable {
    public let id: UUID
    public var name: String
    public var detail: String?

    public init(id: UUID = UUID(), name: String, detail: String? = nil) {
        self.id = id
        self.name = name
        self.detail = detail
    }
}

public struct UpdateSummaryRow: Equatable, Identifiable {
    public let id: String
    public var title: String
    public var value: String
    public var systemImage: String

    public init(title: String, value: String, systemImage: String) {
        self.id = title
        self.title = title
        self.value = value
        self.systemImage = systemImage
    }
}

public struct UpdatePlan: Equatable {
    public var apps: [UpdateItem]
    public var tools: [UpdateItem]
    public var homebrewUpdateAvailable: Bool
    public var estimatedDurationMinutes: Int?

    public init(
        apps: [UpdateItem] = [],
        tools: [UpdateItem] = [],
        homebrewUpdateAvailable: Bool = false,
        estimatedDurationMinutes: Int? = nil
    ) {
        self.apps = apps
        self.tools = tools
        self.homebrewUpdateAvailable = homebrewUpdateAvailable
        self.estimatedDurationMinutes = estimatedDurationMinutes
    }

    public static let empty = UpdatePlan()

    public var totalUpdates: Int {
        apps.count + tools.count + (homebrewUpdateAvailable ? 1 : 0)
    }

    public var isEmpty: Bool {
        totalUpdates == 0
    }

    public var headline: String {
        isEmpty ? "Alles aktuell." : "\(totalUpdates) Updates bereit"
    }

    public var durationText: String {
        guard let estimatedDurationMinutes else { return "Dauer abhängig vom Umfang" }
        return "ca. \(estimatedDurationMinutes) Minuten"
    }

    public var summaryRows: [UpdateSummaryRow] {
        var rows: [UpdateSummaryRow] = []
        if !apps.isEmpty {
            rows.append(UpdateSummaryRow(title: "Apps", value: "\(apps.count)", systemImage: "app.badge"))
        }
        if !tools.isEmpty {
            rows.append(UpdateSummaryRow(title: "Tools", value: "\(tools.count)", systemImage: "terminal"))
        }
        if homebrewUpdateAvailable {
            rows.append(UpdateSummaryRow(title: "Homebrew", value: "1", systemImage: "shippingbox"))
        }
        return rows
    }
}

public enum UpdateStep: String, CaseIterable, Identifiable, Equatable {
    case checkingHomebrew
    case loadingPlan
    case updatingApps
    case updatingTools
    case cleanup
    case finishing

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .checkingHomebrew:
            return "Homebrew prüfen"
        case .loadingPlan:
            return "Update-Plan laden"
        case .updatingApps:
            return "Apps aktualisieren"
        case .updatingTools:
            return "Tools aktualisieren"
        case .cleanup:
            return "Aufräumen"
        case .finishing:
            return "Fertigstellen"
        }
    }

    public var systemImage: String {
        switch self {
        case .checkingHomebrew:
            return "checkmark.seal"
        case .loadingPlan:
            return "list.bullet.clipboard"
        case .updatingApps:
            return "app.badge"
        case .updatingTools:
            return "terminal"
        case .cleanup:
            return "sparkles"
        case .finishing:
            return "flag.checkered"
        }
    }
}

public enum UpdateStepState: Equatable {
    case completed
    case current
    case pending
}

public struct UpdateProgress: Equatable {
    public var currentStep: UpdateStep?
    public var completedSteps: Set<UpdateStep>

    public init(currentStep: UpdateStep? = nil, completedSteps: Set<UpdateStep> = []) {
        self.currentStep = currentStep
        self.completedSteps = completedSteps
    }

    public static let idle = UpdateProgress()

    public func state(for step: UpdateStep) -> UpdateStepState {
        if completedSteps.contains(step) {
            return .completed
        }
        if currentStep == step {
            return .current
        }
        return .pending
    }

    public func completingCurrent(andStarting nextStep: UpdateStep?) -> UpdateProgress {
        var completed = completedSteps
        if let currentStep {
            completed.insert(currentStep)
        }
        return UpdateProgress(currentStep: nextStep, completedSteps: completed)
    }
}

public struct FriendlyUpdateError: Equatable {
    public var title: String
    public var message: String
    public var affectedItem: String
    public var recoverySuggestion: String

    public init(exitCode: Int32, log: String) {
        let item = FriendlyUpdateError.detectAffectedItem(in: log)
        self.title = "Ein Update konnte nicht abgeschlossen werden."
        self.affectedItem = item
        self.message = item == "Unbekannt"
            ? "Der Update-Lauf wurde gestoppt, bevor alle Schritte fertig waren."
            : "Betroffen: \(item). Der Update-Lauf wurde gestoppt, bevor alle Schritte fertig waren."
        self.recoverySuggestion = "Schließe betroffene Apps oder Prozesse und versuche es erneut. Die Details bleiben im Protokoll erhalten."
    }

    private static func detectAffectedItem(in log: String) -> String {
        let candidates = ["homebrew", "brew", "mas", "git", "node", "python", "ruby", "wget", "curl"]
        let lowercasedLog = log.lowercased()
        if let match = candidates.first(where: { lowercasedLog.contains($0) }) {
            return match == "brew" ? "Homebrew" : match
        }
        return "Unbekannt"
    }
}
