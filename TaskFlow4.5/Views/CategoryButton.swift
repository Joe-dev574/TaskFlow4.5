//
//  CategoryButton.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/23/25.
//

import SwiftUI

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
                        .fill(category.color.opacity(isSelected ? 0.6 : 0.10))
                )
                .foregroundStyle(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray, lineWidth: isSelected ? 2 : 0)
                )
                .onTapGesture(perform: onTap)
        }
    }
