//
//  ItemCardView.swift
//  Flow
//
//  Created by Joseph DeWeese on 1/31/25.
//

import SwiftUI
import SwiftData

/// A view that displays a card representation of an Item with its details
struct ItemCardView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var context // Access to SwiftData model context
    let item: Item // The item to display
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            SwipeAction(cornerRadius: 10, direction: .trailing) {
                ZStack {
                    // Background with material effect
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.ultraThinMaterial.opacity(1.0)) // Simplified opacity value
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Main content stack
                    VStack(alignment: .leading, spacing: 8) { // Added spacing for consistency
                        
                        // Category header
                        HStack(spacing: 12) {
                            Spacer() // Pushes category tag to right
                            Text(item.category)
                                .padding(4)
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 2, y: 2)
                        }
                        
                        // Title section with icon
                        HStack(spacing: 8) {
                            // Icon based on first letter of title
                            Text(String(item.title.prefix(1)))
                                .font(.title)
                                .fontWeight(.semibold)
                                .fontDesign(.serif)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                                .frame(width: 35, height: 35)
                                .background(
                                    Gradient(colors: [.blue, .purple]).opacity(0.8) // Replaced .inSelectedCategory with explicit gradient
                                )
                                .clipShape(Circle()) // Added for better visual appearance
                                .padding(5)
                            
                            // Item title
                            Text(item.title)
                                .font(.system(size: 18, weight: .semibold, design: .serif))
                                .foregroundStyle(.primary)
                                .lineLimit(1) // Prevents title from wrapping
                        }
                        
                        // Date section
                        HStack(spacing: 4) {
                            Spacer()
                            Text("Date Created:")
                                .foregroundStyle(.gray)
                            Image(systemName: "calendar.badge.clock")
                                .foregroundStyle(.gray)
                            Text(item.dateAdded, format: .dateTime) // Simplified date formatting
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .font(.system(size: 12, weight: .semibold, design: .serif))
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                        
                        // Remarks section (shown only if not empty)
                        if !item.remarks.isEmpty {
                            Text(item.remarks)
                                .font(.system(size: 14, design: .serif))
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 4)
                                .lineLimit(3)
                                .padding(.bottom, 4)
                        }
                        
                        
                    }
                    .padding(.horizontal, 7)
                    .padding( 4)
                }
            } actions: {
                Action(tint: .red, icon: "trash", action: {
                    context.delete(item)
                    //WidgetCentrer.shared.reloadAllTimneLines
                })
            }
        }
            // Card border overlay
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        .linearGradient(
                            colors: [.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
        }
    }


