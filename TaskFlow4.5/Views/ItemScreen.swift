//
//  ItemScreen.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftUI

/// A view that displays a list of items and provides functionality to add new items.
struct ItemScreen: View {
    // MARK: - Properties
    
    /// Environment object for managing Core Data context
    @Environment(\.modelContext) private var modelContext
    
    /// Controls the visibility of the add item sheet
    @State private var showAddItemSheet: Bool = false
    
    /// Tracks the current date for display purposes
    @State private var currentDate: Date = .init()
    
   
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderView()
                    VStack {
                        ItemList()
                    }
                }
            
        .overlay(alignment: .bottom) {
            // Floating action button to add new items
            Button(action: {
                showAddItemSheet = true
                HapticsManager.notification(type: .success) // Provides haptic feedback
            }) {
                Image(systemName: "plus")
                    .font(.callout)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
            }.background(.blue.shadow(.drop(color: .black.opacity(0.25), radius: 5, x: 10, y: 10)), in: .circle)
            .sheet(isPresented: $showAddItemSheet) {
                AddItem( )
                   .presentationDetents([.large])
            }
        }
        .blur(radius: showAddItemSheet ? 8 : 0) // Applies blur effect when sheet is presented
    }
    
    // MARK: - Subviews
    
    /// Displays the header with date information
    @ViewBuilder
    private func HeaderView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(currentDate.format("MMMM"))
                    .foregroundStyle(.blue)
                
                Text(currentDate.format("YYYY"))
                    .foregroundStyle(.gray)
                
                Spacer()
                Button(action: {
                    HapticsManager.notification(type: .success)
                }, label: {
                LogoView( )
            })
                       }
            .font(.title.bold())
            
            Text(currentDate.formatted(date: .complete, time: .omitted))
                .font(.callout)
                .fontWeight(.semibold)
                .textScale(.secondary)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Preview

#Preview {
    ItemScreen()
}
