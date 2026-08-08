import SwiftUI

/// Subtle floating banner shown when Lucidity crosses into a new zone,
/// e.g. "Entering Drifting Zone — Defensive +20%".
struct ZoneNotificationView: View {
    let notification: ZoneNotification

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(notification.zone.color)
                .frame(width: 7, height: 7)
                .shadow(color: notification.zone.color, radius: 4)
            Text(notification.message)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(notification.zone.color.opacity(0.18))
                .background(Capsule().fill(.black.opacity(0.55)))
        )
        .overlay(Capsule().stroke(notification.zone.color.opacity(0.5), lineWidth: 1))
        .shadow(color: notification.zone.color.opacity(0.3), radius: 10)
    }
}
