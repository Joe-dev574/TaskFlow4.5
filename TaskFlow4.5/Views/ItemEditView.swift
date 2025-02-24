//
//  ItemEditView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/23/25.
//

import SwiftData
import SwiftUI

/// A view for editing an existing item's details with category-based color theming
struct ItemEditView: View {
    // MARK: - Environment Properties
    @Environment(\.modelContext) private var context // Access to the SwiftData model context for persistence
    @Environment(\.dismiss) private var dismiss     // Dismiss action to close the view
    
    // MARK: - State Properties
    private let editItem: Item                      // The item being edited (required, not optional)
    @State private var title: String                // Title of the item
    @State private var remarks: String              // Remarks or description of the item
    @State private var dateAdded: Date              // Date the item was originally added
    @State private var dateDue: Date                // Due date for the item
    @State private var dateStarted: Date            // Start date for the item (if applicable)
    @State private var dateCompleted: Date          // Completion date for the item (if applicable)
    @State private var itemCategory: Category       // Category of the item (e.g., today, work)
    
    // MARK: - Animation Properties
    @State private var animateColor: Color          // Color for animation based on category
    @State private var animate: Bool = false        // Controls the animation state
    
    // MARK: - Error Handling Properties
    @State private var showErrorAlert: Bool = false // Flag to show error alert
    @State private var errorMessage: String = ""    // Message to display in error alert
    
    // MARK: - Initialization
    /// Initializes the edit screen with an existing item
    /// - Parameter editItem: The item to edit (must be provided)
    init(editItem: Item) {
        self.editItem = editItem
        // Pre-populate state properties with the existing item's data
        _title = State(initialValue: editItem.title)
        _remarks = State(initialValue: editItem.remarks)
        _dateAdded = State(initialValue: editItem.dateAdded)
        _dateDue = State(initialValue: editItem.dateDue)
        _dateStarted = State(initialValue: editItem.dateStarted)
        _dateCompleted = State(initialValue: editItem.dateCompleted)
        _itemCategory = State(initialValue: Category(rawValue: editItem.category) ?? .today)
        _animateColor = State(initialValue: Category(rawValue: editItem.category)?.color ?? Category.today.color)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background color based on the selected category
            itemCategory.color
                .ignoresSafeArea()
            
            // Animated circle transition effect when the category changes
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
            
            // Main form content for editing the item
            NavigationStack {
                Form {
                    // Section for editing the item's title
                    Section("Title") {
                        CustomTextEditor(remarks: $title, placeholder: "Enter title of item...", minHeight: 35)
                    }
                    
                    // Section for editing the item's description
                    Section("Brief Description") {
                        CustomTextEditor(remarks: $remarks, placeholder: "Enter brief description...", minHeight: 75)
                    }
                    
                    // Section for selecting the item's category
                    Section("Category") {
                        CategorySelector(
                            selectedCategory: $itemCategory,
                            animateColor: $animateColor,
                            animate: $animate
                        )
                    }
                    .foregroundStyle(itemCategory.color)
                    
                    // Section for editing dates associated with the item
                    Section("Dates") {
                        // Display and allow editing of the creation date
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
                        datePickersForCategory() // Dynamic date pickers based on category
                    }
                }
                .toolbar {
                    // Cancel button to discard changes
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            HapticsManager.notification(type: .success)
                            dismiss()
                        }
                        .fontDesign(.serif)
                        .foregroundStyle(itemCategory.color)
                    }
                    
                    // Title logo for branding
                    ToolbarItem(placement: .principal) {
                        LogoView()
                            .padding(.top, 10)
                    }
                    
                    // Save button to persist changes
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            saveEditedItem()
                        }
                        .font(.callout)
                        .fontDesign(.serif)
                        .foregroundStyle(.white)
                        .buttonStyle(.borderedProminent)
                        .tint(itemCategory.color)
                        .disabled(!isFormValid) // Disable if form is invalid
                    }
                }
                // Alert for displaying save errors
                .alert("Error", isPresented: $showErrorAlert) {
                    Button("OK") { showErrorAlert = false }
                } message: {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Private Computed Properties
    /// Checks if the form is valid (title and remarks are not empty)
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !remarks.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Private Methods
    /// Saves the edited item back to the model context
    private func saveEditedItem() {
        // Update the existing item's properties with the edited values
        editItem.title = title
        editItem.remarks = remarks
        editItem.dateAdded = dateAdded
        editItem.dateDue = dateDue
        editItem.dateStarted = dateStarted
        editItem.dateCompleted = dateCompleted
        editItem.category = itemCategory.rawValue
        
        do {
            try context.save() // Persist changes to the model context
            HapticsManager.notification(type: .success) // Provide haptic feedback
            dismiss() // Close the view on successful save
        } catch {
            // Handle save failure
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    /// Returns appropriate DatePickers based on the selected category
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
    // Preview requires a sample item since editItem is non-optional
    let sampleItem = Item(
        title: "Sample Task",
        remarks: "This is a test",
        dateAdded: .now,
        dateDue: .now.addingTimeInterval(86400),
        dateStarted: .now,
        dateCompleted: .now
    )
    sampleItem.category = Category.today.rawValue
    return ItemEditView(editItem: sampleItem)
        .preferredColorScheme(.light)
}
