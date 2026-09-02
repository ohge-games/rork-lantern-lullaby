import Foundation

/// The bookshop prologue, shown once before the first chapter: moving day,
/// Pages & Embers, and the first night with the book.
extension NarrativeCatalogBook1 {

    static let prologueScenes: [StoryScene] = [
        StoryScene(
            backgroundImage: "bg_bedroom_morning",
            lines: [
                .narrator("Moving is hard."),
                .narrator("Everything you knew is somewhere else now. Your friends. Your room. The way the light came through your window in the morning."),
                .narrator("Your parents say you'll make new friends. That you'll love it here eventually. They mean well. But when you're young, \"eventually\" feels like forever."),
                .narrator("So you walk. Because walking is better than unpacking."),
                .narrator("And sometimes, when you're not looking for anything at all... you find exactly what you need."),
            ],
            transitionStyle: .fade
        ),
        StoryScene(
            backgroundImage: "bg_bookstore",
            lines: [
                .narrator("A narrow alley. At the end, a small shop with a hand-painted sign: PAGES & EMBERS — Books & Curiosities."),
                .mcThought("Hello? Is anyone..."),
                DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                             text: "I'm always here. Though \"here\" is somewhat flexible."),
                DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                             text: "You're new here. I can tell. You have that look — the one that says \"I don't belong anywhere yet.\""),
                DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                             text: "But here's a secret, young one: nobody belongs anywhere at first. Belonging is something you build. Story by story. Dream by dream."),
                .narrator("He pulls a book from the shelf. Leather-bound. The cover shows a sword thrust into a stone. The title, in faded gold: THE ONCE AND FUTURE KING."),
                DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                             text: "This one's been waiting for you. You'll need this too."),
                .narrator("A small brass lantern. The moment your fingers close around it, the flame sparks to life by itself."),
                DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                             text: "Ah. Good. It likes you. Read the first chapter before bed tonight. Light the lantern when you do."),
                DialogueLine(speakerName: "Shopkeeper", speakerPortrait: PortraitRegistry.shopkeeperPortrait,
                             text: "And remember: in dreams, nothing is quite what it seems. Not even you."),
            ],
            transitionStyle: .fade
        ),
        StoryScene(
            backgroundImage: "bedroom_night_storybook",
            lines: [
                .narrator("Your new room is full of boxes you haven't unpacked. Unfamiliar shadows. Strange shapes."),
                .narrator("But the book sits on your pillow. The lantern glows on your nightstand."),
                .mcThought("I can't explain it, but it feels like the book is waiting."),
                .narrator("In the beginning, there was a boy who didn't know he was a king."),
                .narrator("His name was Wart. He was small and overlooked and thought he would never be anyone special. He was wrong."),
                .narrator("This is his story. But now, it's also yours."),
                .narrator("Close your eyes. Open them in the dream."),
            ],
            transitionStyle: .dreamRipple
        ),
    ]

    /// The morning after the first night: the MC's first reflection.
    static let firstMorningScene = StoryScene(
        backgroundImage: "bg_bedroom_morning",
        lines: [
            .narrator("You wake with a gasp. Sunlight streams through unfamiliar curtains."),
            .narrator("The lantern sits on the nightstand — flame extinguished, metal cool. The book lies open on your chest."),
            .mcThought("It was just a dream."),
            .mcThought("...wasn't it?"),
        ]
    )
}
