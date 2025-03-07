//
//  TaskListView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/6/25.
//

import SwiftUI
import SwiftData



struct TaskListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.presentationMode) var presentationMode
        let item: Item
    @State private var itemTask: ItemTask?
 @State private var itemTasks: [ItemTask] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(item.title)
                    .foregroundStyle(.mediumGrey)
                Spacer()
                Text("\(itemTasks.count)")
            }
            .font(.system(.title3))
            .foregroundColor(.mediumGrey)
            .padding(.horizontal)
            .fontWeight(.semibold)
            List {
                ForEach(itemTasks) { itemTask in
                    TaskRowView(itemTask: ItemTask())
                        .foregroundStyle(.mediumGrey)
                }
                .onDelete(perform: delete)
            }
            .listStyle(.inset)
        }
        .navigationBarTitleDisplayMode(.inline)
                Spacer()
            }
    func delete(_ indexSet: IndexSet) {
        for index in indexSet {
            itemTasks.remove(at: index)
        }
        try! modelContext.save()
    }
}
