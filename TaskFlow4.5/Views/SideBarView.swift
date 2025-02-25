//
//  SideBarView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/24/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Button("Close") {
                withAnimation {
                    isPresented = false
                }
            }
            .padding()
            .foregroundStyle(.blue)
            
            Spacer()
            Text("Sidebar Content")
                .font(.headline)
            // Add more sidebar items here
            Spacer()
        }
        .frame(width: 250, alignment: .leading)
        .background(Color(.systemGray6))
        .frame(maxWidth: .infinity, alignment: .leading)
        .edgesIgnoringSafeArea(.all)
    }
}
