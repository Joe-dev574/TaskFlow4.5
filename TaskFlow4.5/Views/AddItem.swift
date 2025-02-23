//
//  AddItem.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/22/25.
//

import SwiftUI

struct AddItem: View {
    /// Env Properties
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
    @State private var itemCategory: Category = .today
  
    // MARK: - Animation Properties
    @State private var animateColor: Color = Category.work.color
    @State private var animate: Bool = false

    // MARK: - Initialization
    init(editItem: Item? = nil) {
        self.editItem = editItem
    }

    // MARK: - Body
    var body: some View {
        ZStack{
            itemCategory.color
            GeometryReader{
                let size = $0.size
                Rectangle()
                    .fill(animateColor)
                    .mask {
                        Circle()
                    }
                    .frame(width: animate ? size.width * 2 : 0, height: animate ? size.height * 2 : 0)
                    .offset(animate ? CGSize(width: -size.width / 2, height: -size.height / 2) : size)
            }
            .clipped()
            .ignoresSafeArea()
            
            NavigationStack {
                    Form{
                        Section("Title" ) {
                            CustomTextEditor(
                                remarks: $title,
                                placeholder: "Enter title here...",
                                minHeight: 50
                            )
                        }
                        
                        Section("Brief Description") {
                            CustomTextEditor(
                                remarks: $remarks,
                                placeholder: "Brief description here...",
                                minHeight: 100
                            )
                        }
                        
                        Section("Category") {
                            CategorySelector(
                                selectedCategory: $itemCategory,
                                animateColor: $animateColor,
                                animate: $animate
                            )
                        }.foregroundStyle(itemCategory.color)
                        
                        Section("Dates") {
                            HStack{
                                //MARK:  DATE CREATED DATA LINE
                                Text("Date Created: ")
                                    .foregroundStyle(.primary)
                                    .fontDesign(.serif)
                                    .font(.callout)
                                Spacer()
                                Text(dateAdded.formatted(.dateTime))
                                    .fontDesign(.serif)
                                    .foregroundColor(.primary)
                                    .font(.system(size: 18))
                                    .padding(.trailing, 12)
                            }
                            if itemCategory == .family {
                                DatePicker("Date Due", selection: $dateDue)
                            }
                            if itemCategory == .scheduled {
                                DatePicker("Date Due", selection: $dateDue)
                            }
                            if itemCategory == .today {
                                DatePicker("Date Due", selection: $dateDue)
                                DatePicker("Date Started", selection: $dateStarted)
                                DatePicker("Date Completed", selection: $dateCompleted)
                            }
                            if itemCategory == .work {
                                DatePicker("Date Due", selection: $dateDue)
                                DatePicker("Started", selection: $dateStarted)
                            }
                            if itemCategory == .health{
                                DatePicker("Date Due", selection: $dateDue)
                            }
                        }
                      
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                HapticsManager.notification(type: .success)
                                dismiss()
                            }
                            .fontDesign(.serif)
                            .foregroundStyle(itemCategory.color)
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
                            .foregroundStyle(itemCategory.color)
                            .disabled(!isFormValid)
                        }
                    }
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
            item.category = itemCategory.rawValue
            
            do {
                try context.save()
                HapticsManager.notification(type: .success)
                dismiss()
            } catch {
                print("Failed to save item: \(error.localizedDescription)")
                // TODO: Show user-facing error alert
            }
        }
    }
    // MARK: - Supporting Views
    struct CustomTextEditor: View {
        @Binding var remarks: String
        let placeholder: String
        let minHeight: CGFloat
        
        var body: some View {
            ZStack(alignment: .topLeading) {
                if remarks.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                
                TextEditor(text: $remarks)
                    .scrollContentBackground(.hidden)
                    .background(Color.gray.opacity(0.1))
                    .font(.system(size: 16))
                    .fontDesign(.serif)
                    .frame(minHeight: minHeight)
                    .foregroundStyle(.secondary)
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
                        .fill(category.color.opacity(isSelected ? 0.5 : 0.10))
                )
                .foregroundStyle(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray, lineWidth: isSelected ? 2 : 0)
                )
                .onTapGesture(perform: onTap)
        }
    }
#Preview {
    AddItem()
}
