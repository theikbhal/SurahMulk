import Foundation

final class SurahStore: ObservableObject {
    let data: SurahData

    init() {
        data = SurahStore.load()
    }

    var ayahs: [Ayah] { data.ayahs }

    lazy var vocabulary: VocabularyIndex = VocabularyIndex(ayahs: data.ayahs)

    func ayah(_ n: Int) -> Ayah? {
        data.ayahs.first { $0.n == n }
    }

    static func load() -> SurahData {
        for url in candidates() {
            guard let raw = try? Data(contentsOf: url),
                  let decoded = try? JSONDecoder().decode(SurahData.self, from: raw)
            else { continue }
            return decoded
        }
        print("mulk.json missing — run scripts/fetch_data.py and rebuild")
        fatalError("mulk.json missing — run scripts/fetch_data.py")
    }

    /// App-bundle copy first (what scripts/build_app.sh installs), then the SwiftPM resource bundle.
    /// Never touches a development path outside the app bundle.
    private static func candidates() -> [URL] {
        var urls: [URL] = []
        if let url = Bundle.main.url(forResource: "mulk", withExtension: "json") {
            urls.append(url)
        }
        if let url = Bundle.main.url(
            forResource: "mulk",
            withExtension: "json",
            subdirectory: "SurahMulk_SurahMulk.bundle"
        ) {
            urls.append(url)
        }
        if let resource = Bundle.main.resourceURL {
            urls.append(resource.appendingPathComponent("SurahMulk_SurahMulk.bundle/mulk.json"))
        }
        if let built = Bundle.main.path(forResource: "SurahMulk_SurahMulk", ofType: "bundle") {
            urls.append(URL(fileURLWithPath: built).appendingPathComponent("mulk.json"))
        }
        return urls
    }
}
