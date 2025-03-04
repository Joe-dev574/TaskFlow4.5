//
//  TaskListView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/3/25.
//

import SwiftUI

struct TaskListView: View {
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    ForEach(0..<100) { index in
                        Text("thois is a place holder text  \(index)")
                        
                    }.foregroundStyle(.mediumGrey)
                }
            }
        }
    }
}
#Preview {
    TaskListView()
}
