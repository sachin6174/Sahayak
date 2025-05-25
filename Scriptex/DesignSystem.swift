// MIT License
//
// Copyright (c) [2020-present] Alexis Bridoux
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

// MARK: - ScriptexColors

struct ScriptexColors {
    // Primary Colors
    static let primary = Color(red: 0.0, green: 0.5, blue: 0.5) // Deep Teal
    static let secondary = Color(red: 1.0, green: 0.4, blue: 0.3) // Coral for CTAs
    static let accent = Color(red: 0.7, green: 0.9, blue: 0.9) // Light Aqua for highlights
    
    // Neutral Colors
    static let background = Color(red: 0.95, green: 0.97, blue: 0.98) // Off-white background
    static let cardBackground = Color.white
    static let text = Color(red: 0.15, green: 0.15, blue: 0.15) // Near-black text
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4) // Gray text
    
    // Functional Colors
    static let success = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let warning = Color(red: 0.95, green: 0.77, blue: 0.2)
    static let error = Color(red: 0.85, green: 0.2, blue: 0.2)
    
    // Sidebar Colors
    static let sidebarBackground = Color(red: 0.18, green: 0.23, blue: 0.25)
    static let sidebarText = Color.white
    static let sidebarHighlight = primary.opacity(0.7)
    static let sidebarSelected = primary
}

// MARK: - ScriptexFonts

struct ScriptexFonts {
    static let titleLarge = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let subtitle = Font.system(size: 18, weight: .medium, design: .rounded)
    static let body = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let button = Font.system(size: 14, weight: .medium)
}

// MARK: - ScriptexPadding

struct ScriptexPadding {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}

// MARK: - ScriptexRadius

struct ScriptexRadius {
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
}

// MARK: - ScriptexShadow

struct ScriptexShadow {
    static func small<T: View>(on content: T) -> some View {
        content.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    static func medium<T: View>(on content: T) -> some View {
        content.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - ButtonStyles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ScriptexFonts.button)
            .padding(.horizontal, ScriptexPadding.medium)
            .padding(.vertical, ScriptexPadding.small)
            .background(configuration.isPressed ? ScriptexColors.secondary.opacity(0.8) : ScriptexColors.secondary)
            .foregroundColor(.white)
            .cornerRadius(ScriptexRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ScriptexFonts.button)
            .padding(.horizontal, ScriptexPadding.medium)
            .padding(.vertical, ScriptexPadding.small)
            .background(configuration.isPressed ? ScriptexColors.accent.opacity(0.7) : ScriptexColors.accent)
            .foregroundColor(ScriptexColors.primary)
            .cornerRadius(ScriptexRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(ScriptexPadding.small)
            .background(configuration.isPressed ? Color.black.opacity(0.05) : Color.clear)
            .cornerRadius(ScriptexRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - TextFieldStyles

struct ScriptexTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(ScriptexPadding.medium)
            .background(ScriptexColors.cardBackground)
            .cornerRadius(ScriptexRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                    .stroke(ScriptexColors.accent, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Card View

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(ScriptexPadding.medium)
            .background(ScriptexColors.cardBackground)
            .cornerRadius(ScriptexRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - SectionTitle

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(ScriptexFonts.title)
            .foregroundColor(ScriptexColors.primary)
            .padding(.bottom, ScriptexPadding.small)
    }
}

// MARK: - Extensions

extension View {
    func cardStyle() -> some View {
        self
            .padding(ScriptexPadding.medium)
            .background(ScriptexColors.cardBackground)
            .cornerRadius(ScriptexRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func smallShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func mediumShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
