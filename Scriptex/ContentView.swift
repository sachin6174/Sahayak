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

import UniformTypeIdentifiers
import SwiftUI

// MARK: - Section

enum AppSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case scriptExecution = "Script Execution"
    case appManager = "App Manager"
    case fileManager = "File Manager"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "speedometer"  // Changed from "gauge.fill" to a compatible icon
        case .scriptExecution: return "terminal.fill"
        case .appManager: return "app.badge.fill"
        case .fileManager: return "folder.fill"
        }
    }
    
    var description: String {
        switch self {
        case .dashboard: return "System information and status"
        case .scriptExecution: return "Execute scripts with elevated privileges"
        case .appManager: return "Manage installed applications"
        case .fileManager: return "Browse and manage files"
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @State private var selectedSection: AppSection = .dashboard
    @State private var showWelcomeAnimation = true
    
    var body: some View {
        GeometryReader { geometry in
            HSplitView {
                // Sidebar
                SidebarView(selectedSection: $selectedSection)
                    .frame(minWidth: 220, idealWidth: 240, maxWidth: 280)
                
                // Detail Content
                ZStack {
                    ScriptexColors.background
                        .ignoresSafeArea()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text(selectedSection.rawValue)
                                    .font(ScriptexFonts.titleLarge)
                                    .foregroundColor(ScriptexColors.primary)
                                
                                Text(selectedSection.description)
                                    .font(ScriptexFonts.subtitle)
                                    .foregroundColor(ScriptexColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Action buttons specific to each section could go here
                        }
                        .padding(.horizontal, ScriptexPadding.large)
                        .padding(.vertical, ScriptexPadding.medium)
                        .background(ScriptexColors.cardBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        // Content
                        ScrollView {
                            switch selectedSection {
                            case .dashboard:
                                DashboardView()
                                    .padding(ScriptexPadding.large)
                            case .scriptExecution:
                                ScriptExecutionView()
                                    .padding(ScriptexPadding.large)
                            case .appManager:
                                AppManagerView()
                                    .padding(ScriptexPadding.large)
                            case .fileManager:
                                FileManagerView()
                                    .padding(ScriptexPadding.large)
                            }
                        }
                    }
                }
                .frame(minWidth: max(500, geometry.size.width * 0.7))
            }
            .onAppear {
                // This small delay allows the UI to render before showing welcome animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        showWelcomeAnimation = false
                    }
                }
            }
            .overlay(
                Group {
                    if showWelcomeAnimation {
                        ZStack {
                            ScriptexColors.primary
                                .ignoresSafeArea()
                            
                            VStack(spacing: ScriptexPadding.large) {
                                Text("Scriptex")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 60))
                                    .foregroundColor(ScriptexColors.accent)
                            }
                        }
                        .transition(.opacity)
                    }
                }
            )
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}

// MARK: - SidebarView

struct SidebarView: View {
    @Binding var selectedSection: AppSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Sidebar Header
            VStack(alignment: .leading, spacing: ScriptexPadding.small) {
                Text("Scriptex")
                    .font(ScriptexFonts.title)
                    .foregroundColor(ScriptexColors.sidebarText)
                
                Text("Automation Tools")
                    .font(ScriptexFonts.caption)
                    .foregroundColor(ScriptexColors.sidebarText.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(ScriptexPadding.medium)
            
            Divider()
                .background(ScriptexColors.sidebarText.opacity(0.2))
                .padding(.horizontal, ScriptexPadding.small)
            
            // Navigation Items
            VStack(spacing: ScriptexPadding.small) {
                ForEach(AppSection.allCases) { section in
                    SidebarItem(
                        icon: section.icon,
                        title: section.rawValue,
                        isSelected: selectedSection == section,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedSection = section
                            }
                        }
                    )
                }
            }
            .padding(.vertical, ScriptexPadding.medium)
            
            Spacer()
            
            // Footer with version info
            HStack {
                Text("Version 1.0")
                    .font(ScriptexFonts.caption)
                    .foregroundColor(ScriptexColors.sidebarText.opacity(0.5))
                
                Spacer()
                
                Button(action: {
                    // Help action
                }) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(ScriptexColors.sidebarText.opacity(0.5))
                }
                .buttonStyle(IconButtonStyle())
            }
            .padding(ScriptexPadding.medium)
        }
        .background(ScriptexColors.sidebarBackground)
    }
}

struct SidebarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ScriptexPadding.medium) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .frame(width: 24)
                
                Text(title)
                    .font(ScriptexFonts.body)
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(ScriptexColors.secondary)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, ScriptexPadding.small)
            .padding(.horizontal, ScriptexPadding.medium)
            .background(
                RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                    .fill(isSelected ? ScriptexColors.sidebarHighlight : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(isSelected ? ScriptexColors.sidebarText : ScriptexColors.sidebarText.opacity(0.7))
        .padding(.horizontal, ScriptexPadding.small)
    }
}

// MARK: - ScriptExecutionView

struct ScriptExecutionView: View {
    @State private var scriptPath = ""
    @State private var scriptOutput = ""
    @State private var isDropTarget = false
    @State private var isExecuting = false
    @State private var showSuccessIndicator = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: ScriptexPadding.large) {
            // Input Section
            CardView {
                VStack(alignment: .leading, spacing: ScriptexPadding.medium) {
                    Text("Script File")
                        .font(ScriptexFonts.subtitle)
                        .foregroundColor(ScriptexColors.text)
                    
                    HStack(spacing: ScriptexPadding.medium) {
                        TextField("Enter script path or drop file here", text: $scriptPath)
                            .textFieldStyle(ScriptexTextFieldStyle())
                            .onDrop(of: [.fileURL], isTargeted: $isDropTarget) { providers in
                                providers.first?.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                                    guard
                                        let data,
                                        let path = URL(dataRepresentation: data, relativeTo: nil)
                                    else { return }
                                    
                                    withAnimation {
                                        scriptPath = path.path
                                    }
                                }
                                return true
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                                    .stroke(isDropTarget ? ScriptexColors.primary : Color.clear, lineWidth: 2)
                            )
                            .animation(.easeInOut(duration: 0.2), value: isDropTarget)
                        
                        Button(action: {
                            withAnimation {
                                isExecuting = true
                                executeScript()
                            }
                        }) {
                            if isExecuting {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    
                                    Text("Running...")
                                }
                            } else {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Execute")
                                }
                            }
                        }
                        .disabled(scriptPath.isEmpty || isExecuting)
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    
                    if showSuccessIndicator {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ScriptexColors.success)
                            
                            Text("Script executed successfully")
                                .font(ScriptexFonts.caption)
                                .foregroundColor(ScriptexColors.success)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showSuccessIndicator = false
                                }
                            }
                        }
                    }
                }
            }
            
            // Output Section
            CardView {
                VStack(alignment: .leading, spacing: ScriptexPadding.medium) {
                    HStack {
                        Text("Output")
                            .font(ScriptexFonts.subtitle)
                            .foregroundColor(ScriptexColors.text)
                        
                        Spacer()
                        
                        Button(action: {
                            scriptOutput = ""
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(ScriptexColors.textSecondary)
                        }
                        .buttonStyle(IconButtonStyle())
                        .opacity(scriptOutput.isEmpty ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: scriptOutput.isEmpty)
                    }
                    
                    if scriptOutput.isEmpty {
                        VStack(spacing: ScriptexPadding.small) {
                            Image(systemName: "terminal")
                                .font(.system(size: 32))
                                .foregroundColor(ScriptexColors.textSecondary.opacity(0.5))
                            
                            Text("Script output will appear here")
                                .font(ScriptexFonts.body)
                                .foregroundColor(ScriptexColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, ScriptexPadding.large)
                    } else {
                        ScrollView {
                            Text(scriptOutput)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(ScriptexColors.text)
                                .padding(ScriptexPadding.medium)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(ScriptexRadius.small)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(minHeight: 200, maxHeight: .infinity)
                    }
                }
            }
        }
    }
    
    private func executeScript() {
        guard !scriptPath.isEmpty else { return }

        isExecuting = true
        
        // Using completion handler instead of async/await for macOS 11 compatibility
        ExecutionService.executeScript(at: scriptPath) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let output):
                    withAnimation {
                        self.scriptOutput = output
                        self.isExecuting = false
                        self.showSuccessIndicator = true
                    }
                case .failure(let error):
                    withAnimation {
                        self.scriptOutput = "Error: \(error.localizedDescription)"
                        self.isExecuting = false
                    }
                }
            }
        }
    }
}
