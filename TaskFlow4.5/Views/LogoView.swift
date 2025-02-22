//
//  LogoView.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/1/25.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack{
            Image(systemName: "memorychip")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(.blue).opacity(0.3)
            HStack {
                Text("Mind")
                    .font(.callout)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .offset(x: 13, y: 1)
                Text("Flow")
                    .font(.callout)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .offset(x: 5, y: 1)
              
                Text("1.0")
                    .font(.caption)
                    .fontDesign(.serif)
                    .fontWeight(.regular)
                    .padding(.leading, 10)
                    .foregroundColor(.blue)
                    .offset(x: -15, y: -5)
            }.offset(x: 5)
        }
    }
}
#Preview {
    LogoView()
}
