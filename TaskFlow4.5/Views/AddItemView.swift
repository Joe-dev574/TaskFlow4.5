//
//  AddItemView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    private let editItem: Item?
    @State private var title: String = ""
    @State private var remarks: String = ""
    @State private var dateAdded: Date = .now
    @State private var dateDue: Date = .now
    @State private var dateStarted: Date = .now
    @State private var dateCompleted: Date = .now
    @State private var category: Category = .work
    
    // MARK: - Animation Properties
    @State private var animateColor: Color = Category.work.color
    @State private var animate: Bool = false
    
    // MARK: - Initialization
    init(editItem: Item? = nil) {
        self.editItem = editItem
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    CustomTextEditor(
                        text: $title,
                        placeholder: "Enter title here...",
                        minHeight: 50
                    )
                }
                
                Section("Brief Description") {
                    CustomTextEditor(
                        text: $remarks,
                        placeholder: "Brief description here...",
                        minHeight: 100
                    )
                }
                
                Section("Category") {
                    CategorySelector(
                        selectedCategory: $category,
                        animateColor: $animateColor,
                        animate: $animate
                    )
                }
                
                Section("Dates") {
                    DatePicker("Added", selection: $dateAdded)
                    DatePicker("Due", selection: $dateDue)
                    DatePicker("Started", selection: $dateStarted)
                    DatePicker("Completed", selection: $dateCompleted)
                }
            }
            .fontDesign(.serif)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticsManager.notification(type: .success)
                        dismiss()
                    }
                    .fontDesign(.serif)
                }
                
                ToolbarItem(placement: .principal) {
                    LogoView()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .font(.callout)
                    .fontDesign(.serif)
                    .foregroundStyle(.white)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle(editItem == nil ? "New Item" : "Edit Item")
        }
        .onAppear {
            if let item = editItem {
                loadItemData(item)
            }
        }
    }
    
    // MARK: - Private Properties
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !remarks.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Private Methods
    private func save() {
        let item = editItem ?? Item(
            title: title,
            remarks: remarks,
            dateAdded: dateAdded,
            dateDue: dateDue,
            dateStarted: dateStarted,
            dateCompleted: dateCompleted
        )
        
        if editItem == nil {
            context.insert(item)
        }
        
        item.title = title
        item.remarks = remarks
        item.dateAdded = dateAdded
        item.dateDue = dateDue
        item.dateStarted = dateStarted
        item.dateCompleted = dateCompleted
        item.category = Category.scheduled.rawValue
        
        do {
            try context.save()
            HapticsManager.notification(type: .success)
            dismiss()
        } catch {
            print("Failed to save item: \(error.localizedDescription)")
            // TODO: Show user-facing error alert
        }
    }
    
    private func loadItemData(_ item: Item) {
        title = item.title
        remarks = item.remarks
        dateAdded = item.dateAdded
        dateDue = item.dateDue
        dateStarted = item.dateStarted
        dateCompleted = item.dateCompleted
      
        animateColor = category.color
    }
}

// MARK: - Supporting Views
struct CustomTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                    .padding(.leading, 4)
            }
            
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .background(Color.gray.opacity(0.1))
                .font(.system(size: 16))
                .fontDesign(.serif)
                .frame(minHeight: minHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.secondary, lineWidth: 1)
                )
        }
    }
}

struct CategorySelector: View {
    @Binding var selectedCategory: Category
    @Binding var animateColor: Color
    @Binding var animate: Bool
    
    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),
            spacing: 15
        ) {
            ForEach(Category.allCases, id: \.rawValue) { category in
                CategoryButton(
                    category: category,
                    isSelected: selectedCategory == category,
                    onTap: {
                        guard !animate else { return }
                        animateColor = category.color
                        withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 1)) {
                            animate = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            animate = false
                            selectedCategory = category
                        }
                    }
                )
            }
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Text(category.rawValue.uppercased())
            .font(.system(size: 12))
            .fontDesign(.serif)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(category.color.opacity(isSelected ? 0.5 : 0.25))
            )
            .foregroundColor(category.color)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(category.color, lineWidth: isSelected ? 2 : 0)
            )
            .onTapGesture(perform: onTap)
    }
}

#Preview {
    AddItemView()
}
