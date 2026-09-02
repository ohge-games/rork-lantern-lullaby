import Foundation

/// Playable roster (Lancelot, Bedivere, Escanor, Merlin) and their fully
/// dedicated card pools.
///
/// Kept in its own file so the starter-set content in `CardCatalog.swift`
/// stays readable. Each hero owns a standalone pool — no neutral sharing —
/// so class identity comes through in the deck itself. Every card here sets
/// `heroID`, which is how `pool(for:)` and `starterDeck(for:)` find them
/// without hardcoding membership lists.
nonisolated extension CardCatalog {

    /// Stable hero identities. Fixed UUIDs (see `CardCatalog.stableID` for
    /// the rationale) keep hero→card and save→definition references stable
    /// across launches.
    nonisolated enum HeroIDs {
        static let wart       = CardCatalog.StarterIDs.wart
        static let archimedes = CardCatalog.StarterIDs.archimedes
        static let lancelot = UUID(uuidString: "B2000000-0000-4000-8000-000000000001")!
        static let bedivere = UUID(uuidString: "B3000000-0000-4000-8000-000000000001")!
        static let escanor  = UUID(uuidString: "B4000000-0000-4000-8000-000000000001")!
        static let merlin   = UUID(uuidString: "B5000000-0000-4000-8000-000000000001")!
        static let kay      = UUID(uuidString: "B6000000-0000-4000-8000-000000000001")!
        static let morgana  = UUID(uuidString: "B7000000-0000-4000-8000-000000000001")!
        static let galahad  = UUID(uuidString: "B8000000-0000-4000-8000-000000000001")!
    }

    private static func classID(_ uuidString: String) -> UUID {
        UUID(uuidString: uuidString) ?? UUID()
    }

    // MARK: - Lancelot — burst aggression (offensive, Vivid zone)

    static let lionsCharge = Card(
        id: classID("A2000000-0000-4000-8000-000000000001"),
        name: "Lion's Charge",
        text: "Deal 18 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 18)],
        heroID: HeroIDs.lancelot
    )

    static let twinSlash = Card(
        id: classID("A2000000-0000-4000-8000-000000000002"),
        name: "Twin Slash",
        text: "Deal 12 damage. Draw 1 card.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 12), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.lancelot
    )

    static let recklessAssault = Card(
        id: classID("A2000000-0000-4000-8000-000000000003"),
        name: "Reckless Assault",
        text: "Deal 14 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14)],
        heroID: HeroIDs.lancelot
    )

    static let battleTrance = Card(
        id: classID("A2000000-0000-4000-8000-000000000004"),
        name: "Battle Trance",
        text: "Draw 2 cards.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2)],
        heroID: HeroIDs.lancelot
    )

    static let steelGuard = Card(
        id: classID("A2000000-0000-4000-8000-000000000005"),
        name: "Steel Guard",
        text: "Gain 10 shield.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 10)],
        heroID: HeroIDs.lancelot
    )

    static let finalGambit = Card(
        id: classID("A2000000-0000-4000-8000-000000000006"),
        name: "Final Gambit",
        text: "Deal 25 damage.",
        lucidityCost: 7,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 25)],
        heroID: HeroIDs.lancelot
    )

    // Progression cards (7-15)
    
    static let lakesFury = Card(
        id: classID("A2000000-0000-4000-8000-000000000007"),
        name: "Lake's Fury",
        text: "Deal 20 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 20)],
        heroID: HeroIDs.lancelot
    )

    static let perfectParry = Card(
        id: classID("A2000000-0000-4000-8000-000000000008"),
        name: "Perfect Parry",
        text: "Gain 14 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 14)],
        heroID: HeroIDs.lancelot
    )

    static let relentlessAssault = Card(
        id: classID("A2000000-0000-4000-8000-000000000009"),
        name: "Relentless Assault",
        text: "Deal 22 damage.",
        lucidityCost: 8,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 22)],
        heroID: HeroIDs.lancelot
    )

    static let momentOfClarity = Card(
        id: classID("A2000000-0000-4000-8000-000000000010"),
        name: "Moment of Clarity",
        text: "Draw 2 cards. Gain 4 shield.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2), Effect(type: .shield, value: 4)],
        heroID: HeroIDs.lancelot
    )

    static let forbiddenLove = Card(
        id: classID("A2000000-0000-4000-8000-000000000011"),
        name: "Forbidden Love",
        text: "Heal 15 HP.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 15)],
        heroID: HeroIDs.lancelot
    )

    static let oathBreaker = Card(
        id: classID("A2000000-0000-4000-8000-000000000012"),
        name: "Oath Breaker",
        text: "Deal 18 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 18)],
        heroID: HeroIDs.lancelot
    )

    static let mirrorLake = Card(
        id: classID("A2000000-0000-4000-8000-000000000013"),
        name: "Mirror Lake",
        text: "Gain 12 shield. Heal 6 HP.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 12), Effect(type: .heal, value: 6)],
        heroID: HeroIDs.lancelot
    )

    static let firstKnight = Card(
        id: classID("A2000000-0000-4000-8000-000000000014"),
        name: "First Knight",
        text: "Deal 16 damage. Draw 1 card.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 16), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.lancelot
    )

    static let memoryOfTheLake = Card(
        id: classID("A2000000-0000-4000-8000-000000000015"),
        name: "Memory of the Lake",
        text: "Deal 20 damage. Heal 10 HP.",
        lucidityCost: 7,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 20), Effect(type: .heal, value: 10)],
        heroID: HeroIDs.lancelot
    )

    static let knightsChoice = Card(
        id: classID("A2000000-0000-4000-8000-000000000016"),
        name: "Knight's Choice",
        text: "Choose: Honor or Passion.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [],
        heroID: HeroIDs.lancelot,
        choices: [
            CardChoiceOption(
                id: "honor",
                name: "Honor",
                text: "Gain 12 shield · Draw 1 card",
                iconName: "shield.fill",
                effects: [
                    Effect(type: .shield, value: 12),
                    Effect(type: .drawCards, value: 1),
                ]
            ),
            CardChoiceOption(
                id: "passion",
                name: "Passion",
                text: "+4 Lucidity · Deal 18 damage",
                iconName: "flame.fill",
                effects: [
                    Effect(type: .lucidityModify, value: 4),
                    Effect(type: .damage, value: 18),
                ]
            ),
        ]
    )

    static let lancelotCards: [Card] = [
        lionsCharge, twinSlash, recklessAssault, battleTrance, steelGuard, finalGambit,
        lakesFury, perfectParry, relentlessAssault, momentOfClarity, forbiddenLove,
        oathBreaker, mirrorLake, firstKnight, memoryOfTheLake, knightsChoice,
    ]

    // MARK: - Bedivere — shields and sustain (defensive, Balanced zone)

    static let loyalGuard = Card(
        id: classID("A3000000-0000-4000-8000-000000000001"),
        name: "Loyal Guard",
        text: "Gain 14 shield. Draw 1 card.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 14), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.bedivere
    )

    static let swornOath = Card(
        id: classID("A3000000-0000-4000-8000-000000000002"),
        name: "Sworn Oath",
        text: "Gain 10 shield. Heal 6 health.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 10), Effect(type: .heal, value: 6)],
        heroID: HeroIDs.bedivere
    )

    static let counterstance = Card(
        id: classID("A3000000-0000-4000-8000-000000000003"),
        name: "Counterstance",
        text: "Deal 10 damage. Gain 8 shield.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .damage, value: 10), Effect(type: .shield, value: 8)],
        heroID: HeroIDs.bedivere
    )

    static let steadyBreath = Card(
        id: classID("A3000000-0000-4000-8000-000000000004"),
        name: "Steady Breath",
        text: "Heal 8 HP. Gain 4 shield.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 8), Effect(type: .shield, value: 4)],
        heroID: HeroIDs.bedivere
    )

    static let aegisWall = Card(
        id: classID("A3000000-0000-4000-8000-000000000005"),
        name: "Aegis Wall",
        text: "Gain 18 shield.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 18)],
        heroID: HeroIDs.bedivere
    )

    static let vigilStrike = Card(
        id: classID("A3000000-0000-4000-8000-000000000006"),
        name: "Vigil Strike",
        text: "Deal 12 damage.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 12)],
        heroID: HeroIDs.bedivere
    )

    // Progression cards (7-15)

    static let holdTheLine = Card(
        id: classID("A3000000-0000-4000-8000-000000000007"),
        name: "Hold the Line",
        text: "Gain 20 shield.",
        lucidityCost: 6,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 20)],
        heroID: HeroIDs.bedivere
    )

    static let kingsGuard = Card(
        id: classID("A3000000-0000-4000-8000-000000000008"),
        name: "King's Guard",
        text: "Gain 15 shield. Heal 5 HP.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 15), Effect(type: .heal, value: 5)],
        heroID: HeroIDs.bedivere
    )

    static let lastOfTheTable = Card(
        id: classID("A3000000-0000-4000-8000-000000000009"),
        name: "Last of the Table",
        text: "Gain 18 shield.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 18)],
        heroID: HeroIDs.bedivere
    )

    static let loyalStrike = Card(
        id: classID("A3000000-0000-4000-8000-000000000010"),
        name: "Loyal Strike",
        text: "Deal 14 damage. Gain 6 shield.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14), Effect(type: .shield, value: 6)],
        heroID: HeroIDs.bedivere
    )

    static let unshakeable = Card(
        id: classID("A3000000-0000-4000-8000-000000000011"),
        name: "Unshakeable",
        text: "Gain 10 shield. Heal 8 HP.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 10), Effect(type: .heal, value: 8)],
        heroID: HeroIDs.bedivere
    )

    static let oneArmedBlow = Card(
        id: classID("A3000000-0000-4000-8000-000000000012"),
        name: "One-Armed Blow",
        text: "Deal 16 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 16)],
        heroID: HeroIDs.bedivere
    )

    static let brothersInArms = Card(
        id: classID("A3000000-0000-4000-8000-000000000013"),
        name: "Brothers in Arms",
        text: "Heal 12 HP.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 12)],
        heroID: HeroIDs.bedivere
    )

    static let finalDuty = Card(
        id: classID("A3000000-0000-4000-8000-000000000014"),
        name: "Final Duty",
        text: "Gain 25 shield.",
        lucidityCost: 7,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 25)],
        heroID: HeroIDs.bedivere
    )

    static let returnToTheLake = Card(
        id: classID("A3000000-0000-4000-8000-000000000015"),
        name: "Return to the Lake",
        text: "Heal 18 HP. Gain 8 shield.",
        lucidityCost: 6,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 18), Effect(type: .shield, value: 8)],
        heroID: HeroIDs.bedivere
    )

    static let loyalOath = Card(
        id: classID("A3000000-0000-4000-8000-000000000016"),
        name: "Loyal Oath",
        text: "Choose: Protect or Avenge.",
        lucidityCost: 3,
        cardType: .utility,
        effects: [],
        heroID: HeroIDs.bedivere,
        choices: [
            CardChoiceOption(
                id: "protect",
                name: "Protect",
                text: "Gain 18 shield",
                iconName: "shield.fill",
                effects: [
                    Effect(type: .shield, value: 18),
                ]
            ),
            CardChoiceOption(
                id: "avenge",
                name: "Avenge",
                text: "Deal 14 damage · Gain 6 shield",
                iconName: "bolt.shield.fill",
                effects: [
                    Effect(type: .damage, value: 14),
                    Effect(type: .shield, value: 6),
                ]
            ),
        ]
    )

    static let bedivereCards: [Card] = [
        loyalGuard, swornOath, counterstance, steadyBreath, aegisWall, vigilStrike,
        holdTheLine, kingsGuard, lastOfTheTable, loyalStrike, unshakeable,
        oneArmedBlow, brothersInArms, finalDuty, returnToTheLake, loyalOath,
    ]

    // MARK: - Escanor — scaling payoff (grows stronger each turn, Vivid zone)

    static let cruelSun = Card(
        id: classID("A4000000-0000-4000-8000-000000000001"),
        name: "Cruel Sun",
        text: "Deal 16 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 16)],
        heroID: HeroIDs.escanor
    )

    static let risingPride = Card(
        id: classID("A4000000-0000-4000-8000-000000000002"),
        name: "Rising Pride",
        text: "Deal 12 damage.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 12)],
        heroID: HeroIDs.escanor
    )

    static let noonBlaze = Card(
        id: classID("A4000000-0000-4000-8000-000000000003"),
        name: "Noon Blaze",
        text: "Deal 20 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 20)],
        heroID: HeroIDs.escanor
    )

    static let sunshine = Card(
        id: classID("A4000000-0000-4000-8000-000000000004"),
        name: "Sunshine",
        text: "Heal 10 health. Gain 8 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 10), Effect(type: .shield, value: 8)],
        heroID: HeroIDs.escanor
    )

    static let arrogance = Card(
        id: classID("A4000000-0000-4000-8000-000000000005"),
        name: "Arrogance",
        text: "Draw 2 cards.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2)],
        heroID: HeroIDs.escanor
    )

    static let divineAxeRhitta = Card(
        id: classID("A4000000-0000-4000-8000-000000000006"),
        name: "Divine Axe Rhitta",
        text: "Deal 28 damage.",
        lucidityCost: 8,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 28)],
        heroID: HeroIDs.escanor
    )

    // Progression cards (7-15)

    static let dawningPower = Card(
        id: classID("A4000000-0000-4000-8000-000000000007"),
        name: "Dawning Power",
        text: "Deal 10 damage. Draw 1 card.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 10), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.escanor
    )

    static let pridefulStrike = Card(
        id: classID("A4000000-0000-4000-8000-000000000008"),
        name: "Prideful Strike",
        text: "Deal 18 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 18)],
        heroID: HeroIDs.escanor
    )

    static let radiantAura = Card(
        id: classID("A4000000-0000-4000-8000-000000000009"),
        name: "Radiant Aura",
        text: "Gain 14 shield. Heal 6 HP.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 14), Effect(type: .heal, value: 6)],
        heroID: HeroIDs.escanor
    )

    static let morningFlare = Card(
        id: classID("A4000000-0000-4000-8000-000000000010"),
        name: "Morning Flare",
        text: "Deal 14 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14)],
        heroID: HeroIDs.escanor
    )

    static let solarBlessing = Card(
        id: classID("A4000000-0000-4000-8000-000000000011"),
        name: "Solar Blessing",
        text: "Heal 15 HP.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 15)],
        heroID: HeroIDs.escanor
    )

    static let zenithStrike = Card(
        id: classID("A4000000-0000-4000-8000-000000000012"),
        name: "Zenith Strike",
        text: "Deal 22 damage.",
        lucidityCost: 7,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 22)],
        heroID: HeroIDs.escanor
    )

    static let absorbSunlight = Card(
        id: classID("A4000000-0000-4000-8000-000000000013"),
        name: "Absorb Sunlight",
        text: "Draw 3 cards.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 3)],
        heroID: HeroIDs.escanor
    )

    static let solarShield = Card(
        id: classID("A4000000-0000-4000-8000-000000000014"),
        name: "Solar Shield",
        text: "Gain 18 shield.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 18)],
        heroID: HeroIDs.escanor
    )

    static let theOneUltimate = Card(
        id: classID("A4000000-0000-4000-8000-000000000015"),
        name: "The One: Ultimate",
        text: "Deal 30 damage.",
        lucidityCost: 8,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 30)],
        heroID: HeroIDs.escanor
    )

    static let pridesDecision = Card(
        id: classID("A4000000-0000-4000-8000-000000000016"),
        name: "Pride's Decision",
        text: "Choose: Blaze or Endure.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [],
        heroID: HeroIDs.escanor,
        choices: [
            CardChoiceOption(
                id: "blaze",
                name: "Blaze",
                text: "+6 Lucidity · Deal 22 damage",
                iconName: "sun.max.fill",
                effects: [
                    Effect(type: .lucidityModify, value: 6),
                    Effect(type: .damage, value: 22),
                ]
            ),
            CardChoiceOption(
                id: "endure",
                name: "Endure",
                text: "−4 Lucidity · Heal 14 HP",
                iconName: "moon.fill",
                effects: [
                    Effect(type: .lucidityModify, value: -4),
                    Effect(type: .heal, value: 14),
                ]
            ),
        ]
    )

    static let escanorCards: [Card] = [
        cruelSun, risingPride, noonBlaze, sunshine, arrogance, divineAxeRhitta,
        dawningPower, pridefulStrike, radiantAura, morningFlare, solarBlessing,
        zenithStrike, absorbSunlight, solarShield, theOneUltimate, pridesDecision,
    ]

    // MARK: - Merlin — utility and lucidity control (mage, Drifting zone)

    static let infinity = Card(
        id: classID("A5000000-0000-4000-8000-000000000001"),
        name: "Infinity",
        text: "Draw 3 cards.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 3)],
        heroID: HeroIDs.merlin
    )

    static let aldansInsight = Card(
        id: classID("A5000000-0000-4000-8000-000000000002"),
        name: "Aldan's Insight",
        text: "Move Lucidity 8 toward Balanced. Draw 1 card.",
        lucidityCost: 3,
        cardType: .utility,
        effects: [Effect(type: .lucidityCenter, value: 8), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.merlin
    )

    static let arcaneBolt = Card(
        id: classID("A5000000-0000-4000-8000-000000000003"),
        name: "Arcane Bolt",
        text: "Deal 14 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14)],
        heroID: HeroIDs.merlin
    )

    static let absoluteCancel = Card(
        id: classID("A5000000-0000-4000-8000-000000000004"),
        name: "Absolute Cancel",
        text: "Gain 12 shield. Move Lucidity 5 toward Balanced.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 12), Effect(type: .lucidityCenter, value: 5)],
        heroID: HeroIDs.merlin
    )

    static let manaWell = Card(
        id: classID("A5000000-0000-4000-8000-000000000005"),
        name: "Mana Well",
        text: "Heal 10 health. Draw 1 card.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .heal, value: 10), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.merlin
    )

    static let realityShift = Card(
        id: classID("A5000000-0000-4000-8000-000000000006"),
        name: "Reality Shift",
        text: "Choose: Unravel or Ward.",
        lucidityCost: 3,
        cardType: .utility,
        effects: [],
        heroID: HeroIDs.merlin,
        choices: [
            CardChoiceOption(
                id: "unravel",
                name: "Unravel",
                text: "+5 Lucidity · Deal 16 damage",
                iconName: "sparkles",
                effects: [
                    Effect(type: .lucidityModify, value: 5),
                    Effect(type: .damage, value: 16),
                ]
            ),
            CardChoiceOption(
                id: "ward",
                name: "Ward",
                text: "−5 Lucidity · Gain 14 shield",
                iconName: "shield.lefthalf.filled",
                effects: [
                    Effect(type: .lucidityModify, value: -5),
                    Effect(type: .shield, value: 14),
                ]
            ),
        ]
    )

    // Progression cards (7-15)

    static let timeSlip = Card(
        id: classID("A5000000-0000-4000-8000-000000000007"),
        name: "Time Slip",
        text: "Draw 2 cards. Move Lucidity 5 toward Balanced.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2), Effect(type: .lucidityCenter, value: 5)],
        heroID: HeroIDs.merlin
    )

    static let backwardsWisdom = Card(
        id: classID("A5000000-0000-4000-8000-000000000008"),
        name: "Backwards Wisdom",
        text: "Heal 12 HP. Draw 1 card.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 12), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.merlin
    )

    static let wildMagic = Card(
        id: classID("A5000000-0000-4000-8000-000000000009"),
        name: "Wild Magic",
        text: "Deal 16 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 16)],
        heroID: HeroIDs.merlin
    )

    static let arcaneBarrier = Card(
        id: classID("A5000000-0000-4000-8000-000000000010"),
        name: "Arcane Barrier",
        text: "Gain 16 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 16)],
        heroID: HeroIDs.merlin
    )

    static let prophecy = Card(
        id: classID("A5000000-0000-4000-8000-000000000011"),
        name: "Prophecy",
        text: "Draw 3 cards.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 3)],
        heroID: HeroIDs.merlin
    )

    static let livingBackwards = Card(
        id: classID("A5000000-0000-4000-8000-000000000012"),
        name: "Living Backwards",
        text: "Reduce Lucidity by 12.",
        lucidityCost: 0,
        cardType: .utility,
        effects: [Effect(type: .lucidityModify, value: -12)],
        heroID: HeroIDs.merlin
    )

    static let arcaneStorm = Card(
        id: classID("A5000000-0000-4000-8000-000000000013"),
        name: "Arcane Storm",
        text: "Deal 20 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 20)],
        heroID: HeroIDs.merlin
    )

    static let enchantment = Card(
        id: classID("A5000000-0000-4000-8000-000000000014"),
        name: "Enchantment",
        text: "Gain 12 shield. Heal 8 HP.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 12), Effect(type: .heal, value: 8)],
        heroID: HeroIDs.merlin
    )

    static let wisdomOfAges = Card(
        id: classID("A5000000-0000-4000-8000-000000000015"),
        name: "Wisdom of Ages",
        text: "Draw 2 cards. Heal 10 HP.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2), Effect(type: .heal, value: 10)],
        heroID: HeroIDs.merlin
    )

    static let merlinCards: [Card] = [
        infinity, aldansInsight, arcaneBolt, absoluteCancel, manaWell, realityShift,
        timeSlip, backwardsWisdom, wildMagic, arcaneBarrier, prophecy,
        livingBackwards, arcaneStorm, enchantment, wisdomOfAges,
    ]

    // MARK: - Kay — resource management and tempo

    static let bluntStrike = Card(
        id: classID("A6000000-0000-4000-8000-000000000001"),
        name: "Blunt Strike",
        text: "Deal 11 damage.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 11)],
        heroID: HeroIDs.kay
    )

    static let grudgingDefense = Card(
        id: classID("A6000000-0000-4000-8000-000000000002"),
        name: "Grudging Defense",
        text: "Gain 10 shield.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 10)],
        heroID: HeroIDs.kay
    )

    static let stewardsStores = Card(
        id: classID("A6000000-0000-4000-8000-000000000003"),
        name: "Steward's Stores",
        text: "Draw 1 card. Gain 4 shield.",
        lucidityCost: 3,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 1), Effect(type: .shield, value: 4)],
        heroID: HeroIDs.kay
    )

    static let practicalBlow = Card(
        id: classID("A6000000-0000-4000-8000-000000000004"),
        name: "Practical Blow",
        text: "Deal 9 damage.",
        lucidityCost: 3,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 9)],
        heroID: HeroIDs.kay
    )

    static let noNonsense = Card(
        id: classID("A6000000-0000-4000-8000-000000000005"),
        name: "No Nonsense",
        text: "Deal 14 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14)],
        heroID: HeroIDs.kay
    )

    static let quartermaster = Card(
        id: classID("A6000000-0000-4000-8000-000000000006"),
        name: "Quartermaster",
        text: "Draw 2 cards.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2)],
        heroID: HeroIDs.kay
    )

    // Progression cards (7-15)

    static let seneschalsOrder = Card(
        id: classID("A6000000-0000-4000-8000-000000000007"),
        name: "Seneschal's Order",
        text: "Draw 2 cards. Gain 6 shield.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2), Effect(type: .shield, value: 6)],
        heroID: HeroIDs.kay
    )

    static let efficientStrike = Card(
        id: classID("A6000000-0000-4000-8000-000000000008"),
        name: "Efficient Strike",
        text: "Deal 11 damage. Draw 1 card.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 11), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.kay
    )

    static let practicalDefense = Card(
        id: classID("A6000000-0000-4000-8000-000000000009"),
        name: "Practical Defense",
        text: "Gain 14 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 14)],
        heroID: HeroIDs.kay
    )

    static let disciplinedStrike = Card(
        id: classID("A6000000-0000-4000-8000-000000000010"),
        name: "Disciplined Strike",
        text: "Deal 16 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 16)],
        heroID: HeroIDs.kay
    )

    static let resourcefulness = Card(
        id: classID("A6000000-0000-4000-8000-000000000011"),
        name: "Resourcefulness",
        text: "Draw 3 cards.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 3)],
        heroID: HeroIDs.kay
    )

    static let fosterBrothersWrath = Card(
        id: classID("A6000000-0000-4000-8000-000000000012"),
        name: "Foster Brother's Wrath",
        text: "Deal 18 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 18)],
        heroID: HeroIDs.kay
    )

    static let stewardsMight = Card(
        id: classID("A6000000-0000-4000-8000-000000000013"),
        name: "Steward's Might",
        text: "Gain 12 shield. Heal 6 HP.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 12), Effect(type: .heal, value: 6)],
        heroID: HeroIDs.kay
    )

    static let suppliesAtHand = Card(
        id: classID("A6000000-0000-4000-8000-000000000014"),
        name: "Supplies at Hand",
        text: "Heal 12 HP. Draw 1 card.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 12), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.kay
    )

    static let kaysFinisher = Card(
        id: classID("A6000000-0000-4000-8000-000000000015"),
        name: "Kay's Finisher",
        text: "Deal 20 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 20)],
        heroID: HeroIDs.kay
    )

    static let practicalChoice = Card(
        id: classID("A6000000-0000-4000-8000-000000000016"),
        name: "Practical Choice",
        text: "Choose: Efficiency or Force.",
        lucidityCost: 3,
        cardType: .utility,
        effects: [],
        heroID: HeroIDs.kay,
        choices: [
            CardChoiceOption(
                id: "efficiency",
                name: "Efficiency",
                text: "Draw 2 cards · Gain 4 shield",
                iconName: "rectangle.stack.fill",
                effects: [
                    Effect(type: .drawCards, value: 2),
                    Effect(type: .shield, value: 4),
                ]
            ),
            CardChoiceOption(
                id: "force",
                name: "Force",
                text: "Deal 12 damage · Draw 1 card",
                iconName: "hammer.fill",
                effects: [
                    Effect(type: .damage, value: 12),
                    Effect(type: .drawCards, value: 1),
                ]
            ),
        ]
    )

    static let kayCards: [Card] = [
        bluntStrike, grudgingDefense, stewardsStores, practicalBlow, noNonsense, quartermaster,
        seneschalsOrder, efficientStrike, practicalDefense, disciplinedStrike, resourcefulness,
        fosterBrothersWrath, stewardsMight, suppliesAtHand, kaysFinisher, practicalChoice,
    ]

    // MARK: - Morgana — debuffs and hybrid damage

    static let spiteBolt = Card(
        id: classID("A7000000-0000-4000-8000-000000000001"),
        name: "Spite Bolt",
        text: "Deal 11 damage.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 11)],
        heroID: HeroIDs.morgana
    )

    static let darkMending = Card(
        id: classID("A7000000-0000-4000-8000-000000000002"),
        name: "Dark Mending",
        text: "Heal 10 HP.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 10)],
        heroID: HeroIDs.morgana
    )

    static let thornShield = Card(
        id: classID("A7000000-0000-4000-8000-000000000003"),
        name: "Thorn Shield",
        text: "Gain 8 shield.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 8)],
        heroID: HeroIDs.morgana
    )

    static let soulSiphon = Card(
        id: classID("A7000000-0000-4000-8000-000000000004"),
        name: "Soul Siphon",
        text: "Deal 12 damage. Heal 6 HP.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 12), Effect(type: .heal, value: 6)],
        heroID: HeroIDs.morgana
    )

    static let feyFire = Card(
        id: classID("A7000000-0000-4000-8000-000000000005"),
        name: "Fey Fire",
        text: "Deal 15 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 15)],
        heroID: HeroIDs.morgana
    )

    static let darkPact = Card(
        id: classID("A7000000-0000-4000-8000-000000000006"),
        name: "Dark Pact",
        text: "Draw 2 cards.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2)],
        heroID: HeroIDs.morgana
    )

    // Progression cards (7-15)

    static let queenOfAir = Card(
        id: classID("A7000000-0000-4000-8000-000000000007"),
        name: "Queen of Air",
        text: "Deal 18 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 18)],
        heroID: HeroIDs.morgana
    )

    static let shadowMending = Card(
        id: classID("A7000000-0000-4000-8000-000000000008"),
        name: "Shadow Mending",
        text: "Heal 14 HP. Gain 4 shield.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 14), Effect(type: .shield, value: 4)],
        heroID: HeroIDs.morgana
    )

    static let curseOfMorgana = Card(
        id: classID("A7000000-0000-4000-8000-000000000009"),
        name: "Curse of Morgana",
        text: "Deal 14 damage. Heal 4 HP.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14), Effect(type: .heal, value: 4)],
        heroID: HeroIDs.morgana
    )

    static let darkWard = Card(
        id: classID("A7000000-0000-4000-8000-000000000010"),
        name: "Dark Ward",
        text: "Gain 16 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 16)],
        heroID: HeroIDs.morgana
    )

    static let feyBargain = Card(
        id: classID("A7000000-0000-4000-8000-000000000011"),
        name: "Fey Bargain",
        text: "Draw 3 cards.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 3)],
        heroID: HeroIDs.morgana
    )

    static let lifeSteal = Card(
        id: classID("A7000000-0000-4000-8000-000000000012"),
        name: "Life Steal",
        text: "Deal 16 damage. Heal 8 HP.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 16), Effect(type: .heal, value: 8)],
        heroID: HeroIDs.morgana
    )

    static let shadowCloak = Card(
        id: classID("A7000000-0000-4000-8000-000000000013"),
        name: "Shadow Cloak",
        text: "Gain 14 shield. Draw 1 card.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 14), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.morgana
    )

    static let queenOfDarkness = Card(
        id: classID("A7000000-0000-4000-8000-000000000014"),
        name: "Queen of Darkness",
        text: "Deal 22 damage.",
        lucidityCost: 7,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 22)],
        heroID: HeroIDs.morgana
    )

    static let corruptedHealing = Card(
        id: classID("A7000000-0000-4000-8000-000000000015"),
        name: "Corrupted Healing",
        text: "Heal 20 HP.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 20)],
        heroID: HeroIDs.morgana
    )

    static let feyBargainChoice = Card(
        id: classID("A7000000-0000-4000-8000-000000000016"),
        name: "Fey Bargain",
        text: "Choose: Drain or Deceive.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [],
        heroID: HeroIDs.morgana,
        choices: [
            CardChoiceOption(
                id: "drain",
                name: "Drain",
                text: "Deal 14 damage · Heal 7 HP",
                iconName: "drop.fill",
                effects: [
                    Effect(type: .damage, value: 14),
                    Effect(type: .heal, value: 7),
                ]
            ),
            CardChoiceOption(
                id: "deceive",
                name: "Deceive",
                text: "−5 Lucidity · Gain 14 shield · Draw 1",
                iconName: "moon.stars.fill",
                effects: [
                    Effect(type: .lucidityModify, value: -5),
                    Effect(type: .shield, value: 14),
                    Effect(type: .drawCards, value: 1),
                ]
            ),
        ]
    )

    static let morganaCards: [Card] = [
        spiteBolt, darkMending, thornShield, soulSiphon, feyFire, darkPact,
        queenOfAir, shadowMending, curseOfMorgana, darkWard, feyBargainChoice,
        lifeSteal, shadowCloak, queenOfDarkness, corruptedHealing,
    ]

    // MARK: - Galahad — healing and purification

    static let holyStrike = Card(
        id: classID("A8000000-0000-4000-8000-000000000001"),
        name: "Holy Strike",
        text: "Deal 12 damage.",
        lucidityCost: 4,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 12)],
        heroID: HeroIDs.galahad
    )

    static let grace = Card(
        id: classID("A8000000-0000-4000-8000-000000000002"),
        name: "Grace",
        text: "Heal 12 HP.",
        lucidityCost: 3,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 12)],
        heroID: HeroIDs.galahad
    )

    static let blessedShield = Card(
        id: classID("A8000000-0000-4000-8000-000000000003"),
        name: "Blessed Shield",
        text: "Gain 10 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 10)],
        heroID: HeroIDs.galahad
    )

    static let radiantTouch = Card(
        id: classID("A8000000-0000-4000-8000-000000000004"),
        name: "Radiant Touch",
        text: "Heal 8 HP. Gain 4 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 8), Effect(type: .shield, value: 4)],
        heroID: HeroIDs.galahad
    )

    static let lightEverlasting = Card(
        id: classID("A8000000-0000-4000-8000-000000000005"),
        name: "Light Everlasting",
        text: "Heal 6 HP. Gain 6 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 6), Effect(type: .shield, value: 6)],
        heroID: HeroIDs.galahad
    )

    static let grailKnight = Card(
        id: classID("A8000000-0000-4000-8000-000000000006"),
        name: "Grail Knight",
        text: "Deal 18 damage. Heal 8 HP.",
        lucidityCost: 7,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 18), Effect(type: .heal, value: 8)],
        heroID: HeroIDs.galahad
    )

    // Progression cards (7-15)

    static let divineLight = Card(
        id: classID("A8000000-0000-4000-8000-000000000007"),
        name: "Divine Light",
        text: "Heal 16 HP.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 16)],
        heroID: HeroIDs.galahad
    )

    static let puritysEdge = Card(
        id: classID("A8000000-0000-4000-8000-000000000008"),
        name: "Purity's Edge",
        text: "Deal 14 damage. Heal 4 HP.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 14), Effect(type: .heal, value: 4)],
        heroID: HeroIDs.galahad
    )

    static let holyShield = Card(
        id: classID("A8000000-0000-4000-8000-000000000009"),
        name: "Holy Shield",
        text: "Gain 16 shield.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .shield, value: 16)],
        heroID: HeroIDs.galahad
    )

    static let grailsBlessing = Card(
        id: classID("A8000000-0000-4000-8000-000000000010"),
        name: "Grail's Blessing",
        text: "Heal 14 HP. Gain 6 shield.",
        lucidityCost: 5,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 14), Effect(type: .shield, value: 6)],
        heroID: HeroIDs.galahad
    )

    static let faithfulBlow = Card(
        id: classID("A8000000-0000-4000-8000-000000000011"),
        name: "Faithful Blow",
        text: "Deal 16 damage.",
        lucidityCost: 5,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 16)],
        heroID: HeroIDs.galahad
    )

    static let purifyingLight = Card(
        id: classID("A8000000-0000-4000-8000-000000000012"),
        name: "Purifying Light",
        text: "Heal 10 HP. Draw 1 card.",
        lucidityCost: 4,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 10), Effect(type: .drawCards, value: 1)],
        heroID: HeroIDs.galahad
    )

    static let seekTheGrail = Card(
        id: classID("A8000000-0000-4000-8000-000000000013"),
        name: "Seek the Grail",
        text: "Draw 2 cards. Heal 6 HP.",
        lucidityCost: 5,
        cardType: .utility,
        effects: [Effect(type: .drawCards, value: 2), Effect(type: .heal, value: 6)],
        heroID: HeroIDs.galahad
    )

    static let saintlyStrike = Card(
        id: classID("A8000000-0000-4000-8000-000000000014"),
        name: "Saintly Strike",
        text: "Deal 20 damage.",
        lucidityCost: 6,
        cardType: .offensive,
        effects: [Effect(type: .damage, value: 20)],
        heroID: HeroIDs.galahad
    )

    static let achieveTheGrail = Card(
        id: classID("A8000000-0000-4000-8000-000000000015"),
        name: "Achieve the Grail",
        text: "Heal 25 HP.",
        lucidityCost: 6,
        cardType: .defensive,
        effects: [Effect(type: .heal, value: 25)],
        heroID: HeroIDs.galahad
    )

    static let grailsPath = Card(
        id: classID("A8000000-0000-4000-8000-000000000016"),
        name: "Grail's Path",
        text: "Choose: Mercy or Justice.",
        lucidityCost: 4,
        cardType: .utility,
        effects: [],
        heroID: HeroIDs.galahad,
        choices: [
            CardChoiceOption(
                id: "mercy",
                name: "Mercy",
                text: "Heal 16 HP · Gain 6 shield",
                iconName: "heart.fill",
                effects: [
                    Effect(type: .heal, value: 16),
                    Effect(type: .shield, value: 6),
                ]
            ),
            CardChoiceOption(
                id: "justice",
                name: "Justice",
                text: "Deal 16 damage · Heal 6 HP",
                iconName: "bolt.fill",
                effects: [
                    Effect(type: .damage, value: 16),
                    Effect(type: .heal, value: 6),
                ]
            ),
        ]
    )

    static let galahadCards: [Card] = [
        holyStrike, grace, blessedShield, radiantTouch, lightEverlasting, grailKnight,
        divineLight, puritysEdge, holyShield, grailsBlessing, faithfulBlow,
        purifyingLight, seekTheGrail, saintlyStrike, achieveTheGrail, grailsPath,
    ]

    // MARK: - Heroes

    static let lancelot = Hero(
        id: HeroIDs.lancelot,
        name: "Lancelot",
        title: "The Lion of Benwick",
        maxHealth: 70,
        passive: PassiveAbility(
            name: "Peerless Blade",
            text: "Offensive cards deal 3 extra damage while Vivid.",
            kind: .vividFury(amount: 3)
        ),
        storyText: "The greatest knight who ever lived, undone by his own heart. In dreams, his blade finds purpose once more.",
        cardIDs: lancelotCards.map(\.id)
    )

    static let bedivere = Hero(
        id: HeroIDs.bedivere,
        name: "Bedivere",
        title: "The Loyal Arm",
        maxHealth: 85,
        passive: PassiveAbility(
            name: "Steadfast",
            text: "While Balanced, take 15% reduced damage.",
            kind: .balancedResilience(percent: 15)
        ),
        storyText: "The last of Arthur's knights, who cast Excalibur into the lake. His loyalty outlasted legend itself.",
        cardIDs: bedivereCards.map(\.id)
    )

    static let escanor = Hero(
        id: HeroIDs.escanor,
        name: "Escanor",
        title: "Pride of the Noonday Sun",
        maxHealth: 65,
        passive: PassiveAbility(
            name: "Rising Sun",
            text: "Damage grows by 3 each turn the battle continues.",
            kind: .growingMight(perTurn: 3)
        ),
        storyText: "A knight whose power waxes with the sun. At noon, none can stand before him. At dusk, he is gentle as a lamb.",
        cardIDs: escanorCards.map(\.id)
    )

    static let merlin = Hero(
        id: HeroIDs.merlin,
        name: "Merlin",
        title: "The Wizard Who Lives Backwards",
        maxHealth: 60,
        passive: PassiveAbility(
            name: "Backwards Living",
            text: "While Drifting, card costs reduced by 2 Lucidity.",
            kind: .cheaperLucidityCosts(amount: 2)
        ),
        storyText: "He remembers the future and forgets the past. Time flows strangely around him, even in dreams.",
        cardIDs: merlinCards.map(\.id)
    )

    static let kay = Hero(
        id: HeroIDs.kay,
        name: "Kay",
        title: "The Seneschal",
        maxHealth: 75,
        passive: PassiveAbility(
            name: "Seneschal's Efficiency",
            text: "The first card played each turn costs 2 less Lucidity.",
            kind: .firstCardDiscount(amount: 2)
        ),
        storyText: "Arthur's foster brother, ever practical, ever grumbling. His love hides behind sharp words and sharper efficiency.",
        cardIDs: kayCards.map(\.id)
    )

    static let morgana = Hero(
        id: HeroIDs.morgana,
        name: "Morgana",
        title: "Queen of Air and Darkness",
        maxHealth: 55,
        passive: PassiveAbility(
            name: "Fey Bargain",
            text: "Whenever Morgana applies a debuff, heal 4 HP.",
            kind: .debuffHealing(amount: 4)
        ),
        storyText: "Half-sister to Arthur, touched by the fey. Is she villain or victim? In dreams, even she doesn't know.",
        cardIDs: morganaCards.map(\.id)
    )

    static let galahad = Hero(
        id: HeroIDs.galahad,
        name: "Galahad",
        title: "The Grail Knight",
        maxHealth: 60,
        passive: PassiveAbility(
            name: "Unblemished",
            text: "While Galahad has no debuffs, heal 3 HP at turn start.",
            kind: .purityHealing(amount: 3)
        ),
        storyText: "Pure of heart, worthy of the Grail. He alone achieved what others only sought. His light does not falter.",
        cardIDs: galahadCards.map(\.id)
    )

    /// The seven Book 1 heroes, in unlock order.
    static let book1Heroes: [Hero] = [lancelot, kay, bedivere, morgana, escanor, galahad, merlin]

    /// Every hero known to the game (starters + Book 1 + template enemies).
    static let allHeroes: [Hero] = starterHeroes + book1Heroes + [dreamer, nightmare]

    static func hero(withID id: Hero.ID) -> Hero? {
        allHeroes.first { $0.id == id }
    }

    // MARK: - Pools & decks

    /// This hero's full card pool. Dedicated pools carry no neutral cards, so
    /// this is simply every card tagged with the hero's `id`.
    static func pool(for hero: Hero) -> [Card] {
        allCards.filter { $0.heroID == hero.id }
    }

    /// Class-card lookup usable while `allCards` is being assembled.
    private static func classCards(for id: Hero.ID) -> [Card] {
        switch id {
        case HeroIDs.lancelot:  return lancelotCards
        case HeroIDs.bedivere:  return bedivereCards
        case HeroIDs.escanor:   return escanorCards
        case HeroIDs.merlin:    return merlinCards
        case HeroIDs.kay:       return kayCards
        case HeroIDs.morgana:   return morganaCards
        case HeroIDs.galahad:   return galahadCards
        case StarterIDs.wart:       return wartCards
        case StarterIDs.archimedes: return archimedesCards
        default:                return []
        }
    }

    /// Fresh starter deck for a playable hero, built from that hero's own
    /// pool. Copy counts lean on cheap staples and limit the expensive
    /// finishers, mirroring the neutral `starterDeck()` composition.
    static func starterDeck(for hero: Hero) -> [CardInstance] {
        let cards = classCards(for: hero.id)
        guard !cards.isEmpty else { return starterDeck() }
        // Two copies of the cheaper half, one of the pricier half.
        let sorted = cards.sorted { $0.lucidityCost < $1.lucidityCost }
        let split = sorted.count / 2
        let composition: [(card: Card, copies: Int)] =
            sorted.enumerated().map { index, card in
                (card, index < split ? 3 : index == sorted.count - 1 ? 1 : 2)
            }
        return composition.flatMap { entry in
            (0..<entry.copies).map { _ in CardInstance(cardID: entry.card.id) }
        }
    }
}
