import AppKit
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = UpdaterViewModel()
    @State private var showsLog = false

    var body: some View {
        ZStack {
            atmosphericBackground

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 18) {
                        statusHero

                        HStack(alignment: .top, spacing: 18) {
                            updatePlanCard
                            selectionCard
                        }

                        timelineCard
                        errorCard
                        logDisclosure
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                footer
            }
        }
        .frame(minWidth: 760, minHeight: 720)
        .animation(.snappy(duration: 0.32), value: viewModel.phase)
        .animation(.snappy(duration: 0.32), value: showsLog)
    }

    private var atmosphericBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color.blue.opacity(0.14),
                    Color.purple.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.blue.opacity(0.20))
                .frame(width: 360, height: 360)
                .blur(radius: 80)
                .offset(x: -280, y: -220)

            Circle()
                .fill(.purple.opacity(0.16))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: 300, y: 260)
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.18), radius: 18, y: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text("UpdatePilot")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                Text("Deine Updates in einem klaren Ablauf.")
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
        .padding(.vertical, 20)
    }

    private var statusHero: some View {
        surfaceCard(padding: 24) {
            HStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(heroTint.opacity(0.16))
                        .frame(width: 126, height: 126)
                    Circle()
                        .stroke(heroTint.opacity(0.30), lineWidth: 1)
                        .frame(width: 126, height: 126)
                    Circle()
                        .stroke(.white.opacity(0.22), lineWidth: 1)
                        .frame(width: 104, height: 104)

                    Image(systemName: heroIcon)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(heroTint)
                        .symbolEffect(.pulse, isActive: viewModel.isRunning)
                }
                .shadow(color: heroTint.opacity(0.22), radius: 26, y: 12)

                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.heroTitle)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    Text(viewModel.heroSubtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        Label(viewModel.updatePlan.durationText, systemImage: "clock")
                        Label("Details auf Wunsch", systemImage: "text.alignleft")
                    }
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var updatePlanCard: some View {
        surfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader("Update-Plan", systemImage: "list.bullet.clipboard")

                if viewModel.updatePlan.summaryRows.isEmpty {
                    Label("Wähle mindestens einen Bereich aus.", systemImage: "exclamationmark.triangle")
                        .font(.callout)
                        .foregroundStyle(.orange)
                } else {
                    VStack(spacing: 10) {
                        ForEach(viewModel.updatePlan.summaryRows) { row in
                            HStack(spacing: 12) {
                                Image(systemName: row.systemImage)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 26)
                                Text(row.title)
                                    .font(.body.weight(.medium))
                                Spacer()
                                Text(row.value)
                                    .font(.system(.title3, design: .rounded, weight: .semibold))
                                    .foregroundStyle(heroTint)
                            }
                            .padding(12)
                            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }

                    Divider().opacity(0.5)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.selectedSteps, id: \.self) { step in
                            Label(step, systemImage: "checkmark.circle.fill")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var selectionCard: some View {
        surfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader("Bereiche", systemImage: "slider.horizontal.3")

                toggleRow(
                    title: "Homebrew",
                    subtitle: "Pakete und Casks aktualisieren, danach aufräumen",
                    systemImage: "shippingbox",
                    isOn: $viewModel.selection.includeHomebrew
                )

                Divider().opacity(0.5)

                toggleRow(
                    title: "Mac App Store",
                    subtitle: "Apps mit mas aktualisieren, wenn mas installiert ist",
                    systemImage: "app.badge",
                    isOn: $viewModel.selection.includeMas
                )

                Divider().opacity(0.5)

                toggleRow(
                    title: "macOS-Systemupdates",
                    subtitle: "Verfügbare Updates anzeigen, ohne Installation oder Neustart",
                    systemImage: "macbook.and.arrow.down",
                    isOn: $viewModel.selection.includeSystemUpdateCheck
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var timelineCard: some View {
        surfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader("Ablauf", systemImage: "point.topleft.down.curvedto.point.bottomright.up")

                VStack(spacing: 0) {
                    ForEach(UpdateStep.allCases) { step in
                        timelineRow(step)
                        if step != UpdateStep.allCases.last {
                            timelineConnector(after: step)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var errorCard: some View {
        if let error = viewModel.friendlyError {
            surfaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label(error.title, systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Text(error.message)
                        .foregroundStyle(.secondary)
                    Text(error.recoverySuggestion)
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Button("Erneut versuchen", action: viewModel.retryUpdates)
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.canStartUpdates)
                }
            }
        }
    }

    private var logDisclosure: some View {
        surfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                Button {
                    showsLog.toggle()
                } label: {
                    HStack {
                        Label("Protokoll", systemImage: "terminal")
                            .font(.headline)
                        Spacer()
                        Text(showsLog ? "Ausblenden" : "Anzeigen")
                            .font(.callout.weight(.medium))
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(showsLog ? 180 : 0))
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if showsLog {
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
                        .frame(minHeight: 180, maxHeight: 260)
                        .background(.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.white.opacity(0.10), lineWidth: 1)
                        )
                        .onChange(of: viewModel.logText) { _, _ in
                            proxy.scrollTo("log-bottom", anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Text(viewModel.statusText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Button("Details") {
                showsLog.toggle()
            }
            .disabled(viewModel.logText.isEmpty)

            Button(action: viewModel.startUpdates) {
                Label(viewModel.isRunning ? "Updates laufen…" : "Update starten", systemImage: viewModel.isRunning ? "arrow.triangle.2.circlepath" : "play.fill")
                    .frame(minWidth: 150)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.canStartUpdates)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }

    private var heroTint: Color {
        switch viewModel.phase {
        case .ready:
            return viewModel.updatePlan.isEmpty ? .secondary : .blue
        case .running:
            return .blue
        case .completed:
            return .green
        case .failed:
            return .orange
        }
    }

    private var heroIcon: String {
        switch viewModel.phase {
        case .ready:
            return viewModel.updatePlan.isEmpty ? "checkmark.circle" : "arrow.down.circle.fill"
        case .running:
            return "arrow.triangle.2.circlepath"
        case .completed:
            return "checkmark.circle.fill"
        case .failed:
            return "exclamationmark.triangle.fill"
        }
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
            .foregroundStyle(.primary)
    }

    private func timelineRow(_ step: UpdateStep) -> some View {
        let state = viewModel.progress.state(for: step)

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(timelineColor(for: state).opacity(state == .pending ? 0.10 : 0.18))
                    .frame(width: 34, height: 34)
                Image(systemName: timelineIcon(for: state, step: step))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(timelineColor(for: state))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.body.weight(state == .current ? .semibold : .regular))
                Text(timelineCaption(for: state))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 5)
    }

    private func timelineConnector(after step: UpdateStep) -> some View {
        let state = viewModel.progress.state(for: step)
        return HStack(spacing: 14) {
            Rectangle()
                .fill(state == .completed ? Color.green.opacity(0.45) : Color.secondary.opacity(0.18))
                .frame(width: 2, height: 18)
                .frame(width: 34)
            Spacer()
        }
    }

    private func timelineIcon(for state: UpdateStepState, step: UpdateStep) -> String {
        switch state {
        case .completed:
            return "checkmark"
        case .current:
            return step.systemImage
        case .pending:
            return "circle"
        }
    }

    private func timelineColor(for state: UpdateStepState) -> Color {
        switch state {
        case .completed:
            return .green
        case .current:
            return .blue
        case .pending:
            return .secondary
        }
    }

    private func timelineCaption(for state: UpdateStepState) -> String {
        switch state {
        case .completed:
            return "Erledigt"
        case .current:
            return "Läuft gerade"
        case .pending:
            return "Wartet"
        }
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

    private func surfaceCard<Content: View>(padding: CGFloat = 20, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 22, y: 12)
    }
}

#Preview {
    ContentView()
}
