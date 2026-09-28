import SwiftUI
import AppKit
import WebKit

struct VideoView: View {
    @EnvironmentObject var store: SurahStore
    @State private var inApp = false

    private var videoURL: URL { URL(string: store.data.video)! }
    private var thumb: URL {
        URL(string: "https://img.youtube.com/vi/JwXN2fnc8Uk/hqdefault.jpg")!
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                card

                if inApp {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Playing in app")
                                .font(.headline)
                            Spacer()
                            Button("Open in YouTube") { NSWorkspace.shared.open(videoURL) }
                            Button("Close") { inApp = false }
                        }
                        EmbeddedVideo(url: videoURL)
                            .frame(height: 460)
                    }
                    .padding(20)
                    .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
                }
            }
            .padding(28)
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recitation video")
                .font(.title2.bold())

            AsyncImage(url: thumb) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    placeholder
                case .empty:
                    ZStack {
                        Color.black.opacity(0.7)
                        ProgressView().tint(.white)
                    }
                @unknown default:
                    placeholder
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(alignment: .center) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(radius: 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Surah Al-Mulk full · By Sheikh Sudais with Arabic text (HD)")
                    .font(.headline)
                Text(store.data.video)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 12) {
                Button {
                    NSWorkspace.shared.open(videoURL)
                } label: { Label("Watch on YouTube", systemImage: "play.fill") }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)

                Button {
                    inApp = true
                } label: { Label("Play in app", systemImage: "rectangle.expand.vertical") }
                    .buttonStyle(.bordered)

                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(store.data.video, forType: .string)
                } label: { Label("Copy link", systemImage: "link") }
                    .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private var placeholder: some View {
        ZStack {
            Color.black.opacity(0.7)
            Image(systemName: "film")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

private struct EmbeddedVideo: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {}
}
