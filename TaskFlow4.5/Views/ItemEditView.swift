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
    @Environment(\.modelContext) private var context // Provides access to SwiftData for saving changes
    @Environment(\.dismiss) private var dismiss      // Allows dismissing the view when done
    
    // MARK: - State Properties
    private let editItem: Item                      // The item being edited, passed during initialization
    @State private var title: String                // Current title of the item
    @State private var remarks: String              // Current remarks or description
    @State private var dateAdded: Date              // Date the item was created
    @State private var dateDue: Date                // Due date for the item
    @State private var dateStarted: Date            // Start date (if applicable)
    @State private var dateCompleted: Date          // Completion date (if applicable)
    @State private var itemCategory: Category       // Selected category for the item
    @State private var categoryAnimationTrigger: Bool = false // Triggers background scale animation on category change
    
    // MARK: - Error Handling Properties
    @State private var showErrorAlert: Bool = false // Controls visibility of error alert
    @State private var errorMessage: String = ""    // Stores error message for display
    
    // MARK: - Initial Values for Comparison
    private let initialTitle: String                // Original title for change detection
    private let initialRemarks: String              // Original remarks for change detection
    private let initialDateAdded: Date              // Original creation date
    private let initialDateDue: Date                // Original due date
    private let initialDateStarted: Date            // Original start date
    private let initialDateCompleted: Date          // Original completion date
    private let initialCategory: Category           // Original category
    
    // MARK: - Initialization
    /// Creates the view with an existing item to edit
    init(editItem: Item) {
        self.editItem = editItem
        // Initialize state with item's current values
        _title = State(initialValue: editItem.title)
        _remarks = State(initialValue: editItem.remarks)
        _dateAdded = State(initialValue: editItem.dateAdded)
        _dateDue = State(initialValue: editItem.dateDue)
        _dateStarted = State(initialValue: editItem.dateStarted)
        _dateCompleted = State(initialValue: editItem.dateCompleted)
        _itemCategory = State(initialValue: Category(rawValue: editItem.category) ?? .today)
        
        // Store initial values for comparison
        self.initialTitle = editItem.title
        self.initialRemarks = editItem.remarks
        self.initialDateAdded = editItem.dateAdded
        self.initialDateDue = editItem.dateDue
        self.initialDateStarted = editItem.dateStarted
        self.initialDateCompleted = editItem.dateCompleted
        self.initialCategory = Category(rawValue: editItem.category) ?? .today
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView // Static gradient background with category-based coloring
            contentView    // Main content including form and navigation
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports accessibility text sizes up to xxxLarge
    }
    
    // MARK: - Background View
    /// Provides a static gradient background with subtle category color influence
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                itemCategory.color.opacity(0.01),     // Subtle category color at top
                .gray.darker().opacity(0.02),         // Darker gray in middle
                .gray.opacity(0.1)                    // Light gray at bottom
            ]),
            startPoint: .topLeading,                  // Gradient starts at top-left
            endPoint: .bottomTrailing                 // Gradient ends at bottom-right
        )
        .ignoresSafeArea()                            // Extends to screen edges
        .scaleEffect(categoryAnimationTrigger ? 1.1 : 1.0) // Scales slightly on category change
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: categoryAnimationTrigger) // Spring animation for scale
        .onChange(of: itemCategory) { _, _ in         // Triggers animation when category changes
            withAnimation {
                categoryAnimationTrigger = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    categoryAnimationTrigger = false    // Resets after 0.5s
                }
            }
        }
    }
    
    // MARK: - Content View
    /// Main content stack with navigation and form
    private var contentView: some View {
        NavigationStack {
            Form {
                titleSection      // Section for editing title
                remarksSection    // Section for editing remarks
                categorySection   // Section for selecting category
                datesSection      // Section for date management
            }
            .scrollContentBackground(.hidden) // Makes form background transparent
            .navigationTitle(title)           // Displays item title in navigation bar
            .toolbar { toolbarItems }         // Adds logo and save button to toolbar
            .padding(.horizontal, 12)         // Horizontal padding for content
            .tint(itemCategory.color)         // Applies category color to navigation elements
            .foregroundStyle(calculateContrastingColor(background: itemCategory.color)) // Ensures text contrast
            .alert("Error", isPresented: $showErrorAlert) { // Shows error alert if save fails
                Button("OK") { showErrorAlert = false }
            } message: {
                Text(errorMessage)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }
    
    // MARK: - Form Sections
    /// Section for editing the item title
    private var titleSection: some View {
        Section(header: Text("Title").foregroundStyle(itemCategory.color)) {
            CustomTextEditor(remarks: $title, placeholder: "Enter title of item...", minHeight: 35)
                .background(Color(.white.opacity(0.7)))    // Semi-transparent white background
                .foregroundStyle(.black)                    // Black text for contrast
                .accessibilityLabel("Item Title")
                .accessibilityHint("Enter the title of your item")
        }
    }
    
    /// Section for editing the item description
    private var remarksSection: some View {
        Section(header: Text("Brief Description").foregroundStyle(itemCategory.color)) {
            CustomTextEditor(remarks: $remarks, placeholder: "Enter brief description...", minHeight: 75)
                .background(Color(.white.opacity(0.7)))
                .foregroundStyle(.black)
                .accessibilityLabel("Item Description")
                .accessibilityHint("Enter a brief description of your item")
        }
    }
    
    /// Section for selecting the item category
    private var categorySection: some View {
        Section(header: Text("Category").foregroundStyle(itemCategory.color)) {
            CategorySelector(
                selectedCategory: $itemCategory,
                animateColor: .constant(itemCategory.color),
                animate: .constant(false)
            )
            .foregroundStyle(.primary)                     // Primary color for selector text
            .accessibilityLabel("Category Selector")
            .accessibilityHint("Choose a category for your item")
        }
    }
    
    /// Section displaying creation date and dynamic date pickers
    private var datesSection: some View {
        Section(header: Text("Dates").foregroundStyle(itemCategory.color)) {
            HStack {
                Text("Created")
                    .font(.caption)                        // Standard font for label
                    .foregroundStyle(itemCategory.color)
                Spacer()
                Text(dateAdded.formatted(.dateTime))
                    .font(.caption)                        // Matches label font
                    .foregroundStyle(itemCategory.color)
                    .padding(.trailing, 50)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Created \(dateAdded.formatted(.dateTime))")
            datePickersForCategory()          // Renders category-specific date pickers
        }
    }
    
    // MARK: - Toolbar Items
    /// Defines toolbar content with logo and save button
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {         // Centered logo
                LogoView()
                    .padding(.horizontal)
                    .accessibilityLabel("App Logo")
            }
            ToolbarItem(placement: .topBarTrailing) {    // Save button on right
                Button("Save") {
                    saveEditedItem()                     // Saves changes when tapped
                }
                .font(.callout)
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(itemCategory.color)                // Button matches category color
                .disabled(!hasFormChanged)               // Disabled until changes detected
                .accessibilityLabel("Save Changes")
                .accessibilityHint("Tap to save your edited item. Disabled until changes are made.")
            }
        }
    }
    
    // MARK: - Private Computed Properties
    /// Checks if any form fields have changed from initial values
    private var hasFormChanged: Bool {
        title != initialTitle ||
        remarks != initialRemarks ||
        dateAdded != initialDateAdded ||
        dateDue != initialDateDue ||
        dateStarted != initialDateStarted ||
        dateCompleted != initialDateCompleted ||
        itemCategory != initialCategory
    }
    
    // MARK: - Private Methods
    /// Saves edited item to the model context
    private func saveEditedItem() {
        editItem.title = title
        editItem.remarks = remarks
        editItem.dateAdded = dateAdded
        editItem.dateDue = dateDue
        editItem.dateStarted = dateStarted
        editItem.dateCompleted = dateCompleted
        editItem.category = itemCategory.rawValue
        
        do {
            try context.save()                          // Persists changes
            HapticsManager.notification(type: .success) // Success haptic feedback
            dismiss()                                   // Closes the view
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)") // Logs error for debugging
        }
    }
    
    /// Renders date pickers based on category with reduced text size
    @ViewBuilder
    private func datePickersForCategory() -> some View {
        DatePicker("Due", selection: $dateDue)
            .foregroundStyle(itemCategory.color)
            .font(.caption)
            .accessibilityLabel("Due Date")
            .accessibilityHint("Select the due date for your item")
        
        if itemCategory == .today || itemCategory == .work {
            DatePicker("Start", selection: $dateStarted)
                .foregroundStyle(itemCategory.color)
                .font(.caption)                     // Reduced size
                .accessibilityLabel("Start Date")
                .accessibilityHint("Select the start date for your item")
        }
        
        if itemCategory == .today {
            DatePicker("Finish", selection: $dateCompleted)
                .foregroundStyle(itemCategory.color)
                .font(.caption)                     // Reduced size
                .accessibilityLabel("Completion Date")
                .accessibilityHint("Select the completion date for your item")
        }
    }
    
    /// Calculates luminance for WCAG contrast compliance
    private func relativeLuminance(color: Color) -> Double {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    /// Computes contrast ratio between two luminance values
    private func contrastRatio(l1: Double, l2: Double) -> Double {
        let lighter = max(l1, l2), darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    /// Selects black or white based on contrast with background
    private func calculateContrastingColor(background: Color) -> Color {
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 4.5 && whiteContrast >= blackContrast ? .white : .black
    }
}

// MARK: - Color Extension
extension Color {
    /// Returns a darker version of the color
    func darker() -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(red: max(red - 0.2, 0), green: max(green - 0.2, 0), blue: max(blue - 0.2, 0), opacity: alpha)
    }
}

// MARK: - Preview
#Preview {
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
