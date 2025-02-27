//
//  LogoView.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/1/25.
//


import SwiftUI

struct LogoView: View {
    // MARK: - Animation States
    @State private var rotationAngle: Double = 0.0
    @State private var gearOpacity: Double = Constants.initialGearOpacity
    @State private var gearScale: Double = 1.0    // New: scale for pulse effect
    @State private var textOffset: CGFloat = 0.0  // New: text bounce
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: Constants.spacing) {
            // Enhanced gear icon with dynamic effects
            Image(systemName: "gearshape.fill")  // Changed to filled gear for bolder look
                .resizable()
                .frame(width: Constants.gearSize, height: Constants.gearSize)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.remark, .blue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )  // Gradient color for adventure
                .opacity(gearOpacity)
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(gearScale)  // New: pulse effect
                .shadow(color: .blue.opacity(0.3), radius: 3, x: 0, y: 2)  // New: subtle glow
                .onAppear(perform: startAnimation)
                .accessibilityLabel("Animated adventurous gear")
            
            // Enhanced text group with motion
            HStack(spacing: Constants.textSpacing) {
                Text("Daily")
                    .font(.custom("Avenir-Black", size: 16))  // Bolder custom font
                    .foregroundStyle(.primary)  // More adventurous color
                    .offset(y: textOffset)     // New: bounce effect
                
                Text("Grind")
                    .font(.custom("Avenir-Black", size: 16))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .gray.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )  // Gradient for excitement
                    .offset(y: -textOffset)    // Opposite bounce
                
                Text("1.0")
                    .font(.custom("Avenir-Medium", size: 12))
                    .foregroundStyle(.orange.opacity(0.9))
                    .rotationEffect(.degrees(10))  // Slight tilt for dynamism
            }
            .shadow(radius: 1)  // Subtle text shadow
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Daily Grind version 1.0")
        }
        .frame(maxHeight: Constants.maxHeight)  // Adjusted to 40 as requested
    }
    
    // MARK: - Constants
    private enum Constants {
        static let gearSize: CGFloat = 30
        static let initialGearOpacity: Double = 0.9
        static let finalGearOpacity: Double = 0.7
        static let spacing: CGFloat = 5
        static let textSpacing: CGFloat = 2
        static let fastDuration: Double = 0.7
        static let slowDuration: Double = 0.5
        static let fadeDuration: Double = 0.2
        static let pulseDuration: Double = 0.8
        static let fastRotations: Double = 4
        static let maxHeight: CGFloat = 45  // Updated to match your requirement
    }
    
    // MARK: - Animation
    private func startAnimation() {
        // Fast gear spin with pulse
        withAnimation(.linear(duration: Constants.fastDuration)) {
            rotationAngle = 360 * Constants.fastRotations
            gearScale = 1.2  // Slight grow
        }
        
        // Slow down with bounce back
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration) {
            withAnimation(.spring(response: Constants.slowDuration, dampingFraction: 0.6)) {
                rotationAngle = 360 * Constants.fastRotations + 45  // 45° settle
                gearScale = 0.9  // Slight shrink
                textOffset = 2   // Text bounce up
            }
        }
        
        // Final settle with fade
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration) {
            withAnimation(.easeInOut(duration: Constants.fadeDuration)) {
                gearOpacity = Constants.finalGearOpacity
                gearScale = 1.0    // Back to normal
                textOffset = 0     // Text settle
            }
        }
        
        // Continuous subtle pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration + Constants.fadeDuration) {
            withAnimation(.easeInOut(duration: Constants.pulseDuration).repeatForever(autoreverses: true)) {
                gearScale = 1.05
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LogoView()
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)  // Dark mode for contrast
}
