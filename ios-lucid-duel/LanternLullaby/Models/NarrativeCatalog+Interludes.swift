import Foundation

/// The waking world between chapters.
///
/// A chapter of the book ends in the dream; the morning after belongs to
/// the dreamer. These scenes are the breath between books-within-the-book:
/// the child wakes, carries something back, and the shop is still there on
/// the corner. They play once, after the chapter's last page falls, before
/// the map comes back.
///
/// Keep them short — three to six lines — and keep them in the bedroom or
/// the bookshop. The dream has its own drama; this is where it lands.
/// Not `nonisolated`: these scenes reach `PortraitRegistry`, which is
/// main-actor like the rest of the narrative layer.
enum NarrativeCatalogInterludes {

    /// The scenes to play after clearing chapter `index` (0-based), or nil
    /// when that chapter has no waking-world beat of its own.
    static func interlude(afterChapter index: Int) -> [StoryScene]? {
        switch index {
        case 0: return [afterTheSwordScene]
        case 1: return [afterOrkneyScene]
        case 2: return [afterTheTournamentScene]
        case 3: return [afterCamlannScene]
        case 4: return [afterTheLastLessonScene, theShelfScene]
        default: return nil
        }
    }

    /// Every interlude in order, for the journal.
    static var allInterludes: [(chapterIndex: Int, scenes: [StoryScene])] {
        (0..<5).compactMap { index in
            interlude(afterChapter: index).map { (index, $0) }
        }
    }

    // MARK: - Chapter 1 — the sword in the stone

    static let afterTheSwordScene = StoryScene(
        backgroundImage: "bg_bedroom_morning",
        lines: [
            .narrator("Morning. The book is closed on the blanket, exactly where it was."),
            .mcThought("A boy pulled a sword out of a stone last night. And I was there. I helped."),
            .narrator("Downstairs, someone is making toast. The radiator ticks. Everything is ordinary."),
            .mcThought("Nobody here knows I know a king."),
            .mcThought("I'll go back tonight. There's more."),
        ],
        transitionStyle: .fade
    )

    // MARK: - Chapter 2 — the queen of air and darkness

    static let afterOrkneyScene = StoryScene(
        backgroundImage: "bg_bedroom_morning",
        lines: [
            .narrator("You wake with your hands closed, as if you were holding something."),
            .mcThought("She looked at me like she was reading a page I hadn't written yet."),
            .mcThought("Mom asked if I slept okay. I said yes. It's true, mostly."),
            .narrator("The lantern on the nightstand is cold. It has been cold all night. Of course it has."),
            .mcThought("...Then why is the glass warm?"),
        ],
        transitionStyle: .fade
    )

    // MARK: - Chapter 3 — the ill-made knight

    static let afterTheTournamentScene = StoryScene(
        backgroundImage: "bg_bookstore",
        lines: [
            .narrator("Saturday. The bell over the shop door makes its odd, soft sound."),
            DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                         text: "Ah. You're at the tournaments. How is Lancelot treating you?"),
            .mcThought("He won everything. He looked miserable the whole time."),
            DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                         text: "Winning and being happy are two different skills. Most people only practise one."),
            DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                         text: "Keep reading. The next part is the hard one. You'll want the lantern lit."),
        ],
        transitionStyle: .fade
    )

    // MARK: - Chapter 4 — the candle in the wind

    static let afterCamlannScene = StoryScene(
        backgroundImage: "bg_bedroom_morning",
        lines: [
            .narrator("You lie still for a while before you open your eyes."),
            .mcThought("I've read this part before, in the old book at school. I knew how it ended."),
            .mcThought("I thought knowing would make it easier."),
            .narrator("Outside, a car door. A dog. Somebody's morning starting the way mornings do."),
            .mcThought("One chapter left. I'm not going to leave him there alone."),
        ],
        transitionStyle: .fade
    )

    // MARK: - Chapter 5 — the once and future king

    static let afterTheLastLessonScene = StoryScene(
        backgroundImage: "bg_bedroom_morning",
        lines: [
            .narrator("The last page turns itself, the way the first one did."),
            .mcThought("Rex Quondam, Rexque Futurus. The Once and Future King."),
            .mcThought("It means he comes back. It means the story isn't over — it's just waiting."),
            .narrator("You close the book. The lantern's flame settles to a steady, patient gold."),
        ],
        transitionStyle: .fade
    )

    static let theShelfScene = StoryScene(
        backgroundImage: "bg_bookstore",
        lines: [
            DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                         text: "One down. How do you feel?"),
            .mcThought("Like I could go back any time I wanted."),
            DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                         text: "That's exactly right. That's what a book is."),
            .narrator("He turns to the shelf behind him. There are a great many books on it."),
            DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                         text: "Come back when you're ready for the next one. Bring the lantern."),
        ],
        transitionStyle: .fade
    )
}
