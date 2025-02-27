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
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    private let editItem: Item
    @State private var title: String
    @State private var remarks: String
    @State private var dateAdded: Date
    @State private var dateDue: Date
    @State private var dateStarted: Date
    @State private var dateCompleted: Date
    @State private var itemCategory: Category
    @State private var itemStatus: Item.Status
    @State private var categoryAnimationTrigger: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    // MARK: - Initial Values for Comparison
    private let initialTitle: String
    private let initialRemarks: String
    private let initialDateAdded: Date
    private let initialDateDue: Date
    private let initialDateStarted: Date
    private let initialDateCompleted: Date
    private let initialCategory: Category
    private let initialStatus: Item.Status

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
        _itemStatus = State(initialValue: Item.Status(rawValue: editItem.status)!)

        initialTitle = editItem.title
        initialRemarks = editItem.remarks
        initialDateAdded = editItem.dateAdded
        initialDateDue = editItem.dateDue
        initialDateStarted = editItem.dateStarted
        initialDateCompleted = editItem.dateCompleted
        initialCategory = Category(rawValue: editItem.category) ?? .today
        initialStatus = Item.Status(rawValue: editItem.status)!
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .gray.darker().opacity(0.02),
                .gray.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .scaleEffect(categoryAnimationTrigger ? 1.1 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: categoryAnimationTrigger)
        .onChange(of: itemCategory) { _, _ in
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
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    remarksSection
                    categorySection
                    statusSection
                    datesSection
                }
                .padding()
            }
            .navigationTitle(title)
            .toolbar { toolbarItems }
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
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let backgroundOpacity: Double = 0.1
        static let reducedOpacity: Double = backgroundOpacity * 0.25 // 75% reduction: 0.1 * 0.25 = 0.025
    }

    // MARK: - Content Sections
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .foregroundStyle(itemCategory.color)
                .font(.headline)
            
            LabeledContent {
                TextField("Enter title of item...", text: $title)
                    .foregroundStyle(.white)
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

    private var remarksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brief Description")
                .foregroundStyle(itemCategory.color)
                .font(.headline)
            
            LabeledContent {
                TextEditor(text: $remarks)
                    .foregroundStyle(.white)
                    .frame(minHeight: 85)
                    .padding(4)
                    .background(Color("LightGrey").opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
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

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .foregroundStyle(itemCategory.color)
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

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .foregroundStyle(itemCategory.color)
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

    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dates")
                .foregroundStyle(itemCategory.color)
                .font(.headline)
            
            VStack(spacing: 8) {
                LabeledContent("Created") {
                    Text(dateAdded.formatted(.dateTime))
                        .font(.caption)
                        .foregroundStyle(itemCategory.color)
                }
                .foregroundStyle(itemCategory.color)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Created \(dateAdded.formatted(.dateTime))")
                
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
        itemCategory != initialCategory ||
        itemStatus != initialStatus
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
        editItem.status = itemStatus.rawValue
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
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 7 && whiteContrast >= blackContrast ? .white : .black
    }
}

// MARK: - Color Extension
extension Color {
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
        dateCompleted: .now,
        status: Item.Status.Active,
        category: Category.today,
        tint: "TaskColor 1"
    )
    ItemEditView(editItem: sampleItem)
        .preferredColorScheme(.light)
}
