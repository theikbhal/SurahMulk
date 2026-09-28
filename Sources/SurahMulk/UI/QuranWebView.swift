import SwiftUI
import WebKit

struct QuranWebView: View {
    @EnvironmentObject var store: SurahStore
    @State private var reloadToken = 0
    @State private var inApp = true

    private var url: URL { URL(string: store.data.web) ?? URL(string: "https://quran.com")! }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("quran.com/al-mulk", systemImage: "globe")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("In app", isOn: $inApp)
                    .toggleStyle(.checkbox)
                Button {
                    reloadToken += 1
                } label: { Image(systemName: "arrow.clockwise") }
                    .help("Reload")
                Button {
                    NSWorkspace.shared.open(url)
                } label: { Label("Open in browser", systemImage: "safari") }
            }
            .padding(12)
            .background(.bar)

            Divider()

            if inApp {
                WebView(url: url, reloadToken: reloadToken)
            } else {
                VStack(spacing: 10) {
                    Text("In-app view is off")
                        .font(.headline)
                    Text("Turn on “In app” to read quran.com here, or open it in your browser.")
                        .foregroundStyle(.secondary)
                    Button("Open in browser") { NSWorkspace.shared.open(url) }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
