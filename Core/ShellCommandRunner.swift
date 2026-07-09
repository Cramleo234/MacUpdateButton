import Foundation

public final class ShellCommandRunner {
    public init() {}

    public func run(command: String, onOutput: @escaping @Sendable (String) -> Void) async -> Int32 {
        await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: ShellCommandFactory.executablePath)
            process.arguments = ShellCommandFactory.arguments(for: command)

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            let emitData: @Sendable (Data) -> Void = { data in
                guard !data.isEmpty, let text = String(data: data, encoding: .utf8), !text.isEmpty else {
                    return
                }
                onOutput(text)
            }

            outputPipe.fileHandleForReading.readabilityHandler = { handle in
                emitData(handle.availableData)
            }
            errorPipe.fileHandleForReading.readabilityHandler = { handle in
                emitData(handle.availableData)
            }

            process.terminationHandler = { finishedProcess in
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil
                emitData(outputPipe.fileHandleForReading.readDataToEndOfFile())
                emitData(errorPipe.fileHandleForReading.readDataToEndOfFile())
                continuation.resume(returning: finishedProcess.terminationStatus)
            }

            do {
                try process.run()
            } catch {
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil
                onOutput("Konnte Update-Lauf nicht starten: \(error.localizedDescription)\n")
                continuation.resume(returning: 127)
            }
        }
    }
}

public enum ShellCommandFactory {
    public static let executablePath = "/bin/zsh"

    public static func arguments(for command: String) -> [String] {
        ["-lc", command]
    }
}
