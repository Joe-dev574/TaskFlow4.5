//
//  ItemTask.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftUI
import SwiftData

// Define a model class for task items using SwiftData's @Model macro
@Model
class ItemTask {
    // MARK: - Properties
    
    // Task name with default empty string
    var name: String = ""
    
    // Completion status with default false
    var isCompleted: Bool = false
    
    // Optional date for the task (nil by default)
    var taskDate: Date?
    
    
    var dateAdded: Date = Date()
    
    // Optional time for the task (nil by default)
    var taskTime: Date?
    
    // Optional reference to a related Item object
    var item: Item?
    
    // MARK: - Initialization
    
    /// Creates a new ItemTask instance
    /// - Parameters:
    ///   - name: The task's name
    ///   - isCompleted: Completion status (defaults to false)
    ///   - taskDate: Scheduled date (defaults to nil)
    ///   - taskTime: Scheduled time (defaults to nil)
    init(
        name: String,
        isCompleted: Bool = false,
        taskDate: Date? = nil,
        dateAdded: Date = Date.now,
        taskTime: Date? = nil
    ) {
        self.name = name
        self.isCompleted = isCompleted
        self.taskDate = taskDate
        self.dateAdded = dateAdded
        self.taskTime = taskTime
    }
}
