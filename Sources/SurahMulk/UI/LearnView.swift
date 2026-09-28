import SwiftUI

/// Hadith about Surah Al-Mulk and its benefits.
struct LearnView: View {
    @State private var showBenefits = true
    @State private var showHadith = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                disclosure("Hadith on Surah Mulk", "text.quote", $showHadith) {
                    VStack(spacing: 12) {
                        ForEach(Content.hadith) { item in
                            hadithCard(item)
                        }
                    }
                }

                disclosure("Benefits of Surah Mulk", "sparkles", $showBenefits) {
                    VStack(spacing: 12) {
                        ForEach(Content.benefits) { item in
                            benefitCard(item)
                        }
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 860)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hadith & benefits")
                .font(.title2.bold())
            Text("Why this surah deserves a place in your evening — with the sources.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private func disclosure(_ title: String, _ symbol: String, _ binding: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { binding.wrappedValue.toggle() }
            } label: {
                HStack {
                    Image(systemName: symbol)
                        .foregroundStyle(.green)
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Image(systemName: binding.wrappedValue ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if binding.wrappedValue {
                content()
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 14).fill(.quaternary.opacity(0.25)))
    }

    private func hadithCard(_ item: Hadith) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.text)
                .font(.body.italic())
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Spacer()
                Text(item.source)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(.green.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.25)))
    }

    private func benefitCard(_ item: Benefit) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(.quaternary.opacity(0.2)))
    }
}
