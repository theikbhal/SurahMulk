import Foundation

struct Word: Codable, Hashable {
    let ar: String
    let en: String
    let tr: String
    let audio: String
    var root: String = ""
    var pre: [String] = []
    var suf: [String] = []
    var irab: [String] = []
    var sarf: [String] = []
    var count: [String] = []

    private enum CodingKeys: String, CodingKey {
        case ar, en, tr, audio, root, pre, suf, irab, sarf, count
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ar = try c.decode(String.self, forKey: .ar)
        en = try c.decodeIfPresent(String.self, forKey: .en) ?? ""
        tr = try c.decodeIfPresent(String.self, forKey: .tr) ?? ""
        audio = try c.decodeIfPresent(String.self, forKey: .audio) ?? ""
        root = try c.decodeIfPresent(String.self, forKey: .root) ?? ""
        pre = try c.decodeIfPresent([String].self, forKey: .pre) ?? []
        suf = try c.decodeIfPresent([String].self, forKey: .suf) ?? []
        irab = try c.decodeIfPresent([String].self, forKey: .irab) ?? []
        sarf = try c.decodeIfPresent([String].self, forKey: .sarf) ?? []
        count = try c.decodeIfPresent([String].self, forKey: .count) ?? []
    }

    init(ar: String, en: String, tr: String, audio: String) {
        self.ar = ar
        self.en = en
        self.tr = tr
        self.audio = audio
    }
}

struct Ayah: Codable, Hashable, Identifiable {
    var id: Int { n }
    let n: Int
    let ar: String
    let en: String
    let ur: String
    let tel: String
    let audio: String
    let words: [Word]
}

struct WordStat: Codable, Hashable {
    let form: String
    let count: Int
}

struct SurahStats: Codable, Hashable {
    let total: Int
    let unique: Int
    let repeated: Int
    let top: [WordStat]
}

struct SurahData: Codable {
    let surah: Int
    let name: String
    let nameArabic: String
    let nameMeaning: String
    let revelation: String
    let totalAyahs: Int
    let basmala: String
    let video: String
    let web: String
    let stats: SurahStats
    let ayahs: [Ayah]
}

struct Hadith: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let source: String
}

struct Benefit: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
}
