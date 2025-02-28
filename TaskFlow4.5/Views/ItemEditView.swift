//
//  ItemEditView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/23/25.
//

import SwiftData
import SwiftUI

/// A view for editing items with category-based color theming and distinct sections
struct ItemEditView: View {
    // MARK: - Environment Properties
    @Environment(\.modelContext) private var context  // SwiftData context for persistence
    @Environment(\.dismiss) private var dismiss       // Environment value to dismiss the view
    
    let item: Item  // The original item being edited (immutable reference)
    
    // MARK: - State Properties
    private let editItem: Item                        // Working copy of the item for editing
    @State private var title: String                  // Item title
    @State private var remarks: String                // Item description
    @State private var dateAdded: Date                // Creation date
    @State private var dateDue: Date                  // Due date
    @State private var dateStarted: Date              // Start date
    @State private var dateCompleted: Date            // Completion date
    @State private var itemCategory: Category         // Item category
    @State private var itemStatus: Item.Status        // Item status
    @State private var categoryAnimationTrigger: Bool = false  // Trigger for category change animation
    @State private var showErrorAlert: Bool = false   // Controls error alert visibility
    @State private var errorMessage: String = ""      // Error message text
    @State private var showTags = false               // Controls tags sheet visibility
    
    // MARK: - Initial Values for Comparison
    private let initialTitle: String                  // Initial title for change detection
    private let initialRemarks: String                // Initial remarks for change detection
    private let initialDateAdded: Date                // Initial added date for change detection
    private let initialDateDue: Date                  // Initial due date for change detection
    private let initialDateStarted: Date              // Initial start date for change detection
    private let initialDateCompleted: Date            // Initial completion date for change detection
    private let initialCategory: Category             // Initial category for change detection
    private let initialStatus: Item.Status            // Initial status for change detection
    private let initialTags: [Tag]?                   // Initial tags for change detection

    // MARK: - Initialization
    init(editItem: Item) {
        self.item = editItem                         // Initialize the immutable item reference
        self.editItem = editItem                     // Set the working copy
        
        // Initialize state properties with current item values
        _title = State(initialValue: editItem.title)
        _remarks = State(initialValue: editItem.remarks)
        _dateAdded = State(initialValue: editItem.dateAdded)
        _dateDue = State(initialValue: editItem.dateDue)
        _dateStarted = State(initialValue: editItem.dateStarted)
        _dateCompleted = State(initialValue: editItem.dateCompleted)
        _itemCategory = State(initialValue: Category(rawValue: editItem.category) ?? .today)
        _itemStatus = State(initialValue: Item.Status(rawValue: editItem.status)!)
        
        // Store initial values for change comparison
        initialTitle = editItem.title
        initialRemarks = editItem.remarks
        initialDateAdded = editItem.dateAdded
        initialDateDue = editItem.dateDue
        initialDateStarted = editItem.dateStarted
        initialDateCompleted = editItem.dateCompleted
        initialCategory = Category(rawValue: editItem.category) ?? .today
        initialStatus = Item.Status(rawValue: editItem.status)!
        initialTags = editItem.tags                  // Capture initial tags for comparison
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView    // Background gradient layer
            contentView       // Main content layer
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)  // Support for large text sizes
    }

    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .gray.opacity(0.02),    // Light gray top
                .gray.opacity(0.1)      // Darker gray bottom
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .scaleEffect(categoryAnimationTrigger ? 1.1 : 1.0)  // Scale animation for category change
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: categoryAnimationTrigger)
        .onChange(of: itemCategory) { _, _ in
            withAnimation {
                categoryAnimationTrigger = true           // Trigger scale animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    categoryAnimationTrigger = false      // Reset after 0.5 seconds
                }
            }
        }
    }

    // MARK: - Content View
    private var contentView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {    // Main content stack with sections
                    titleSection
                    remarksSection
                    categorySection
                    tagsSection
                    statusSection
                    datesSection
                }
                .padding()
            }
            .navigationTitle(title)      // Dynamic navigation title
            .toolbar { toolbarItems }    // Custom toolbar with save button
            .foregroundStyle(calculateContrastingColor(background: itemCategory.color))
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { showErrorAlert = false }
            } message: {
                Text(errorMessage)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }

    // MARK: - Section Styling Configuration
    private struct SectionStyle {
        static let cornerRadius: CGFloat = 12        // Corner radius for sections
        static let padding: CGFloat = 16             // Padding for sections
        static let backgroundOpacity: Double = 0.001 // Base background opacity
        static let reducedOpacity: Double = backgroundOpacity * 0.35  // Reduced opacity for layering
    }

    // MARK: - Content Sections
    // MARK: Item Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .foregroundStyle(.mediumGrey)          // Section title in medium grey
                .font(.headline)
            
            LabeledContent {
                TextField("Enter title of item...", text: $title)
                    .foregroundStyle(.mediumGrey)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .accessibilityLabel("Item Title")
                    .accessibilityHint("Enter the title of your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: Item Description Text Editor
    private var remarksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brief Description")
                .foregroundStyle(.mediumGrey)          // Section title in medium grey
                .font(.headline)
            
            LabeledContent {
                TextEditor(text: $remarks)
                    .foregroundStyle(.mediumGrey)
                    .frame(minHeight: 85)
                    .padding(4)
                    .background(Color("LightGrey").opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 2))
                    .accessibilityLabel("Item Description")
                    .accessibilityHint("Enter a brief description of your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .foregroundStyle(.mediumGrey)          // Section title in medium grey
                .font(.headline)
            
            LabeledContent {
                CategorySelector(
                    selectedCategory: $itemCategory,
                    animateColor: .constant(itemCategory.color),
                    animate: .constant(false)
                )
                .foregroundStyle(.primary)
                .accessibilityLabel("Category Selector")
                .accessibilityHint("Choose a category for your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: Tag Section
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .foregroundStyle(.mediumGrey)          // Section title in medium grey
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                // Display existing tags in a horizontal scroll view
                if let tags = editItem.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                TagItemView(
                                    tag: tag,
                                    onDelete: {
                                        // Remove tag from the editable item's tags array
                                        if let index = editItem.tags?.firstIndex(of: tag) {
                                            editItem.tags?.remove(at: index)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .frame(height: 40)
                } else {
                    Text("No tags added")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                }
                
                // Button to show tags management sheet
                Button {
                    HapticsManager.notification(type: .success)  // Haptic feedback on tap
                    showTags.toggle()                            // Toggle tag management sheet
                } label: {
                    Label("Manage Tags", systemImage: "tag")
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .foregroundStyle(itemCategory.color)     // Match button color to category
                }
                .overlay(
                    RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                        .stroke(itemCategory.color.opacity(0.9), lineWidth: 3)
                )
                .sheet(isPresented: $showTags) {
                    TagView(item: editItem)                     // Pass editable item to TagView
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .foregroundStyle(.mediumGrey)          // Section title in medium grey
                .font(.headline)
            
            LabeledContent {
                Picker("Status", selection: $itemStatus) {
                    ForEach(Item.Status.allCases, id: \.self) { status in
                        Text(status.descr)
                            .tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Status Picker")
                .accessibilityHint("Select the status of your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: Dates Section
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dates")
                .foregroundStyle(.mediumGrey)          // Section title in medium grey
                .font(.headline)
            
            VStack(spacing: 8) {
                LabeledContent("Created") {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .foregroundStyle(.gray.opacity(0.2))
                        Text(dateAdded.formatted(.dateTime))
                            .font(.system(size: 16))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 195, height: 35)
                    .foregroundStyle(itemCategory.color)
                    .padding(.trailing, 3)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Created \(dateAdded.formatted(.dateTime))")
                }.foregroundStyle(itemCategory.color)
                datePickersForCategory()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 1)
        )
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
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(itemCategory.color)
                .disabled(!hasFormChanged)  // Disable if no changes made
                .accessibilityLabel("Save Changes")
                .accessibilityHint("Tap to save your edited item. Disabled until changes are made.")
            }
        }
    }

    // MARK: - Private Computed Properties
    private var hasFormChanged: Bool {
        // Check if any field has changed from initial values, including tags
        title != initialTitle ||
        remarks != initialRemarks ||
        dateAdded != initialDateAdded ||
        dateDue != initialDateDue ||
        dateStarted != initialDateStarted ||
        dateCompleted != initialDateCompleted ||
        itemCategory != initialCategory ||
        itemStatus != initialStatus ||
        editItem.tags != initialTags
    }

    // MARK: - Private Methods
    private func saveEditedItem() {
        // Update working copy with current values
        editItem.title = title
        editItem.remarks = remarks
        editItem.dateAdded = dateAdded
        editItem.dateDue = dateDue
        editItem.dateStarted = dateStarted
        editItem.dateCompleted = dateCompleted
        editItem.category = itemCategory.rawValue
        editItem.status = itemStatus.rawValue
        // Note: Tags are updated in-place via the tagsSection
        
        do {
            try context.save()              // Save changes to SwiftData
            HapticsManager.notification(type: .success)  // Success feedback
            dismiss()                      // Close the view
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)")
        }
    }

    @ViewBuilder
    private func datePickersForCategory() -> some View {
        VStack(spacing: 12) {
            LabeledContent("Due") {
                DatePicker("", selection: $dateDue)
                    .labelsHidden()
                    .foregroundStyle(itemCategory.color)
                    .font(.caption)
            }
            .foregroundStyle(itemCategory.color)
            .accessibilityLabel("Due Date")
            .accessibilityHint("Select the due date for your item")
            
            if itemCategory == .today || itemCategory == .work {
                LabeledContent("Start") {
                    DatePicker("", selection: $dateStarted)
                        .labelsHidden()
                        .foregroundStyle(itemCategory.color)
                        .font(.caption)
                }
                .foregroundStyle(itemCategory.color)
                .accessibilityLabel("Start Date")
                .accessibilityHint("Select the start date for your item")
            }
            
            if itemCategory == .today {
                LabeledContent("Finish") {
                    DatePicker("", selection: $dateCompleted)
                        .labelsHidden()
                        .foregroundStyle(itemCategory.color)
                        .font(.caption)
                }
                .foregroundStyle(itemCategory.color)
                .accessibilityLabel("Completion Date")
                .accessibilityHint("Select the completion date for your item")
            }
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
        // Calculate contrasting color for readability
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 7 && whiteContrast >= blackContrast ? .white : .black
    }
}

// MARK: - Tag Item View
struct TagItemView: View {
    let tag: Tag            // The tag to display
    let onDelete: () -> Void  // Closure to handle tag deletion
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name)
                .foregroundStyle(Color("MediumGrey"))     // Use converted tag color for text
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
            
            Button(action: onDelete) {
                Image(systemName: "minus.circle")
                    .foregroundStyle(.mediumGrey.opacity(0.80)) // Use converted tag color for delete icon
                    .frame(width: 35, height: 35)
            }
            .buttonStyle(.plain)
        }
        .background(tag.swiftUIColor.opacity(0.5))     // Subtle background with tag's color
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(tag.swiftUIColor.opacity(0.5), lineWidth: 1)  // Border with tag's color
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tag: \(tag.name)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Color Extension
extension Color {
    func darker() -> Color {
        // Create a darker version of the color
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(red: max(red - 0.2, 0), green: max(green - 0.2, 0), blue: max(blue - 0.2, 0), opacity: alpha)
    }
}

// MARK: - Tag Extension
extension Tag {
    var swiftUIColor: Color {
        switch color.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "gray": return .gray
        case "black": return .black
        case "white": return .white
        default:
            // Handle hex codes (e.g., "#FF0000") or fallback to gray
            if color.hasPrefix("#"), color.count == 7 {
                let hex = String(color.dropFirst())
                if let intValue = UInt32(hex, radix: 16) {
                    let r = Double((intValue >> 16) & 0xFF) / 255.0
                    let g = Double((intValue >> 8) & 0xFF) / 255.0
                    let b = Double(intValue & 0xFF) / 255.0
                    return Color(red: r, green: g, blue: b)
                }
            }
            return .gray  // Fallback color if unrecognized
        }
    }
}
