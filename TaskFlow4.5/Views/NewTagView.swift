//
//  NewTagView.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/2/25.
//

import SwiftUI

struct NewTagView: View {
    @State private var name = ""
    @State private var color = Color.red
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        LogoView()
        NavigationStack {
            VStack {
                TextField("Name of Tag.  Choose a Keyword", text: $name)
                    .font(.system(size: 16))
                    .fontDesign(.serif)
                    .padding()
                    .foregroundStyle(.primary)
                    .background(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1))
                    .padding(.bottom, 10)
                ColorPicker("                          Choose a Color", selection: $color, supportsOpacity: false)
                    .fontDesign(.serif)
                Button("Create") {
                    let newTag = Tag(name: name, color: color.toHexString()!)
                    context.insert(newTag)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(name.isEmpty)
            }
            .padding()
            .background(Color.black.opacity(0.04), in: .rect(cornerRadius: 10))
            .padding(.horizontal, 7)
      
         
            Spacer( )
        }
    }
    
}
#Preview {
    NewTagView()
}
