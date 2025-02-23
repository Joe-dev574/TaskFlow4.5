//
//  TaskCategory.swift
//  TaskPlanner
//
//  Created by Balaji on 04/01/23.
//
import SwiftData
import SwiftUI


enum Category: String, CaseIterable {
    
    // Life Domains
    case today = "Today"
    case family = "Family"
    case health = "Health"
    case work = "Work"
  
    
   
  
    // Priority/Time-based Categories
    case scheduled = "Scheduled"
  
    
    var color: Color{
        switch self {
        case .family:
            return Color.green
        case .scheduled:
            return Color.orange
        case .work:
            return Color.blue
        case .today:
            return Color.primary
        case .health:
            return Color.red
        }
    }
    var symbolImage: String {
        switch self {
        // Time-Based Symbols
        case .today: "alarm"
        case .work: "calendar.and.person"
       
        
        // Status-Based Symbols
        case .scheduled: "repeat"

        case .family:
            "figure.2.and.child.holdinghands"
        case .health:
            "heart.rectangle"
        }
    }
}
