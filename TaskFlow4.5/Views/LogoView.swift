//
//  LogoView.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/1/25.
//


import SwiftUI

/// A custom view that displays the app logo with an animated sun icon and stylized text
struct LogoView: View {
    // MARK: - Animation Properties
    @State private var rotationAngle: Double = 0.0
    @State private var scale: Double = 1.0
    @State private var animationCount: Int = 0
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            // Animated background sun icon
            Image(systemName: "gear")
                .resizable()
                .frame(width: Constants.sunSize, height: Constants.sunSize)
                .foregroundColor(.secondary)
                .offset(y: -7)
                .opacity(Constants.sunOpacity)
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(scale)
                .onAppear {
                    startAnimation()
                }
            
            // Main logo text container
            HStack(spacing: 0) {
                // "Orbit" text component
                Text("Daily")
                    .font(.callout)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                // "Plan" text component
                Text("Grind")
                    .font(.callout)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Version number
                Text("1.0")
                    .font(.caption)
                    .fontDesign(.serif)
                    .fontWeight(.regular)
                    .foregroundColor(.blue)
                    .offset(y: -5)
                    .padding(.leading, 1)
            }
            .offset(x: 5)
        }
    }
    
    // MARK: - Constants
    private enum Constants {
        static let sunSize: CGFloat = 45
        static let sunOpacity: Double = 0.3
        static let maxAnimationCount: Int = 1
        static let rotationDuration: Double = 3
        static let pulseDuration: Double = 2.5
    }
    
    // MARK: - Animation Logic
    private func startAnimation() {
        animationCount = 0
        
        // Pulse animation (4 cycles)
        withAnimation(.easeInOut(duration: Constants.pulseDuration).repeatCount(Constants.maxAnimationCount * 2, autoreverses: true)) {
            scale = 1.2
        }
        
        // Rotation animation (2 full rotations)
        let rotationAnimation = Animation.linear(duration: Constants.rotationDuration)
            .repeatCount(Constants.maxAnimationCount, autoreverses: false)
        
        withAnimation(rotationAnimation) {
            rotationAngle = 180 * Double(Constants.maxAnimationCount)
        }
        
        // Reset after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.rotationDuration * Double(Constants.maxAnimationCount)) {
            rotationAngle = 0
            scale = 1.0
            animationCount = Constants.maxAnimationCount
        }
    }
}

// MARK: - Preview
#Preview {
    LogoView()
        .padding()
        .background(Color(.systemBackground))
}
