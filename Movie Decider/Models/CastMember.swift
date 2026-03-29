import Foundation

struct CastMember: Identifiable, Sendable {
    let id: UUID
    let name: String
    let imageName: String   // empty string → SF Symbol fallback in CastMemberCard
}
