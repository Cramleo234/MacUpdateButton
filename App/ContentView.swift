import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UpdaterViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.cyan.opacity(0.22), Color.blue.opacity(0.20), Color.indigo.opacity(0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                header
                updateCard
                logView
            }
            .padding(28)
        }
    }

    private var header: some View {
        HStack(spacing: 16) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(radius: 10, y: 5)

            VStack(alignment: .leading, spacing: 8) {
                Text("UpdatePilot")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Text("Version 0.0.2 · Ein sicherer Knopf für deine macOS-Softwareupdates")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var updateCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 18) {
                Button(action: viewModel.startUpdates) {
                    Label(viewModel.isRunning ? "Updates laufen…" : "Updates starten", systemImage: viewModel.isRunning ? "arrow.triangle.2.circlepath" : "arrow.down.circle.fill")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.canStartUpdates)

                if viewModel.isRunning {
                    ProgressView()
                        .controlSize(.large)
                }
            }

            Text(viewModel.statusText)
                .font(.callout)
                .foregroundStyle(.secondary)

            selectionPanel

            if viewModel.selectedSteps.isEmpty {
                Label("Wähle mindestens einen Bereich aus, bevor du startest.", systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ausgewählte Schritte")
                        .font(.headline)
                    ForEach(viewModel.selectedSteps, id: \.self) { step in
                        Label(step, systemImage: "checkmark.circle")
                            .font(.callout)
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        )
    }

    private var selectionPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Was soll aktualisiert werden?")
                .font(.headline)

            Toggle(isOn: $viewModel.selection.includeHomebrew) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Homebrew")
                        .font(.body.weight(.medium))
                    Text("brew update, brew upgrade und brew cleanup")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(viewModel.isRunning)

            Toggle(isOn: $viewModel.selection.includeMas) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Mac App Store")
                        .font(.body.weight(.medium))
                    Text("mas upgrade, falls mas installiert ist")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(viewModel.isRunning)

            Toggle(isOn: $viewModel.selection.includeSystemUpdateCheck) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("macOS-Systemupdates anzeigen")
                        .font(.body.weight(.medium))
                    Text("Nur prüfen/anzeigen – keine automatische Installation und kein Neustart")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(viewModel.isRunning)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var logView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Protokoll")
                .font(.headline)
            ScrollViewReader { proxy in
                ScrollView {
                    Text(viewModel.logText)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .id("log-bottom")
                        .padding(14)
                }
                .onChange(of: viewModel.logText) { _, _ in
                    proxy.scrollTo("log-bottom", anchor: .bottom)
                }
            }
            .background(Color.black.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    ContentView()
}
