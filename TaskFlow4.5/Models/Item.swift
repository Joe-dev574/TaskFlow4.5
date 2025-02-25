//
//  Item.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftUI
import SwiftData

/// A model class representing an Item entity that conforms to SwiftData's @Model macro
/// This class defines the structure for items that can be stored and managed in the app
@Model
final class Item {
    // MARK: - Properties
    
    /// The title of the item, required field
    var title: String
    
    /// Additional notes or comments about the item
    var remarks: String
    
    /// Date when the item was created
    var dateAdded: Date
    
    /// Date when work on the item began
    var dateStarted: Date
    
    /// Deadline or due date for the item
    var dateDue: Date
    
    /// Date when the item was completed
    var dateCompleted: Date
    
    /// Category classification stored as raw String value from Category enum
    var category: String
    
    /// Tint color identifier for UI representation
    var tint: String
    
    /// Relationship to ItemTask objects with cascade delete rule
    /// When an Item is deleted, all associated ItemTasks will also be deleted
    @Relationship(deleteRule: .cascade)
    var itemTasks: [ItemTask]?
    
    
    // MARK: - Initialization
       
       /// Initializes a new Item with default values
       /// - Parameters:
       ///   - title: The item's title (default: empty string)
       ///   - remarks: Additional notes (default: empty string)
       ///   - dateAdded: Creation date (default: now)
       ///   - dateDue: Due date (default: now)
       ///   - dateStarted: Start date (default: now)
       ///   - dateCompleted: Completion date (default: now)
       ///   - category: Associated category (default: .scheduled)
       ///   - tint: Color identifier (default: "TaskColor 1")
    ///
    ///   
    init(
        title: String = "",
        remarks: String = "",
        dateAdded: Date = .now,
        dateDue: Date = .now,
        dateStarted: Date = .now,
        dateCompleted: Date = .now,
        category: Category = .scheduled,
        tint: String = "TaskColor 1"  // Added default value
    ) {
        self.title = title
        self.remarks = remarks
        self.dateAdded = dateAdded
        self.dateDue = dateDue
        self.dateStarted = dateStarted
        self.dateCompleted = dateCompleted
        self.category = category.rawValue
        self.tint = tint
    }
    
    // MARK: - Helper Methods
    
    /// Determines if the item is completed based on completion date
    func isCompleted() -> Bool {
        dateCompleted <= .now
    }
    
    /// Calculates remaining days until due date
    /// Returns nil if due date has passed or calculation fails
    func daysUntilDue() -> Int? {
        Calendar.current.dateComponents([.day], from: .now, to: dateDue).day
    }
    
    /// Computed property for tint color based on tint string
    var tintColor: Color {
        switch tint {
        case "TaskColor 1": return .taskColor1
        case "TaskColor 2": return .taskColor2
        case "TaskColor 3": return .taskColor3
        case "TaskColor 4": return .taskColor4
        case "TaskColor 5": return .taskColor5
        case "TaskColor 6": return .taskColor6
        case "TaskColor 7": return .taskColor7
        case "TaskColor 8": return .taskColor8
        case "TaskColor 9": return .taskColor9
        case "TaskColor 10": return .taskColor10
        case "TaskColor 11": return .taskColor11
        case "TaskColor 12": return .taskColor12
        case "TaskColor 13": return .taskColor13
        case "TaskColor 14": return .taskColor14
        case "TaskColor 15": return .taskColor15
    
        default: return .black
        }
    }
}

// MARK: - Extensions

extension Item: Identifiable {
    // ID automatically provided by @Model
}

/// Date extension for convenience methods
extension Date {
    /// Creates a date by adding hours to current time
    static func updateHour(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: value, to: .now) ?? .now
    }
}
