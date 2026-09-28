import Foundation

enum Content {
    static let hadith: [Hadith] = [
        Hadith(
            text: "Indeed there is a surah in the Qur'an of thirty verses which intercedes for a person until he is forgiven: “Blessed is He in Whose hand is the dominion, and He is over all things competent.”",
            source: "Sunan al-Tirmidhi 2880 · graded ḥasan"
        ),
        Hadith(
            text: "Whoever recites Surah al-Mulk every night, Allah will protect him from the punishment of the grave.",
            source: "Sunan Ibn Majah · Kitāb Faḍl al-Qur'ān"
        ),
        Hadith(
            text: "Ibn ‘Umar used to make his children read Surah al-Mulk when they went to bed, saying: “I heard the Messenger of Allah ﷺ say these words.”",
            source: "Sunan al-Tirmidhi 2880 · from Ibn ‘Umar"
        ),
        Hadith(
            text: "The Qur'an intercedes for its people on the Day of Resurrection — so let it be a companion of yours while you are awake, and a recitation before you sleep.",
            source: "Cf. Ṣaḥīḥ Muslim 800 · the Qur'an interceding for its reciters"
        )
    ]

    static let benefits: [Benefit] = [
        Benefit(
            title: "It intercedes for you",
            detail: "Thirty verses that argue in your favour until Allah forgives you — the greatest reason to keep it in your daily rotation."
        ),
        Benefit(
            title: "Protection from the grave",
            detail: "Nightly recitation is described as a shield from the punishment of the grave. A five-minute habit that follows you after death."
        ),
        Benefit(
            title: "The habit of the Companions",
            detail: "Ibn ‘Umar taught it to his children at bedtime. The same surah the Prophet ﷺ spoke about is short enough to finish before sleep."
        ),
        Benefit(
            title: "It frames your day",
            detail: "Read in the evening, it settles the heart; read in the morning, it reminds you that life and death are a test you are passing through today."
        ),
        Benefit(
            title: "Deep reflection in few words",
            detail: "Creation of the heavens, the earth, death and life, ships sailing, rain falling — five short verses that carry a full argument for Allah's dominion."
        ),
        Benefit(
            title: "A realistic daily minimum",
            detail: "30 verses, around five minutes aloud. Even the Quick Pass — the last three lines — keeps the chain alive on heavy days."
        ),
        Benefit(
            title: "It lands you in Jannah",
            detail: "Whoever reads it every night will find it an argument on his behalf and a barrier between him and the punishment of Allah."
        )
    ]
}
