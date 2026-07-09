import Foundation

public final class ShellCommandRunner {
    public init() {}

    public func run(command: String, onOutput: @escaping @Sendable (String) -> Void) async -> Int32 {
        let fileManager = FileManager.default
        let runDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("UpdatePilot")
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let scriptURL = runDirectory.appendingPathComponent("run-updatepilot.sh")

        do {
            try fileManager.createDirectory(at: runDirectory, withIntermediateDirectories: true)
            try TerminalScriptFactory.scriptBody(for: command).write(to: scriptURL, atomically: true, encoding: .utf8)
            try fileManager.setAttributes([.posixPermissions: 0o700], ofItemAtPath: scriptURL.path)
        } catch {
            onOutput("Konnte das Terminal-Skript nicht vorbereiten: \\(error.localizedDescription)\\n")
            return 127
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", "Terminal", scriptURL.path]

        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus == 0 {
                onOutput("Terminalfenster geöffnet. Passwortabfragen können dort beantwortet werden.\\n")
            } else {
                onOutput("Terminal konnte nicht geöffnet werden. Exit-Code: \\(process.terminationStatus)\\n")
            }
            return process.terminationStatus
        } catch {
            onOutput("Konnte Terminal nicht öffnen: \\(error.localizedDescription)\\n")
            return 127
        }
    }
}

public enum TerminalScriptFactory {
    public static func scriptBody(for command: String) -> String {
        """
        #!/bin/zsh
        clear
        echo '== UpdatePilot: interaktiver Update-Lauf =='
        echo 'Wenn macOS ein Passwort verlangt, kannst du es hier im Terminal eingeben.'
        echo
        \(command)
        status=$?
        echo
        echo "UpdatePilot beendet mit Exit-Code: $status"
        echo 'Dieses Terminalfenster kann geschlossen werden.'
        exit $status
        """
    }
}
