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
    
    
    var status: Status.RawValue
    
    /// Tint color identifier for UI representation
    var tintColor: String
    
    @Relationship(inverse: \Tag.items)
    var tags: [Tag]?
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
    ///   - category: Associated category (default: .events)
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
        status: Status = .Active,
        category: Category = .events,
        tintColor: TintColor,
        tags: [Tag]? = nil
    ) {
        self.title = title
        self.remarks = remarks
        self.dateAdded = dateAdded
        self.dateDue = dateDue
        self.dateStarted = dateStarted
        self.dateCompleted = dateCompleted
        self.category = category.rawValue
        self.status = status.rawValue
        self.tintColor = tintColor.color
        self.tags = tags
    }
    var icon: Image {
        switch Status(rawValue: status)! {
        case .Upcoming:
            Image(systemName: "checkmark.diamond.fill")
        case .Active:
            Image(systemName: "item.fill")
        case .Hold:
            Image(systemName: "books.vertical.fill")
        }
    }
    /// Extracting Color Value from tintColor String
    @Transient
    var color: Color {
        return tints.first(where: { $0.color == tintColor })?.value ?? Constants.shared.tintColor
    }
    @Transient
    var tint: TintColor? {
        return tints.first(where: { $0.color == tintColor })
    }
    @Transient
    var rawCategory: Category? {
        return Category.allCases.first(where: { category == $0.rawValue })
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
    
 
    
    
    enum Status: Int, Codable, Identifiable, CaseIterable {
        case Upcoming, Active, Hold
        var id: Self { self }
        var descr: LocalizedStringResource {
            switch self {
            case .Upcoming: "Upcoming"
            case .Active: "Active"
            case .Hold: "Hold"
            }
        }
    }
    
    // MARK: - Extensions
}
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
