//
//  ItemScreen.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftData
import SwiftUI

/// A view displaying a list of items with a fixed toolbar for navigation and actions
struct ItemScreen: View {
    // MARK: - Environment and State Properties
    // Environment for managing object context in Core Data
    @Environment(\.modelContext) private var modelContext
    @State private var showAddItemSheet: Bool = false  // Toggles the add item sheet visibility
    @State private var showSidebar: Bool = false  // Toggles the sidebar visibility
    @State private var currentDate: Date = Date()  // Tracks current date for header display

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {  // Use ZStack to layer content and button
                ScrollView {  // Isolate scrolling to ItemList
                    VStack(alignment: .leading, spacing: 0) {
                        ItemList()  // Displays the list of items
                            .padding(.top, 10)  // Add padding to avoid overlap with toolbar
                    }
                    .frame(maxWidth: .infinity)  // Ensure full width
                }
                .scrollContentBackground(.hidden)  // Optional: hide default scroll background

                addItemButton  // Floating action button pinned to bottom-right
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: .bottomTrailing)
            }
            .blur(radius: showAddItemSheet ? 8 : 0)  // Blurs content when sheet is active
            .sheet(isPresented: $showAddItemSheet) {  // Presents sheet for adding new items
                AddItem()
                    .presentationDetents([.large])
            }
            .toolbar { toolbarItems }  // Configures fixed toolbar
            .toolbarBackground(.visible, for: .navigationBar)  // Ensures toolbar background stays visible
            .navigationBarTitleDisplayMode(.inline)  // Keeps toolbar compact and pinned
        }
        .overlay {  // Sidebar overlay with transition
            if showSidebar {
                SidebarView(isPresented: $showSidebar)
                    .transition(.move(edge: .leading))
            }
        }
    }

    // MARK: - Subviews
    /// Floating button to trigger the add item sheet
    private var addItemButton: some View {
        Button(action: {
            showAddItemSheet = true
            HapticsManager.notification(type: .success)  // Provides haptic feedback on tap
        }) {
            Image(systemName: "plus")
                .font(.callout)
                .foregroundStyle(.white)
                .frame(width: 45, height: 45)
                .background(.blue)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)
        }
        .padding()  // Adds padding around button
        .accessibilityLabel("Add New Item")
    }

    /// Custom header view for the toolbar
    @ViewBuilder
    private func headerView() -> some View {
        HStack(spacing: 8) {  // Reduced crowding with tighter spacing
            VStack(alignment: .leading, spacing: 2) {  // Compact vertical stack for date
                Text(currentDate.format("MMMM YYYY"))  // Combines month and year in one line
                    .font(.headline.bold())  // Smaller, bold font for clarity
                    .foregroundStyle(.blue)

                Text(currentDate.format("EEEE, d"))  // Day and weekday on second line
                    .font(.caption)  // Smaller font for less emphasis
                    .foregroundStyle(.gray)
            }
            Spacer()  // Pushes logo to the right

            GearButtonView()  // Compact logo
                .frame(width: 30, height: 25)  // Reduced size for toolbar fit
                .foregroundStyle(.taskColor7)
        }
        .padding(.horizontal, 8)  // Consistent horizontal padding
    }

    // MARK: - Toolbar Configuration
    /// Defines toolbar items for navigation and actions
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {  // Sidebar toggle button
                Button(action: {
                    withAnimation {
                        showSidebar.toggle()  // Uncommented to enable sidebar
                    }
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(.blue)
                }
                .accessibilityLabel("Toggle Sidebar")
            }

            ToolbarItem(placement: .principal) {  // Custom header in center
                headerView().padding(.bottom, 7)
            }

            ToolbarItem(placement: .navigationBarTrailing) {  // Profile navigation link
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.circle")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .accessibilityLabel("Profile")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ItemScreen()
}
