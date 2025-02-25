//
//  LogoView.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/1/25.
//


import SwiftUI

/// A custom SwiftUI view that displays an animated logo with a gear and text
struct LogoView: View {
    // MARK: - Animation States
    @State private var rotationAngle: Double = 0.0    // Tracks gear rotation in degrees
    @State private var scale: Double = 1.0           // Controls gear scaling factor
    @State private var textOpacity: Double = 0.0     // Manages text visibility (0 to 1)
    @State private var textOffset: CGFloat = 50.0    // Initial vertical offset for text entrance
    @State private var gearOpacity: Double = Constants.initialGearOpacity  // Dynamic gear opacity
    @State private var animationCount: Int = 0       // Counts animation cycles completed
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Gear icon with animation properties
            Image(systemName: "gearshape")
                .resizable()                            // Allows size adjustment
                .frame(width: Constants.gearSize, height: Constants.gearSize)  // Sets gear dimensions
                .foregroundStyle(.gearShape)            // Applies system gear color
                .offset(y: Constants.gearOffset)        // Positions gear vertically
                .opacity(gearOpacity)                   // Controls gear visibility
                .rotationEffect(.degrees(rotationAngle)) // Rotates gear based on angle
                .scaleEffect(scale)                     // Scales gear size
                .onAppear(perform: startAnimation)      // Triggers animation on view appearance
                .accessibilityLabel("Animated gear icon")  // Accessibility description
            
            // Text group with "Daily Grind" and version
            HStack(spacing: Constants.textSpacing) {
                Text("Daily")
                    .font(.callout)                     // Sets font size
                    .fontDesign(.serif)                 // Uses serif style
                    .fontWeight(.bold)                  // Makes text bold
                    .foregroundStyle(.blue)             // Sets text color to blue
                
                Text("Grind")
                    .font(.callout)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .foregroundStyle(.taskColor7)          // Uses primary color (typically black/white)
                
                Text("1.0")
                    .font(.caption)                     // Smaller font for version
                    .fontDesign(.serif)
                    .foregroundStyle(.blue)
                    .offset(y: Constants.versionOffset) // Adjusts version number position
                    .padding(.leading, Constants.versionPadding)  // Adds spacing before version
            }
            .offset(x: Constants.textOffset)        // Horizontal alignment of text group
            .offset(y: textOffset)                  // Vertical animation position
            .opacity(textOpacity)                   // Fades text in/out
            .accessibilityElement(children: .ignore)  // Treats text as single unit for accessibility
            .accessibilityLabel("Daily Grind version 1.0")  // Combined accessibility label
        }
    }
    
    // MARK: - Constants
    private enum Constants {
        static let gearSize: CGFloat = 30            // Width and height of gear icon
        static let initialGearOpacity: Double = 0.7  // Starting opacity of gear
        static let finalGearOpacity: Double = 0.3    // Opacity after animation completes
        static let gearOffset: CGFloat = -7          // Vertical offset for gear positioning
        static let textSpacing: CGFloat = 0          // Spacing between text components
        static let textOffset: CGFloat = 5           // Final horizontal text position
        static let versionOffset: CGFloat = -5       // Vertical offset for version number
        static let versionPadding: CGFloat = 1       // Padding before version number
        static let fastDuration: Double = 0.4        // Duration of gear's fast spin
        static let slowDuration: Double = 0.6        // Duration of gear's slow-down phase
        static let textDuration: Double = 0.5        // Duration of text entrance animation
        static let fadeDuration: Double = 0.3        // Duration of gear opacity fade
        static let fastRotations: Double = 2         // Number of full rotations in fast phase
    }
    
    // MARK: - Animation
    /// Initiates the animation sequence for gear and text
    private func startAnimation() {
        animationCount = 0  // Reset animation counter
        
        // Gear fast spin phase
        withAnimation(.linear(duration: Constants.fastDuration)) {
            rotationAngle = 360 * Constants.fastRotations  // Spin 3 full rotations
            scale = 1.2                                   // Scale up gear
        }
        
        // Gear slow-down phase (currently commented out)
        // After fast spin, slows to final position and returns to normal size
//        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration) {
//            withAnimation(.easeOut(duration: Constants.slowDuration)) {
//                rotationAngle = 360 * Constants.fastRotations + 90  // Add quarter turn
//                scale = 1.0                                        // Return to normal size
//            }
//        }
        
        // Text entrance animation
        // Starts after fast spin, slides text up and fades it in
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration) {
            withAnimation(.easeOut(duration: Constants.textDuration)) {
                textOpacity = 1.0    // Make text fully visible
                textOffset = 0.0     // Move text to final position
            }
        }
        
        // Gear opacity fade
        // Reduces opacity after gear settles for better text contrast
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration) {
            withAnimation(.easeOut(duration: Constants.fadeDuration)) {
                gearOpacity = Constants.finalGearOpacity  // Fade to lower opacity
            }
        }
        
        // Reset animation states
        // Returns rotation to zero after full sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration + Constants.fadeDuration) {
            withAnimation {
                rotationAngle = 0     // Reset gear rotation
                animationCount = 1    // Mark animation as complete
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LogoView()
        .padding()                    // Adds padding around logo
        .background(Color(.systemBackground))  // Sets background to system default
        .preferredColorScheme(.light)          // Forces light mode for preview
}
