import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UpdaterViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.22), Color.indigo.opacity(0.18), Color.black.opacity(0.08)],
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
        VStack(alignment: .leading, spacing: 8) {
            Text("MacUpdateButton")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Version 0.0.1 · Ein Knopf für deine macOS-Softwareupdates")
                .font(.headline)
                .foregroundStyle(.secondary)
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
                .disabled(viewModel.isRunning)

                if viewModel.isRunning {
                    ProgressView()
                        .controlSize(.large)
                }
            }

            Text(viewModel.statusText)
                .font(.callout)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(UpdateCommandBuilder.displaySteps, id: \.self) { step in
                    Label(step, systemImage: "checkmark.circle")
                        .font(.callout)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        )
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
