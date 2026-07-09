import XCTest

final class UpdateDashboardModelTests: XCTestCase {
    func testUpdatePlanSummarizesVisibleCountsAndEstimatedDuration() {
        let plan = UpdatePlan(
            apps: [UpdateItem(name: "Firefox"), UpdateItem(name: "Raycast")],
            tools: [UpdateItem(name: "git"), UpdateItem(name: "node"), UpdateItem(name: "wget")],
            homebrewUpdateAvailable: true,
            estimatedDurationMinutes: 6
        )

        XCTAssertEqual(plan.totalUpdates, 6)
        XCTAssertEqual(plan.summaryRows.map(\.title), ["Apps", "Tools", "Homebrew"])
        XCTAssertEqual(plan.summaryRows.map(\.value), ["2", "3", "1"])
        XCTAssertEqual(plan.durationText, "ca. 6 Minuten")
        XCTAssertFalse(plan.isEmpty)
    }

    func testEmptyUpdatePlanReadsAsUpToDate() {
        let plan = UpdatePlan.empty

        XCTAssertEqual(plan.totalUpdates, 0)
        XCTAssertTrue(plan.summaryRows.isEmpty)
        XCTAssertEqual(plan.headline, "Alles aktuell.")
        XCTAssertTrue(plan.isEmpty)
    }

    func testTimelineMarksCompletedCurrentAndPendingSteps() {
        let progress = UpdateProgress(
            currentStep: .updatingApps,
            completedSteps: [.checkingHomebrew, .loadingPlan]
        )

        XCTAssertEqual(progress.state(for: .checkingHomebrew), .completed)
        XCTAssertEqual(progress.state(for: .loadingPlan), .completed)
        XCTAssertEqual(progress.state(for: .updatingApps), .current)
        XCTAssertEqual(progress.state(for: .cleanup), .pending)
        XCTAssertEqual(UpdateStep.allCases.map(\.title), [
            "Homebrew prüfen",
            "Update-Plan laden",
            "Apps aktualisieren",
            "Tools aktualisieren",
            "Aufräumen",
            "Fertigstellen"
        ])
    }

    func testFriendlyUpdateErrorExtractsUsefulSummaryFromLog() {
        let error = FriendlyUpdateError(exitCode: 1, log: "Error: git is already in use by another process")

        XCTAssertEqual(error.title, "Ein Update konnte nicht abgeschlossen werden.")
        XCTAssertEqual(error.affectedItem, "git")
        XCTAssertTrue(error.recoverySuggestion.contains("erneut"))
        XCTAssertFalse(error.message.contains("exit code"))
    }
}
