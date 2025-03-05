//
//  AddTaskView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/3/25.
//

import SwiftUI
import SwiftData

struct AddTaskView: View {
    //MARK:  PROPERTIES
    /// Env Properties
    @Environment(\.modelContext)  var context
    @Environment(\.dismiss) private var dismiss
    var editItem: Item?
    /// View Properties
    @State  var taskName: String = ""
    @State  var taskDescription: String = ""
    @State  var dateCreated: Date = .now
    @State  var taskDueDate: Date = .now
    @State  var dateStarted: Date = .now
    @State  var dateCompleted: Date = .now
    @State var category: Category = .today
    @State var itemCategory: Category  // Item category
    /// Random Tint
    @State var tint: TintColor = tints.randomElement()!
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 15) {
                
                    //MARK:  DATE PICKER GROUP
                    Section("Timeline") {
                        GroupBox{
                            HStack{
                                //MARK:  DATE CREATED DATA LINE
                                Text("Date Created: ")
                                    .foregroundStyle(.mediumGrey)
                                    .font(.callout)
                                Spacer()
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundStyle(.mediumGrey)
                                    .font(.system(size: 14))
                                Text(dateCreated.formatted(.dateTime))
                                    .fontDesign(.serif)
                                    .foregroundStyle(.mediumGrey)
                                    .font(.system(size: 14))
                            }
                                DatePicker("Date Due", selection: $taskDueDate, in: dateCreated..., displayedComponents: .date)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(itemCategory.color, lineWidth: 1))
                    }
                   
                    .padding(.horizontal, 7)
                    ///title
                    Section("Title") {
                        ZStack(alignment: .topLeading) {
                            if taskName.isEmpty {
                                Text("Enter title here...")
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                    .padding(10)
                                    .foregroundStyle(.secondary)
                            }
                            TextEditor(text: $taskName)
                                .scrollContentBackground(.hidden)
                                .background(Color.gray.opacity(0.1))
                                .font(.system(size: 16))
                                .fontDesign(.serif)
                        }
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color.secondary, lineWidth: 1))
                    }
                    .padding(.horizontal, 7)
                    ///description
                    Section("Brief Description") {
                        ZStack(alignment: .topLeading) {
                            if taskDescription.isEmpty {
                                Text("Brief description here...")
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(3)
                                    .padding(10)
                                    .foregroundStyle(.secondary)
                            }
                            TextEditor(text: $taskDescription)
                                .scrollContentBackground(.hidden)
                                .background(Color.gray.opacity(0.1))
                                .font(.system(size: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(itemCategory.color, lineWidth: 1))
                        }
                    }
                    .fontDesign(.serif)
                    .background(.background)
                }  .padding(.horizontal, 7)
            }
            .padding(.horizontal, 10)
            .fontDesign(.serif)
            //MARK:  TOOLBAR
                .toolbar{
                    ToolbarItem(placement: .topBarLeading, content: {
                        Button {
                            HapticsManager.notification(type: .success)
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .fontDesign(.serif)
                        }
                        .buttonStyle(.automatic)
                    })
                    ToolbarItem(placement: .principal, content: {
                        LogoView()
                    })
                    ToolbarItem(placement:.topBarTrailing, content: {
                        Button {
                            /// Saving objectiveTask
                            save()
                        
                        } label: {
                            Text("Save")
                                .font(.callout)
                                .fontDesign(.serif)
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(taskName.isEmpty || taskDescription.isEmpty )
                        .padding(.horizontal, 2)
                    })
                }
                .padding(.top, -25)
        }
    }
    //MARK: - Private Methods -
      func save() {
        /// Saving objectiveTask
        let itemTask = ItemTask(taskName: taskName, taskDescription: taskDescription, isCompleted: true, taskDueDate: Date.distantFuture, dateCreated: Date.now)
        do {
            context.insert(itemTask)
            try context.save()
            /// After Successful objectiveTask Creation, Dismissing the View
            HapticsManager.notification(type: .success)
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
}
