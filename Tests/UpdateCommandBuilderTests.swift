import XCTest

final class UpdateCommandBuilderTests: XCTestCase {
    func testUpdateCommandContainsSafeVersionAndTools() {
        let command = UpdateCommandBuilder.updateCommand()

        XCTAssertTrue(command.contains("MacUpdateButton 0.0.1"))
        XCTAssertTrue(command.contains("brew update"))
        XCTAssertTrue(command.contains("brew upgrade"))
        XCTAssertTrue(command.contains("mas upgrade"))
        XCTAssertTrue(command.contains("softwareupdate -l"))
    }

    func testDisplayStepsExplainSystemUpdateBehavior() {
        XCTAssertTrue(UpdateCommandBuilder.displaySteps.contains { $0.contains("anzeigen") })
        XCTAssertFalse(UpdateCommandBuilder.updateCommand().contains("softwareupdate -i -a"))
    }
}
