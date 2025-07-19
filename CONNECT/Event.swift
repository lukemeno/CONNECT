//
//  Event.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftData

enum EventType: String, CaseIterable, Codable {
    case meetup = "meetup"
    case party = "party"
    case workshop = "workshop"
    case conference = "conference"
    case casual = "casual"
    case sports = "sports"
    case cultural = "cultural"
    case virtual = "virtual"
    
    var displayName: String {
        switch self {
        case .meetup: return "Meetup"
        case .party: return "Party"
        case .workshop: return "Workshop"
        case .conference: return "Conference"
        case .casual: return "Casual"
        case .sports: return "Sports"
        case .cultural: return "Cultural"
        case .virtual: return "Virtual"
        }
    }
    
    var systemImage: String {
        switch self {
        case .meetup: return "person.3"
        case .party: return "party.popper"
        case .workshop: return "hammer"
        case .conference: return "mic"
        case .casual: return "cup.and.saucer"
        case .sports: return "sportscourt"
        case .cultural: return "theatermasks"
        case .virtual: return "video"
        }
    }
}

@Model
final class Event {
    @Attribute(.unique) var id: UUID
    var title: String
    var eventDescription: String
    var type: EventType
    var startDate: Date
    var endDate: Date
    var imageURL: String?
    var maxAttendees: Int?
    var isPublic: Bool
    var requiresApproval: Bool
    var createdAt: Date
    var attendeesCount: Int
    
    // Relationships - Simplified to avoid circular references
    @Relationship(deleteRule: .nullify)
    var creator: User?
    
    @Relationship(deleteRule: .nullify)
    var attendees: [User] = []
    
    @Relationship(deleteRule: .nullify)
    var interestedUsers: [User] = []
    
    @Relationship(deleteRule: .nullify)
    var community: Community?
    
    @Relationship(deleteRule: .nullify)
    var location: Location?
    
    init(
        title: String,
        description: String,
        type: EventType,
        startDate: Date,
        endDate: Date,
        creator: User,
        location: Location? = nil,
        community: Community? = nil,
        maxAttendees: Int? = nil,
        isPublic: Bool = true,
        requiresApproval: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.eventDescription = description
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.creator = creator
        self.location = location
        self.community = community
        self.maxAttendees = maxAttendees
        self.isPublic = isPublic
        self.requiresApproval = requiresApproval
        self.createdAt = Date()
        self.attendeesCount = 1
        
        // Creator automatically attends
        self.attendees.append(creator)
    }
}

// MARK: - Event Extensions
extension Event {
    var timeUntilStart: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: startDate, relativeTo: Date())
    }
    
    var isUpcoming: Bool {
        startDate > Date()
    }
    
    var isOngoing: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }
    
    var isPast: Bool {
        endDate < Date()
    }
    
    var isFull: Bool {
        if let max = maxAttendees {
            return attendeesCount >= max
        }
        return false
    }
    
    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
    
    var durationString: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func addAttendee(_ user: User) -> Bool {
        guard !isFull, !attendees.contains(where: { $0.id == user.id }) else {
            return false
        }
        
        attendees.append(user)
        attendeesCount += 1
        return true
    }
    
    func removeAttendee(_ user: User) {
        attendees.removeAll { $0.id == user.id }
        attendeesCount = max(0, attendeesCount - 1)
    }
    
    func addInterested(_ user: User) {
        if !interestedUsers.contains(where: { $0.id == user.id }) {
            interestedUsers.append(user)
        }
    }
    
    func removeInterested(_ user: User) {
        interestedUsers.removeAll { $0.id == user.id }
    }
    
    func isAttending(_ user: User) -> Bool {
        attendees.contains { $0.id == user.id }
    }
    
    func isInterested(_ user: User) -> Bool {
        interestedUsers.contains { $0.id == user.id }
    }
} 