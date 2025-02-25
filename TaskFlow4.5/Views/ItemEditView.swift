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
    @Environment(\.modelContext) private var context // Access to SwiftData model context
    @Environment(\.dismiss) private var dismiss      // Dismisses the view
    
    // MARK: - State Properties
    private let editItem: Item                      // Item being edited
    @State private var title: String                // Item title
    @State private var remarks: String              // Item remarks
    @State private var dateAdded: Date              // Creation date
    @State private var dateDue: Date                // Due date
    @State private var dateStarted: Date            // Start date
    @State private var dateCompleted: Date          // Completion date
    @State private var itemCategory: Category       // Selected category
    @State private var categoryAnimationTrigger: Bool = false // Triggers scale animation on category change
    
    // MARK: - Error Handling Properties
    @State private var showErrorAlert: Bool = false // Shows error alert
    @State private var errorMessage: String = ""    // Error message for alert
    
    // MARK: - Initial Values for Comparison
    private let initialTitle: String
    private let initialRemarks: String
    private let initialDateAdded: Date
    private let initialDateDue: Date
    private let initialDateStarted: Date
    private let initialDateCompleted: Date
    private let initialCategory: Category
    
    // MARK: - Initialization
    init(editItem: Item) {
        self.editItem = editItem
        _title = State(initialValue: editItem.title)
        _remarks = State(initialValue: editItem.remarks)
        _dateAdded = State(initialValue: editItem.dateAdded)
        _dateDue = State(initialValue: editItem.dateDue)
        _dateStarted = State(initialValue: editItem.dateStarted)
        _dateCompleted = State(initialValue: editItem.dateCompleted)
        _itemCategory = State(initialValue: Category(rawValue: editItem.category) ?? .today)
        
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
            backgroundView // Static gradient background
            contentView    // Main content (NavigationStack)
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Supports large text sizes
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
               
                itemCategory.color.opacity(0.01),     // Category color at top
                .gray.darker().opacity(0.02), // Darker category color in middle
                .gray.opacity(0.1),// Gray as trailing color
            ]),
            startPoint: .topLeading,                 // Fixed start point
            endPoint: .bottomTrailing                // Fixed end point
        )
        .ignoresSafeArea()                           // Fills entire screen
        .scaleEffect(categoryAnimationTrigger ? 1.1 : 1.0) // Slight scale on category change
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: categoryAnimationTrigger)
        .onChange(of: itemCategory) { _, _ in        // Animate on category change
            withAnimation {
                categoryAnimationTrigger = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    categoryAnimationTrigger = false
                }
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        NavigationStack {
            Form {
                titleSection      // Title editor
                remarksSection    // Remarks editor
                categorySection   // Category selector
                datesSection      // Date pickers
            }
            .scrollContentBackground(.hidden) // Transparent form background
            .navigationTitle(title)
            .toolbar { toolbarItems }         // Toolbar with logo and save button
            .padding(.horizontal, 12)
            .tint(itemCategory.color)         // Navigation tint
            .foregroundStyle(calculateContrastingColor(background: itemCategory.color))
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { showErrorAlert = false }
            } message: {
                Text(errorMessage)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }
    
    // MARK: - Form Sections
    private var titleSection: some View {
        Section(header: Text("Title").foregroundStyle(itemCategory.color)) {
            CustomTextEditor(remarks: $title, placeholder: "Enter title of item...", minHeight: 35)
                .background(Color(.white.opacity(0.7)))
                .foregroundStyle(.black)
                .accessibilityLabel("Item Title")
                .accessibilityHint("Enter the title of your item")
        }
    }
    
    private var remarksSection: some View {
        Section(header: Text("Brief Description").foregroundStyle(itemCategory.color)) {
            CustomTextEditor(remarks: $remarks, placeholder: "Enter brief description...", minHeight: 75)
                .background(Color(.white.opacity(0.7)))
                .foregroundStyle(.black)
                .accessibilityLabel("Item Description")
                .accessibilityHint("Enter a brief description of your item")
        }
    }
    
    private var categorySection: some View {
        Section(header: Text("Category").foregroundStyle(itemCategory.color)) {
            CategorySelector(
                selectedCategory: $itemCategory,
                animateColor: .constant(itemCategory.color),
                animate: .constant(false)
            )
            .foregroundStyle(.primary)
            .accessibilityLabel("Category Selector")
            .accessibilityHint("Choose a category for your item")
        }
    }
    
    private var datesSection: some View {
        Section(header: Text("Dates").foregroundStyle(itemCategory.color)) {
            HStack {
                Text("Date Created:")
                    .font(.system(size: 18))
                    .foregroundStyle(itemCategory.color)
                Spacer()
                Text(dateAdded.formatted(.dateTime))
                    .font(.system(size: 18))
                    .foregroundStyle(itemCategory.color)
                    .padding(.trailing, 12)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Created: \(dateAdded.formatted(.dateTime))")
            datePickersForCategory()
        }
    }
    
    // MARK: - Toolbar Items
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .principal) {
                LogoView()
                    .padding(.horizontal)
                    .accessibilityLabel("App Logo")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveEditedItem()
                }
                .font(.callout)
                .fontDesign(.serif)
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(itemCategory.color)
                .disabled(!hasFormChanged)
                .accessibilityLabel("Save Changes")
                .accessibilityHint("Tap to save your edited item. Disabled until changes are made.")
            }
        }
    }
    
    // MARK: - Private Computed Properties
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
    private func saveEditedItem() {
        editItem.title = title
        editItem.remarks = remarks
        editItem.dateAdded = dateAdded
        editItem.dateDue = dateDue
        editItem.dateStarted = dateStarted
        editItem.dateCompleted = dateCompleted
        editItem.category = itemCategory.rawValue
        
        do {
            try context.save()
            HapticsManager.notification(type: .success)
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    @ViewBuilder
    private func datePickersForCategory() -> some View {
        DatePicker("Due", selection: $dateDue)
            .foregroundStyle(itemCategory.color)
            .accessibilityLabel("Due Date")
            .accessibilityHint("Select the due date for your item")
        
        if itemCategory == .today || itemCategory == .work {
            DatePicker("Started", selection: $dateStarted)
                .foregroundStyle(itemCategory.color)
                .accessibilityLabel("Start Date")
                .accessibilityHint("Select the start date for your item")
        }
        
        if itemCategory == .today {
            DatePicker("Completed", selection: $dateCompleted)
                .foregroundStyle(itemCategory.color)
                .accessibilityLabel("Completion Date")
                .accessibilityHint("Select the completion date for your item")
        }
    }
    
    private func relativeLuminance(color: Color) -> Double {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private func contrastRatio(l1: Double, l2: Double) -> Double {
        let lighter = max(l1, l2), darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private func calculateContrastingColor(background: Color) -> Color {
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 4.5 && whiteContrast >= blackContrast ? .white : .black
    }
}

extension Color {
    func darker() -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(red: max(red - 0.2, 0), green: max(green - 0.2, 0), blue: max(blue - 0.2, 0), opacity: alpha)
    }
}

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
