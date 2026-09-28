import SwiftUI
import WebKit

/// Thin WKWebView wrapper — used by the Quran.com tab and the in-app video player.
struct WebView: NSViewRepresentable {
    let url: URL
    var reloadToken: Int = 0

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        guard reloadToken > 0 else { return }
        if webView.url?.absoluteString != url.absoluteString {
            webView.load(URLRequest(url: url))
        }
    }
}
