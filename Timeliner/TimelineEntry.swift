//
//  TimelineEntry.swift
//  Timeliner
//
//  Created by Mitchell Tillman on 7/11/24.
//

// TimelineEntry.swift

import Foundation
import AppKit

struct TimelineEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var description: String
    var date: Date
    var category: String
    var universalLink: String?
    var icon: NSImage?
    
    static func == (lhs: TimelineEntry, rhs: TimelineEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: UUID = UUID(), description: String, date: Date, category: String, universalLink: String? = nil) {
        self.id = id
        self.description = description
        self.date = date
        self.category = category
        self.universalLink = universalLink
        self.icon = universalLink.flatMap { URL(string: $0) }.flatMap { getIconForURL($0) }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, description, date, category, universalLink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(Date.self, forKey: .date)
        category = try container.decode(String.self, forKey: .category)
        universalLink = try container.decodeIfPresent(String.self, forKey: .universalLink)
        icon = universalLink.flatMap { URL(string: $0) }.flatMap { getIconForURL($0) }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(description, forKey: .description)
        try container.encode(date, forKey: .date)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(universalLink, forKey: .universalLink)
    }
}

// Helper function to get the icon for a given URL
func getIconForURL(_ url: URL) -> NSImage? {
    if let appURL = NSWorkspace.shared.urlForApplication(toOpen: url) {
        return NSWorkspace.shared.icon(forFile: appURL.path)
    }
    return nil
}
