//
//  TaskListScreen.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/4/25.
//

import SwiftUI
import SwiftData

enum SortOrder: String, Identifiable, CaseIterable {
    case Status, Title, DueDate
    
    var id: Self {
        self
    }
}
struct TaskListScreen: View {
    // Environment for managing object context in Core Data
    @Environment(\.modelContext) private var modelContext
    //MARK: Properties
    @State private var createNewTask = false
    @State private var sortOrder = SortOrder.Status
    @State private var filter = ""
    
    var body: some View {
        NavigationStack {
            List{
                VStack{
                    Picker("", selection: $sortOrder) {
                        ForEach(SortOrder.allCases) {  sortOrder in
                            Text("\(sortOrder.rawValue)").tag(sortOrder)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 4)
                    
                    TaskList()
                        .searchable(text: $filter, prompt: Text("Filter with Status, Title or Due Date"))
                }
                
            }
            .navigationTitle("Add Task")
            .toolbar {
                Button(action: {
                    createNewTask = true
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        . foregroundStyle(.blue.gradient)
                })
            }
            .sheet(isPresented: $createNewTask){
                AddTaskView()
                    .presentationDetents([.medium])
            }
        }
    }
    
}
#Preview {
    TaskListScreen()
}
