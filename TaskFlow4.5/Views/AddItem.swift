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
    @Environment(\.modelContext) private var context // Provides access to SwiftData for saving changes
    @Environment(\.dismiss) private var dismiss      // Allows dismissing the view when done
    
    // MARK: - Item Property
    let item: Item?  // Optional item for editing; nil if creating a new item
    
    // MARK: - State Properties
    /// View Properties
    @State private var title: String
    @State private var remarks: String
    @State private var dateAdded: Date
    @State private var dateDue: Date
    @State private var dateStarted: Date
    @State private var dateCompleted: Date
    @State private var category: Category = .health
    
    @State private var categoryAnimationTrigger: Bool = false // Triggers background scale animation on category change
    
    // MARK: - Error Handling Properties
    @State private var showErrorAlert: Bool = false // Controls visibility of error alert
    @State private var errorMessage: String = ""    // Stores error message for display
    
    // MARK: - Initialization
    /// Initializes the view with an optional item; sets state from item if provided, otherwise uses defaults
    init(item: Item? = nil) {
        self.item = item
        if let item = item {
            _title = State(initialValue: item.title)
            _remarks = State(initialValue: item.remarks)
            _dateAdded = State(initialValue: item.dateAdded)
            _dateDue = State(initialValue: item.dateDue)
            _dateStarted = State(initialValue: item.dateStarted)
            _dateCompleted = State(initialValue: item.dateCompleted)
            _category = State(initialValue: category) // Fixed: Use item.category, not standalone category
        } else {
            _title = State(initialValue: "")
            _remarks = State(initialValue: "")
            _dateAdded = State(initialValue: .now)
            _dateDue = State(initialValue: .now)
            _dateStarted = State(initialValue: .now)
            _dateCompleted = State(initialValue: .now)
            _category = State(initialValue: .today)
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView // Static gradient background with category-based coloring
            contentView    // Main content including form and navigation
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports accessibility text sizes up to xxxLarge
        .background(backgroundView) // Ensure background is applied at the root level
    }
    
    // MARK: - Background View
    /// Provides a prominent background with category color influence, overriding default phone settings
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .lightGrey.opacity(0.2),   // High opacity for strong category color
                .gray.darker().opacity(0.4),   // Darker gray for contrast (assumes .darker() extension)
 //               .gray.opacity(0.3)             // Solid base to ensure visibility
            ]),
            startPoint: .topLeading,           // Gradient starts at top-left
            endPoint: .bottomTrailing          // Gradient ends at bottom-right
        )
        .ignoresSafeArea()                     // Extends to screen edges
        .scaleEffect(categoryAnimationTrigger ? 1.75 : 1.0) // Scales slightly on category change
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: categoryAnimationTrigger) // Spring animation
        .onChange(of: category) { _, _ in      // Triggers animation when category changes
            withAnimation {
                categoryAnimationTrigger = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    categoryAnimationTrigger = false // Resets after 0.5s
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
       //     .scrollContentBackground(.visible) // Makes form background transparent to show gradient
            .navigationTitle(title)           // Displays item title in navigation bar
            .toolbar { toolbarItems }         // Adds logo and save button to toolbar
            .padding(.horizontal, 4)         // Horizontal padding for content
            .foregroundStyle(calculateContrastingColor(background: category.color)) // Ensures text contrast
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
        Section(header: Text("Title").foregroundStyle(category.color)) {
            CustomTextEditor(remarks: $title, placeholder: "Enter title of item...", minHeight: 35)
                .background(Color("LightGrey"))    // Slightly opaque white for readability
                .foregroundStyle(.primary)                 // Primary text color for contrast
                .accessibilityLabel("Item Title")
                .accessibilityHint("Enter the title of your item")
        }
    }
    
    /// Section for editing the item description
    private var remarksSection: some View {
        Section(header: Text("Brief Description").foregroundStyle(category.color)) {
            CustomTextEditor(remarks: $remarks, placeholder: "Enter brief description...", minHeight: 75)
                .background(Color("LightGrey")) // Lighter opacity for distinction
                .foregroundStyle(.black)
                .accessibilityLabel("Item Description")
                .accessibilityHint("Enter a brief description of your item")
        }
    }
    
    /// Section for selecting the item category
    private var categorySection: some View {
        Section(header: Text("Category").foregroundStyle(category.color)) {
            CategorySelector(
                selectedCategory: $category,
                animateColor: .constant(category.color),
                animate: .constant(false)
            )
            .foregroundStyle(.primary)                     // Primary color for selector text
            .accessibilityLabel("Category Selector")
            .accessibilityHint("Choose a category for your item")
        }
    }
    
    /// Section displaying creation date and dynamic date pickers
    private var datesSection: some View {
        Section(header: Text("Dates").foregroundStyle(category.color)) {
            HStack {
                Text("Created")
                    .font(.caption)                        // Standard font for label
                    .foregroundStyle(category.color)
                Spacer()
                Text(dateAdded.formatted(.dateTime))
                    .font(.caption)                        // Matches label font
                    .foregroundStyle(category.color)
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
            ToolbarItem(placement: .topBarLeading) {
                Button{
                    HapticsManager.notification(type: .success)
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(category.color)
                }
            }
            ToolbarItem(placement: .principal) {         // Centered logo
                LogoView()
                    .padding(.horizontal)
                    .accessibilityLabel("App Logo")
            }
            ToolbarItem(placement: .topBarTrailing) {    // Save button on right
                Button("Save") {
                    save()                     // Saves changes when tapped
                }
                .font(.callout)
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(category.color)                // Button matches category color
                .accessibilityLabel("Save Changes")
                .accessibilityHint("Tap to save your edited item.")
            }
        }
    }
    
    // MARK: - Private Methods
    /// Saves edited item or creates new item in the model context
    private func save() {
        // Creating new item: instantiate and insert into context
                let newItem = Item(title: title, remarks: remarks, dateAdded: dateAdded, dateDue: dateDue, dateStarted: dateStarted, dateCompleted: dateCompleted, category: category)
                context.insert(newItem)
            do {
                try context.save()                          // Persists changes to SwiftData
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
            .foregroundStyle(category.color)
            .font(.caption)
            .accessibilityLabel("Due Date")
            .accessibilityHint("Select the due date for your item")
        
        if category == .today || category == .work {
            DatePicker("Start", selection: $dateStarted)
                .foregroundStyle(category.color)
                .font(.caption)                     // Reduced size
                .accessibilityLabel("Start Date")
                .accessibilityHint("Select the start date for your item")
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
        return (lighter + 0.05) / (darker + 0.05) // Fixed: Reverted to standard WCAG formula
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

// MARK: - Preview
#Preview {
    AddItem(item: Item(title: "test", remarks: "making all kinds of remarks ere we go", dateAdded: .now, dateDue: .distantFuture, dateStarted: .distantPast, dateCompleted: .distantFuture, category: .family))
}
