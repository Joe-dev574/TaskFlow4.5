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
    var taskName: String = ""
    // Description name with default empty string
    var taskDescription: String = ""
    // Completion status with default false
    var isCompleted: Bool = false
    
    // Optional date for the task (nil by default)
    var taskDueDate: Date?
    
    
    var dateCreated: Date = Date()
    
    // Optional time for the task (nil by default)
    var taskDueTime: Date?
    
    // Optional reference to a related Item object
    var item: Item?
    
    // MARK: - Initialization
    
    init(
        taskName: String = "",
        taskDescription: String = "",
        isCompleted: Bool = false,
        taskDueDate: Date? = nil,
        dateCreated: Date = Date.now,
        taskDueTime: Date? = nil,
        item: Item? = nil
    ) {
        self.taskName = taskName
        self.isCompleted = isCompleted
        self.taskDueDate = taskDueDate
        self.dateCreated = dateCreated
        self.taskDueTime = taskDueTime
        self.item = item
    }
}
