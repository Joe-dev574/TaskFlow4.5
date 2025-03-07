//
//  TaskRowView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/6/25.
//

import SwiftUI
import SwiftData



struct TaskRowView: View {
    @Environment(\.modelContext) var modelContext
    @State var itemTask: ItemTask
    
    var body: some View {
        HStack {
            Button {
                itemTask.isCompleted.toggle()
            } label: {
                if itemTask.isCompleted {
                    filledItemTaskLabel
                } else {
                    emptyItemTaskLabel
                }
            }
            .frame(width: 20, height: 20)
            .buttonStyle(.plain)
            
            TextField(itemTask.taskName, text: $itemTask.taskName)
                .foregroundStyle(itemTask.isCompleted ? .secondary : .primary)
        }
    }
    
    var filledItemTaskLabel: some View {
        Circle()
            .stroke(.mediumGrey, lineWidth: 2)
            .overlay(alignment: .center) {
                GeometryReader { geo in
                    VStack {
                        Circle()
                            .fill(.mediumGrey)
                            .frame(width: geo.size.width*0.7, height: geo.size.height*0.7, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
    }
    
    var emptyItemTaskLabel: some View {
        Circle()
            .stroke(.secondary)
    }
}

#Preview {
    
    TaskRowView (itemTask: ItemTask(taskName: "testing task", taskDescription: "test this so identify effectiveness of implementation"))
           
    }

