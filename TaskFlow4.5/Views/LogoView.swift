//
//  LogoView.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/1/25.
//


import SwiftUI

/// A compact SwiftUI view for a toolbar logo with a gear and text
struct LogoView: View {
    // MARK: - Animation States
    @State private var rotationAngle: Double = 0.0    // Tracks gear rotation in degrees
    @State private var gearOpacity: Double = Constants.initialGearOpacity  // Dynamic gear opacity
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: Constants.spacing) {  // Horizontal layout for compact design
            // Gear icon with animation
            Image(systemName: "gearshape")
                .resizable()
                .frame(width: Constants.gearSize, height: Constants.gearSize)  // Smaller gear size
                .foregroundStyle(.primary)            // System gear color
                .opacity(gearOpacity)                   // Dynamic opacity
                .rotationEffect(.degrees(rotationAngle)) // Rotation animation
                .onAppear(perform: startAnimation)      // Start animation on appear
                .accessibilityLabel("Animated gear icon")
            
            // Condensed text group
            HStack(spacing: Constants.textSpacing) {
                Text("Daily")
                    .font(.caption)                     // Smaller font for toolbar
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                
                Text("Grind")
                    .font(.caption)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundStyle(.taskColor7)       // Assuming taskColor7 is defined elsewhere
                
                Text("1.0")
                    .font(.caption2)                    // Even smaller version number
                    .fontDesign(.serif)
                    .foregroundStyle(.blue)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Daily Grind version 1.0")
        }
        .frame(maxHeight: Constants.maxHeight)  // Restrict height for toolbar
    }
    
    // MARK: - Constants
    private enum Constants {
        static let gearSize: CGFloat = 25            // Reduced size for toolbar
        static let initialGearOpacity: Double = 0.7  // Starting gear opacity
        static let finalGearOpacity: Double = 0.3    // Final gear opacity
        static let spacing: CGFloat = 4              // Space between gear and text
        static let textSpacing: CGFloat = 1          // Tight spacing between text elements
        static let fastDuration: Double = 0.4        // Fast spin duration
        static let slowDuration: Double = 0.6        // Slow-down duration
        static let fadeDuration: Double = 0.3        // Opacity fade duration
        static let fastRotations: Double = 2         // Number of fast rotations
        static let maxHeight: CGFloat = 45           // Max height to fit toolbar
    }
    
    // MARK: - Animation
    /// Initiates the compact animation sequence
    private func startAnimation() {
        // Fast gear spin
        withAnimation(.linear(duration: Constants.fastDuration)) {
            rotationAngle = 360 * Constants.fastRotations  // Two full rotations
        }
        
        // Slow down phase
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration) {
            withAnimation(.easeOut(duration: Constants.slowDuration)) {
                rotationAngle = 360 * Constants.fastRotations + 90  // Quarter turn to settle
            }
        }
        
        // Gear opacity fade after settling
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration) {
            withAnimation(.easeOut(duration: Constants.fadeDuration)) {
                gearOpacity = Constants.finalGearOpacity  // Fade for contrast
            }
        }
        
        // Reset rotation
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration + Constants.fadeDuration) {
            withAnimation {
                rotationAngle = 0  // Reset to starting position
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LogoView()
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(.light)
}
