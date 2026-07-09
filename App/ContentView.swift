import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UpdaterViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            HStack(alignment: .top, spacing: 22) {
                VStack(spacing: 16) {
                    updateCard
                    selectionCard
                }
                .frame(width: 360)

                logCard
            }
            .padding(24)
        }
        .frame(minWidth: 860, minHeight: 620)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("UpdatePilot")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                Text("Version 0.0.6 · macOS-Updates in einem ruhigen Ablauf")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if viewModel.isRunning {
                ProgressView()
                    .controlSize(.large)
                    .help("Update-Lauf läuft")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }

    private var updateCard: some View {
        card {
            VStack(alignment: .leading, spacing: 10) {
                Label("Update-Lauf", systemImage: "arrow.down.circle")
                    .font(.headline)

                Text(viewModel.statusText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: viewModel.startUpdates) {
                Label(
                    viewModel.isRunning ? "Updates laufen…" : "Updates starten",
                    systemImage: viewModel.isRunning ? "arrow.triangle.2.circlepath" : "play.fill"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.canStartUpdates)

            if viewModel.selectedSteps.isEmpty {
                Label("Wähle mindestens einen Bereich aus.", systemImage: "exclamationmark.triangle")
                    .font(.callout)
                    .foregroundStyle(.orange)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ausgewählt")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(viewModel.selectedSteps, id: \.self) { step in
                        Label(step, systemImage: "checkmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
        }
    }

    private var selectionCard: some View {
        card {
            Text("Bereiche")
                .font(.headline)

            toggleRow(
                title: "Homebrew",
                subtitle: "Aktualisieren, upgraden und anschließend aufräumen",
                systemImage: "shippingbox",
                isOn: $viewModel.selection.includeHomebrew
            )

            Divider()

            toggleRow(
                title: "Mac App Store",
                subtitle: "Apps mit mas aktualisieren, wenn mas installiert ist",
                systemImage: "app.badge",
                isOn: $viewModel.selection.includeMas
            )

            Divider()

            toggleRow(
                title: "macOS-Systemupdates",
                subtitle: "Nur verfügbare Updates anzeigen, ohne Installation oder Neustart",
                systemImage: "macbook.and.arrow.down",
                isOn: $viewModel.selection.includeSystemUpdateCheck
            )
        }
    }

    private var logCard: some View {
        card {
            HStack {
                Label("Protokoll", systemImage: "terminal")
                    .font(.headline)
                Spacer()
                if viewModel.isRunning {
                    Text("läuft")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.opacity(0.12), in: Capsule())
                        .foregroundStyle(.blue)
                }
            }

            ScrollViewReader { proxy in
                ScrollView {
                    Text(viewModel.logText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .id("log-bottom")
                        .padding(14)
                }
                .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.quaternary, lineWidth: 1)
                )
                .onChange(of: viewModel.logText) { _, _ in
                    proxy.scrollTo("log-bottom", anchor: .bottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toggleRow(title: String, subtitle: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.medium))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .toggleStyle(.switch)
        .disabled(viewModel.isRunning)
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
