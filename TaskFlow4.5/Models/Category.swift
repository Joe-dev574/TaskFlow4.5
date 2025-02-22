//
//  TaskCategory.swift
//  TaskPlanner
//
//  Created by Balaji on 04/01/23.
//
import SwiftData
import SwiftUI


enum Category: String, CaseIterable {
    // Personal Well-being Categories
    case spirit = "Spirit"
    case mind = "Mind"
    case body = "Body"
    
    // Life Domains
    case work = "Work"
    case family = "Family"
    
    // Priority/Time-based Categories
    case urgent = "Urgent"
    case scheduled = "Scheduled"
    
    /// Groups categories by their logical sections
    static func groupedCategories() -> [String: [Category]] {
        [
            "Personal Well-being": [.spirit, .mind, .body],
            "Life Domains": [.work, .family],
            "Priority/Time-based": [.urgent, .scheduled]
        ]
    }
    
    /// Returns the display group name for the category
    var groupName: String {
        switch self {
        case .spirit, .mind, .body: return "Personal Well-being"
        case .work, .family: return "Life Domains"
        case .urgent, .scheduled: return "Priority/Time-based"
        }
    }
    var color: Color{
        switch self {
        case .body:
            return Color.blue
        case .mind:
            return Color.pink
        case .spirit:
            return Color.brown
        case .family:
            return Color.orange
        case .scheduled:
            return Color.purple
        case .urgent:
            return Color.red
        case .work:
            return Color.green
        }
    }
}
