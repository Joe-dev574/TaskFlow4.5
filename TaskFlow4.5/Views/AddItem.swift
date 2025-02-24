//
//  AddItem.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/22/25.
//


import SwiftData
import SwiftUI

/// A view for adding or editing items with category-based color theming
struct AddItem: View {
    // MARK: - Environment Properties
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Properties
    private let editItem: Item?
    @State private var title: String = ""
    @State private var remarks: String = ""
    @State private var dateAdded: Date = .now
    @State private var dateDue: Date = .now
    @State private var dateStarted: Date = .now
    @State private var dateCompleted: Date = .now
    @State private var itemCategory: Category = .today
    
    // MARK: - Animation Properties
    @State private var animateColor: Color = Category.today.color
    @State private var animate: Bool = false
    
    // MARK: - Error Handling Properties
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    // MARK: - Initialization
    init(editItem: Item? = nil) {
        self.editItem = editItem
        // Pre-populate fields if editing an existing item
        if let item = editItem {
            _title = State(initialValue: item.title)
            _remarks = State(initialValue: item.remarks)
            _dateAdded = State(initialValue: item.dateAdded)
            _dateDue = State(initialValue: item.dateDue)
            _dateStarted = State(initialValue: item.dateStarted)
            _dateCompleted = State(initialValue: item.dateCompleted)
            _itemCategory = State(initialValue: Category(rawValue: item.category) ?? .today)
            _animateColor = State(initialValue: Category(rawValue: item.category)?.color ?? itemCategory.color)
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background color based on selected category
            itemCategory.color
                .ignoresSafeArea()
            
            // Animated circle transition effect for category changes
            GeometryReader { geometry in
                let size = geometry.size
                Rectangle()
                    .fill(animateColor)
                    .mask(Circle())
                    .frame(
                        width: animate ? size.width * 2 : 0,
                        height: animate ? size.height * 2 : 0
                    )
                    .offset(animate ? CGSize(width: -size.width / 2, height: -size.height / 2) : size)
            }
            .clipped()
            .ignoresSafeArea()
            
            // Main form content
            NavigationStack {
                Form {
                    Section("Title") {
                        CustomTextEditor(remarks: $remarks, placeholder: "Enter title of item...", minHeight: 35)
                    }
                    
                    Section("Brief Description") {
                        CustomTextEditor(remarks: $remarks, placeholder: "Enter brief description...", minHeight: 75)
                    }
                    
                    Section("Category") {
                        CategorySelector(
                            selectedCategory: $itemCategory,
                            animateColor: $animateColor,
                            animate: $animate
                        )
                    }
                    .foregroundStyle(itemCategory.color)
                    
                    Section("Dates") {
                        // Display creation date
                        HStack {
                            Text("Date Created:")
                                .font(.callout)
                                .fontDesign(.serif)
                                .foregroundStyle(itemCategory.color)
                            Spacer()
                            Text(dateAdded.formatted(.dateTime))
                                .font(.system(size: 18))
                                .fontDesign(.serif)
                                .foregroundStyle(itemCategory.color)
                                .padding(.trailing, 12)
                        }
                        datePickersForCategory()
                    }
                }
                .toolbar {
                    // Cancel button
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            HapticsManager.notification(type: .success)
                            dismiss()
                        }
                        .fontDesign(.serif)
                        .foregroundStyle(itemCategory.color)
                    }
                    
                    // Title logo
                    ToolbarItem(placement: .principal) {
                        LogoView()
                    }
                    
                    // Save button
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            save()
                        }
                        .font(.callout)
                        .fontDesign(.serif)
                        .foregroundStyle(.white)
                        .buttonStyle(.borderedProminent)
                        .tint(itemCategory.color)
                        .disabled(!isFormValid)
                    }
                }
                // Error alert for save failures
                .alert("Error", isPresented: $showErrorAlert) {
                    Button("OK") { showErrorAlert = false }
                } message: {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Private Computed Properties
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !remarks.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Private Methods
    /// Saves the item to the model context
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
        
        // Update item properties
        item.title = title
        item.remarks = remarks
        item.dateAdded = dateAdded
        item.dateDue = dateDue
        item.dateStarted = dateStarted
        item.dateCompleted = dateCompleted
        item.category = itemCategory.rawValue
        
        do {
            try context.save()
            HapticsManager.notification(type: .success)
            dismiss()
        } catch {
            errorMessage = "Failed to save item: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    /// Returns appropriate DatePickers based on selected category
    @ViewBuilder
    private func datePickersForCategory() -> some View {
        DatePicker("Date Due", selection: $dateDue)
            .foregroundStyle(itemCategory.color)
        
        if itemCategory == .today || itemCategory == .work {
            DatePicker("Date Started", selection: $dateStarted)
                .foregroundStyle(itemCategory.color)
        }
        
        if itemCategory == .today {
            DatePicker("Completed", selection: $dateCompleted)
                .foregroundStyle(itemCategory.color)
        }
    }
}

// MARK: - Preview
#Preview {
    AddItem()
        .preferredColorScheme(.light)
}

//// MARK: - Placeholder Components (To be implemented)
///// Placeholder for custom text editor component
//struct CustomTextEditor: View {
//    @Binding var text: String
//    
//    var body: some View {
//        TextField("Enter text", text: $text)
//    }
//}
