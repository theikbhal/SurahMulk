import SwiftUI

struct RootView: View {
    @EnvironmentObject var state: AppState

    var body: some View {
        NavigationSplitView {
            List(selection: $state.tab) {
                Section("Daily") {
                    ForEach([AppState.Tab.read, .quickPass, .streaks], id: \.self) { tab in
                        Label(tab.title, systemImage: tab.symbol).tag(tab)
                    }
                }
                Section("Study") {
                    ForEach([AppState.Tab.memorise, .vocab, .grammar, .translations, .learn, .fastRead], id: \.self) { tab in
                        Label(tab.title, systemImage: tab.symbol).tag(tab)
                    }
                }
                Section("More") {
                    ForEach([AppState.Tab.video, .quranWeb, .help], id: \.self) { tab in
                        Label(tab.title, systemImage: tab.symbol).tag(tab)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 190, ideal: 215)
        } detail: {
            detail
                .toolbar {
                    ToolbarItemGroup {
                        SettingsView()
                    }
                }
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch state.tab {
        case .read: ReadView()
        case .quickPass: QuickPassView()
        case .streaks: StreaksView()
        case .memorise: MemoriseView()
        case .vocab: VocabView()
        case .grammar: GrammarView()
        case .translations: TranslationsView()
        case .learn: LearnView()
        case .fastRead: FastReadView()
        case .video: VideoView()
        case .quranWeb: QuranWebView()
        case .help: HelpView()
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @State private var showing = false

    var body: some View {
        Button {
            showing = true
        } label: {
            Image(systemName: "gearshape")
        }
        .help("Settings")
        .sheet(isPresented: $showing) {
            SettingsPane()
                .environmentObject(state)
                .frame(width: 460, height: 430)
        }
    }
}
