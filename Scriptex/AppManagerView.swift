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

struct AppManagerView: View {
    @State private var installedApps: [AppInfo] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var selectedCategory: AppCategory = .all
    
    enum AppCategory: String, CaseIterable, Identifiable {
        case all = "All"
        case productivity = "Productivity"
        case development = "Development"
        case utilities = "Utilities"
        case entertainment = "Entertainment"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: ScriptexPadding.large) {
            // Search and filter section
            CardView {
                VStack(spacing: ScriptexPadding.medium) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(ScriptexColors.textSecondary)
                        
                        TextField("Search applications", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                withAnimation {
                                    searchText = ""
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(ScriptexColors.textSecondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(ScriptexPadding.medium)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(ScriptexRadius.medium)
                    
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: ScriptexPadding.small) {
                            ForEach(AppCategory.allCases) { category in
                                Button(action: {
                                    withAnimation {
                                        selectedCategory = category
                                    }
                                }) {
                                    Text(category.rawValue)
                                        .padding(.horizontal, ScriptexPadding.medium)
                                        .padding(.vertical, ScriptexPadding.small)
                                        .background(
                                            RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                                                .fill(selectedCategory == category ? 
                                                      ScriptexColors.primary : 
                                                      ScriptexColors.accent.opacity(0.3))
                                        )
                                        .foregroundColor(selectedCategory == category ? 
                                                         .white : 
                                                         ScriptexColors.primary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            
            // Applications list
            CardView {
                VStack(alignment: .leading, spacing: ScriptexPadding.medium) {
                    HStack {
                        Text("Installed Applications")
                            .font(ScriptexFonts.subtitle)
                            .foregroundColor(ScriptexColors.text)
                        
                        Spacer()
                        
                        Text("\(filteredApps.count) apps")
                            .font(ScriptexFonts.caption)
                            .foregroundColor(ScriptexColors.textSecondary)
                        
                        Button(action: {
                            withAnimation {
                                isLoading = true
                                loadInstalledApps()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(ScriptexColors.primary)
                        }
                        .buttonStyle(IconButtonStyle())
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            VStack(spacing: ScriptexPadding.medium) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(1.5)
                                
                                Text("Loading applications...")
                                    .font(ScriptexFonts.body)
                                    .foregroundColor(ScriptexColors.textSecondary)
                            }
                            .padding(.vertical, ScriptexPadding.extraLarge)
                            Spacer()
                        }
                    } else if filteredApps.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: ScriptexPadding.medium) {
                                Image(systemName: "app.dashed")
                                    .font(.system(size: 48))
                                    .foregroundColor(ScriptexColors.textSecondary.opacity(0.5))
                                
                                Text("No applications found")
                                    .font(ScriptexFonts.body)
                                    .foregroundColor(ScriptexColors.textSecondary)
                                
                                if !searchText.isEmpty {
                                    Text("Try different search terms")
                                        .font(ScriptexFonts.caption)
                                        .foregroundColor(ScriptexColors.textSecondary)
                                }
                            }
                            .padding(.vertical, ScriptexPadding.extraLarge)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: ScriptexPadding.medium) {
                                ForEach(filteredApps) { app in
                                    AppItemView(app: app)
                                        .transition(.opacity)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadInstalledApps()
        }
    }
    
    private var filteredApps: [AppInfo] {
        var apps = installedApps
        
        if selectedCategory != .all {
            // In a real app, filter by actual category
            // This is just a simulation
            apps = apps.filter { $0.category == selectedCategory.rawValue }
        }
        
        if !searchText.isEmpty {
            apps = apps.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.bundleIdentifier.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return apps
    }
    
    private func loadInstalledApps() {
        // Simulate loading with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // This is a placeholder. In a real implementation, you would use NSWorkspace
            // to get the list of installed applications.
            let applications = [
                AppInfo(name: "Safari", bundleIdentifier: "com.apple.Safari", iconPath: "", category: "Productivity", version: "16.0"),
                AppInfo(name: "Mail", bundleIdentifier: "com.apple.Mail", iconPath: "", category: "Productivity", version: "16.0"),
                AppInfo(name: "Calendar", bundleIdentifier: "com.apple.Calendar", iconPath: "", category: "Productivity", version: "16.0"),
                AppInfo(name: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", iconPath: "", category: "Development", version: "14.2"),
                AppInfo(name: "Terminal", bundleIdentifier: "com.apple.Terminal", iconPath: "", category: "Utilities", version: "2.12"),
                AppInfo(name: "App Store", bundleIdentifier: "com.apple.AppStore", iconPath: "", category: "Utilities", version: "3.0"),
                AppInfo(name: "Music", bundleIdentifier: "com.apple.Music", iconPath: "", category: "Entertainment", version: "1.2"),
                AppInfo(name: "TV", bundleIdentifier: "com.apple.TV", iconPath: "", category: "Entertainment", version: "1.2")
            ]
            
            withAnimation {
                installedApps = applications
                isLoading = false
            }
        }
    }
}

struct AppItemView: View {
    let app: AppInfo
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: ScriptexPadding.medium) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: ScriptexRadius.small)
                    .fill(ScriptexColors.accent.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                if let image = NSImage(contentsOfFile: app.iconPath) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "app.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ScriptexColors.primary)
                }
            }
            
            // App details
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(ScriptexFonts.body.bold())
                    .foregroundColor(ScriptexColors.text)
                
                Text(app.bundleIdentifier)
                    .font(ScriptexFonts.caption)
                    .foregroundColor(ScriptexColors.textSecondary)
                
                HStack {
                    Text(app.category)
                        .font(ScriptexFonts.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(ScriptexColors.accent.opacity(0.3))
                        .foregroundColor(ScriptexColors.primary)
                        .cornerRadius(ScriptexRadius.small)
                    
                    Text("v\(app.version)")
                        .font(ScriptexFonts.caption)
                        .foregroundColor(ScriptexColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack {
                Button(action: {
                    // Info action
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(ScriptexColors.primary)
                }
                .buttonStyle(IconButtonStyle())
                
                Button(action: {
                    // Open action
                }) {
                    Text("Open")
                        .font(ScriptexFonts.caption.bold())
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .opacity(isHovered ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .padding(ScriptexPadding.medium)
        .background(
            RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                .fill(isHovered ? ScriptexColors.accent.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                .stroke(ScriptexColors.accent.opacity(0.3), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
    }
}

// Update the AppInfo model to include more details
struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let iconPath: String
    let category: String
    let version: String
}
