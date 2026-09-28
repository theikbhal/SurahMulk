import SwiftUI

struct TranslationsView: View {
    @EnvironmentObject var store: SurahStore
    @EnvironmentObject var state: AppState

    enum Flavor: String, CaseIterable, Identifiable {
        case english, urdu, telugu, sideBySide
        var id: String { rawValue }

        var title: String {
            switch self {
            case .english: "English"
            case .urdu: "اردو"
            case .telugu: "తెలుగు"
            case .sideBySide: "Side by side"
            }
        }
    }

    @State private var flavor: Flavor = .english

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Translation", selection: $flavor) {
                    ForEach(Flavor.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 480)

                Spacer()

                Text("Saheeh English · Junagarhi Urdu · Abder-Rahim Telugu")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.bar)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(store.ayahs) { ayah in
                        block(ayah)
                    }
                }
                .padding(26)
                .frame(maxWidth: 940)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private func block(_ ayah: Ayah) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ayah.ar)
                .font(.system(size: 24, weight: .medium))
                .environment(\.layoutDirection, .rightToLeft)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)

            switch flavor {
            case .english:
                line("EN", ayah.en, .primary)
            case .urdu:
                line("UR", ayah.ur, .primary)
                .environment(\.layoutDirection, .rightToLeft)
            case .telugu:
                line("TE", ayah.tel, .primary)
            case .sideBySide:
                HStack(alignment: .top, spacing: 14) {
                    column("English", ayah.en)
                    column("اردو", ayah.ur)
                    column("తెలుగు", ayah.tel)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(.quaternary.opacity(0.2)))
        .onTapGesture {
            state.readAyah = ayah.n
        }
    }

    private func line(_ tag: String, _ text: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(tag)
                .font(.caption2.bold())
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(.green.opacity(0.2)))
            Text(text)
                .font(.body)
                .foregroundStyle(color)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func column(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Text(text)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
