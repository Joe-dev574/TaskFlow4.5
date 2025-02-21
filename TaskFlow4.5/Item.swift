//
//  Item.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
