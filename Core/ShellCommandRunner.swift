import Foundation

public final class ShellCommandRunner {
    public init() {}

    public func run(command: String, onOutput: @escaping @Sendable (String) -> Void) async -> Int32 {
        await withCheckedContinuation { continuation in
            let process = Process()
            let pipe = Pipe()

            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-lc", command]
            process.standardOutput = pipe
            process.standardError = pipe

            pipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                guard !data.isEmpty, let output = String(data: data, encoding: .utf8) else { return }
                onOutput(output)
            }

            process.terminationHandler = { process in
                pipe.fileHandleForReading.readabilityHandler = nil
                let remaining = pipe.fileHandleForReading.readDataToEndOfFile()
                if !remaining.isEmpty, let output = String(data: remaining, encoding: .utf8) {
                    onOutput(output)
                }
                continuation.resume(returning: process.terminationStatus)
            }

            do {
                try process.run()
            } catch {
                pipe.fileHandleForReading.readabilityHandler = nil
                onOutput("Konnte Update-Prozess nicht starten: \\(error.localizedDescription)\\n")
                continuation.resume(returning: 127)
            }
        }
    }
}
