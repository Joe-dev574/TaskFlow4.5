//
//  ItemScreen.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftUI
import SwiftData

/// A view displaying a list of items with a toolbar for navigation and actions
struct ItemScreen: View {
    // MARK: - State Properties
    @Environment(\.modelContext) private var modelContext  // SwiftData context
    @State private var showAddItemSheet: Bool = false      // Controls add item sheet visibility
    @State private var showSidebar: Bool = false           // Controls sidebar visibility
    @State private var currentDate: Date = Date()          // Current date for header
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ItemList()  // List of items
            }
            .frame(maxWidth: .infinity) // Ensures full width usage
            .overlay(alignment: .bottomTrailing) {
                // Floating action button for adding items
                Button(action: {
                    showAddItemSheet = true
                    HapticsManager.notification(type: .success)
                }) {
                    Image(systemName: "plus")
                        .font(.callout)
                        .foregroundStyle(.white)
                        .frame(width: 45, height: 45)
                        .background(.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)
                }
                .padding()
                .accessibilityLabel("Add New Item")
            }
            .blur(radius: showAddItemSheet ? 8 : 0) // Blurs content when sheet is shown
            .sheet(isPresented: $showAddItemSheet) {
                AddItem()
                    .presentationDetents([.large])
            }
            .toolbar {
                // Leading toolbar item: Sidebar menu toggle
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                  //          showSidebar.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Toggle Sidebar")
                }
                
                // Principal toolbar item: Custom header
                ToolbarItem(placement: .principal) {
                    HeaderView()
                }
                
                // Trailing toolbar item: Profile button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("Profile")
                }
            }
            .navigationBarTitleDisplayMode(.inline) // Keeps toolbar compact
        }
        .overlay(
            // Sidebar overlay
            Group {
                if showSidebar {
                    SidebarView(isPresented: $showSidebar)
                        .transition(.move(edge: .leading))
                }
            }
        )
    }
    @ViewBuilder
       private func HeaderView() -> some View {
           HStack {
               VStack(alignment: .leading, spacing: 6) {
                   HStack(spacing: 5) {
                       Text(currentDate.format("MMMM"))
                           .foregroundStyle(.blue)
                       Text(currentDate.format("YYYY"))
                           .foregroundStyle(.gray)
                   }
                   .font(.title3.bold())
                   
                   Text(currentDate.formatted(date: .complete, time: .omitted))
                       .font(.caption)
                       .fontWeight(.semibold)
                       .foregroundStyle(.gray)
               }
               Spacer()
              
                   LogoView()
                       .frame(width: 50, height: 50)
               }
               .buttonStyle(PlainButtonStyle())
               .padding(.horizontal, 5)
           }
       }
   


