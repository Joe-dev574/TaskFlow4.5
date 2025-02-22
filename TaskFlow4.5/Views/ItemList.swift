//
//  ItemList.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftUI
import SwiftData


struct ItemList: View {
    @Environment(\.modelContext) private var context
    @Query private var items: [Item]
    // Computed property to filter and sort items based on the active tab
    private var filteredItems: [Item] {
        switch activeTab {
        case .scheduled:
            return items.filter { $0.category == "Scheduled" }.sorted { $0.dateDue < $1.dateDue }
        case .upcoming:
            return items.filter { $0.category == "Upcoming" }.sorted { $0.dateAdded < $1.dateAdded }
        case .ideas:
            return items.filter { $0.category == "Ideas" }.sorted { $0.title < $1.title }
        case .scheduled:
            return items.filter { $0.category == "Scheduled" }.sorted { $0.dateAdded < $1.dateAdded }
        case .completed:
            return items.filter { $0.category == "Completed"  }.sorted { $0.dateCompleted < $1.dateCompleted }
        }
    }
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ItemList()
}
