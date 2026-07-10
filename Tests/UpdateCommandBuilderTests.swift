import XCTest

final class UpdateCommandBuilderTests: XCTestCase {
    func testUpdateCommandContainsSafeVersionAndDefaultTools() {
        let command = UpdateCommandBuilder.updateCommand()

        XCTAssertTrue(command.contains("UpdatePilot 0.1.1"))
        XCTAssertTrue(command.contains("brew update"))
        XCTAssertTrue(command.contains("brew upgrade"))
        XCTAssertTrue(command.contains("mas upgrade"))
        XCTAssertTrue(command.contains("softwareupdate -l"))
    }

    func testDisplayStepsExplainSystemUpdateBehavior() {
        let steps = UpdateCommandBuilder.displaySteps()

        XCTAssertTrue(steps.contains { $0.contains("anzeigen") })
        XCTAssertFalse(UpdateCommandBuilder.updateCommand().contains("softwareupdate -i -a"))
    }

    func testCommandRespectsDisabledHomebrewAndMasOptions() {
        let selection = UpdateSelection(includeHomebrew: false, includeMas: false, includeSystemUpdateCheck: true)
        let command = UpdateCommandBuilder.updateCommand(selection: selection)

        XCTAssertFalse(command.contains("brew update"))
        XCTAssertFalse(command.contains("mas upgrade"))
        XCTAssertTrue(command.contains("softwareupdate -l"))
        XCTAssertTrue(command.contains("Homebrew wurde abgewählt"))
        XCTAssertTrue(command.contains("Mac-App-Store-Updates wurden abgewählt"))
    }

    func testCommandCanOnlyRunSelectedHomebrewStep() {
        let selection = UpdateSelection(includeHomebrew: true, includeMas: false, includeSystemUpdateCheck: false)
        let command = UpdateCommandBuilder.updateCommand(selection: selection)

        XCTAssertTrue(command.contains("brew update"))
        XCTAssertFalse(command.contains("mas upgrade"))
        XCTAssertFalse(command.contains("softwareupdate -l"))
    }

    func testSelectionDetectsEmptyChoice() {
        XCTAssertFalse(UpdateSelection(includeHomebrew: false, includeMas: false, includeSystemUpdateCheck: false).hasAnySelection)
        XCTAssertTrue(UpdateSelection(includeHomebrew: true, includeMas: false, includeSystemUpdateCheck: false).hasAnySelection)
    }

    func testShellCommandRunsThroughZshWithoutOpeningTerminal() {
        let arguments = ShellCommandFactory.arguments(for: "echo test")

        XCTAssertEqual(ShellCommandFactory.executablePath, "/bin/zsh")
        XCTAssertEqual(arguments, ["-lc", "echo test"])
        XCTAssertFalse(arguments.contains("Terminal"))
    }
}
