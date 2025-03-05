//
//  TaskCard.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/4/25.
//

import SwiftUI
import SwiftData 



enum ItemTaskEvents {
    case onChecked(ItemTask, Bool)
    case onSelect(ItemTask)
}
struct TaskCard: View {
    let itemTask: ItemTask
    let onEvent: (ItemTaskEvents) -> Void
    @State private var checked: Bool = false
    @State private var taskDescription: String = ""
    
    private func formatTaskDueDate(_ date: Date) -> String {
        
        if date.isToday {
            return "Today"
        } else if date.isTomorrow {
            return "Tomorrow"
        } else {
            return date.formatted(date: .numeric, time: .omitted)
        }
    }
    
    //Mark: View
    var body: some View {
        HStack(alignment: .top) {
            
            Image(systemName: checked ? "circle.inset.filled": "circle")
                .font(.title2)
                .padding([.trailing], 5)
                .onTapGesture {
                    checked.toggle()
                    onEvent(.onChecked(itemTask, checked))
                }
            
            VStack {
                Text(itemTask.taskName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if  taskDescription != itemTask.taskDescription {
                    Text(taskDescription)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    
                    if let taskDueDate = itemTask.taskDueDate {
                        Text(formatTaskDueDate(taskDueDate))
                    }
                    
                    if let taskDueTime = itemTask.taskDueTime {
                        Text(taskDueTime, style: .time)
                    }
                    
                }.font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
        }.contentShape(Rectangle())
            .onTapGesture {
                onEvent(.onSelect(itemTask))
            }
    }
}

struct TaskCellViewContainer: View {
    
    @Query(sort: \ItemTask.taskName) private var itemTasks: [ItemTask]
    
    var body: some View {
        TaskCard(itemTask: itemTasks[0]) { _ in
            
        }
    }
}

