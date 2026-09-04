import Foundation

/// Every key the book writes to disk, in one place, plus the one-shot
/// "start this build fresh" switch.
///
/// Bump `freshStartToken` to wipe every saved book on the next launch.
/// The new token is stored immediately afterwards, so the wipe happens
/// exactly once — progress made after it persists normally.
enum SaveStore {
    /// Change this string to force a clean slate on the next launch.
    static let freshStartToken = "2026-09-04-fresh"

    private static let tokenKey = "LanternLullaby.FreshStartToken"

    static let campaignProgressKey = "LanternLullaby.CampaignProgress.v1"
    static let prologueKey = "LanternLullaby.HasSeenPrologue.v1"
    static let corruptProgressKey = campaignProgressKey + ".corrupt"
    static let shownDialogueKeysKey = "DialogueManager.ShownFirstTimeKeys"

    private static var allKeys: [String] {
        [campaignProgressKey, prologueKey, corruptProgressKey, shownDialogueKeysKey]
    }

    /// Wipes the saved book if this build carries a new fresh-start token.
    /// Call before reading any saved state.
    static func applyPendingFreshStart() {
        let defaults = UserDefaults.standard
        guard defaults.string(forKey: tokenKey) != freshStartToken else { return }
        wipe()
        defaults.set(freshStartToken, forKey: tokenKey)
    }

    /// Removes every saved key. The fresh-start token is left alone so a
    /// player-triggered reset does not re-arm the launch wipe.
    static func wipe() {
        let defaults = UserDefaults.standard
        for key in allKeys {
            defaults.removeObject(forKey: key)
        }
    }
}
