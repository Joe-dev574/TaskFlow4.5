//
//  WorkoutSamples.swift
//  WeldEngineer
//
//  Created by Joseph DeWeese on 8/4/24.
//

import Foundation

extension ItemTask {
    static let lastWeek = Calendar.current.date(
        byAdding: .day, value: -7, to: Date.now)!
    static let lastMonth = Calendar.current.date(
        byAdding: .month, value: -1, to: Date.now)!
    static var sampleItemTasks: [ItemTask] {
        [
            ItemTask(
                taskName: "4043 Aluminum Qualification",
                taskDescription: "Develop WPS"
            ),
            ItemTask(
                taskName: "5086 Aluminum Qualification",
                taskDescription: "Develop WPS"
            ),
            ItemTask(
                taskName: "5086 Aluminum Qualification",
                taskDescription: "Develop WPS"
            ),
            ItemTask(
                taskName: "5086 Aluminum Qualification",
                taskDescription: "Develop WPS"
            ),
            ItemTask(
                taskName: "5086 Aluminum Qualification",
                taskDescription: "Develop WPS"
            ),
            ItemTask(
                taskName: "5086 Aluminum Qualification",
                taskDescription: "Develop WPS"
            ),
        ]
    }
}

