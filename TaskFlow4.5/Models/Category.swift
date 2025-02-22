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
            return Color.taskColor15
        case .mind:
            return Color.taskColor9
        case .spirit:
            return Color.taskColor4
        case .family:
            return Color.taskColor8
        case .scheduled:
            return Color.purple
        case .urgent:
            return Color.brown
        case .work:
            return Color.taskColor6
        }
    }
}
