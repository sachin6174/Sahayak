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

struct FileManagerView: View {
    @State private var currentDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
    @State private var directoryContents: [URL] = []
    @State private var errorMessage: String?
    @State private var isLoading = true
    @State private var selectedViewMode: ViewMode = .list
    @State private var selectedFile: URL?
    @State private var showQuickLookPreview = false
    
    enum ViewMode {
        case list, grid
        
        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .grid: return "square.grid.2x2"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: ScriptexPadding.large) {
            // Navigation controls
            CardView {
                VStack(spacing: ScriptexPadding.medium) {
                    // Path navigation
                    HStack(spacing: ScriptexPadding.medium) {
                        Button(action: navigateUp) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        // Path breadcrumbs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 2) {
                                ForEach(pathComponents.indices, id: \.self) { index in
                                    let component = pathComponents[index]
                                    
                                    if index > 0 {
                                        Image(systemName: "chevron.right")
                                            .font(ScriptexFonts.caption)
                                            .foregroundColor(ScriptexColors.textSecondary)
                                    }
                                    
                                    Button(action: {
                                        navigateToComponent(at: index)
                                    }) {
                                        Text(component.isEmpty ? "/" : component)
                                            .font(ScriptexFonts.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .background(
                                        RoundedRectangle(cornerRadius: ScriptexRadius.small)
                                            .fill(index == pathComponents.count - 1 ? 
                                                  ScriptexColors.accent.opacity(0.3) : Color.clear)
                                    )
                                    .foregroundColor(index == pathComponents.count - 1 ? 
                                                     ScriptexColors.primary : ScriptexColors.textSecondary)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(ScriptexRadius.medium)
                        }
                        
                        Spacer()
                        
                        // View mode toggle
                        Button(action: {
                            withAnimation {
                                selectedViewMode = selectedViewMode == .list ? .grid : .list
                            }
                        }) {
                            Image(systemName: selectedViewMode.icon)
                                .foregroundColor(ScriptexColors.primary)
                        }
                        .buttonStyle(IconButtonStyle())
                        
                        // Refresh button
                        Button(action: refreshDirectory) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(ScriptexColors.primary)
                        }
                        .buttonStyle(IconButtonStyle())
                    }
                    
                    // Error message if any
                    if let errorMessage = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(ScriptexColors.warning)
                            
                            Text(errorMessage)
                                .font(ScriptexFonts.caption)
                                .foregroundColor(ScriptexColors.error)
                        }
                        .padding(ScriptexPadding.medium)
                        .background(ScriptexColors.error.opacity(0.1))
                        .cornerRadius(ScriptexRadius.medium)
                    }
                }
            }
            
            // File listing
            CardView {
                VStack(alignment: .leading, spacing: ScriptexPadding.medium) {
                    HStack {
                        Text("Contents")
                            .font(ScriptexFonts.subtitle)
                            .foregroundColor(ScriptexColors.text)
                        
                        Spacer()
                        
                        Text("\(directoryContents.count) items")
                            .font(ScriptexFonts.caption)
                            .foregroundColor(ScriptexColors.textSecondary)
                    }
                    
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                            Spacer()
                        }
                        .padding(.vertical, ScriptexPadding.large)
                    } else if directoryContents.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: ScriptexPadding.medium) {
                                Image(systemName: "folder")
                                    .font(.system(size: 48))
                                    .foregroundColor(ScriptexColors.textSecondary.opacity(0.5))
                                
                                Text("Empty Folder")
                                    .font(ScriptexFonts.body)
                                    .foregroundColor(ScriptexColors.textSecondary)
                            }
                            .padding(.vertical, ScriptexPadding.extraLarge)
                            Spacer()
                        }
                    } else {
                        if selectedViewMode == .list {
                            listView
                        } else {
                            gridView
                        }
                    }
                }
            }
        }
        .onAppear {
            loadDirectoryContents()
        }
        .sheet(isPresented: $showQuickLookPreview) {
            if let selectedFile = selectedFile {
                QuickLookPreview(url: selectedFile)
            }
        }
    }
    
    // List view of files
    private var listView: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(directoryContents, id: \.absoluteString) { url in
                    FileRowView(
                        url: url, 
                        isSelected: selectedFile?.absoluteString == url.absoluteString,
                        onSelect: { selectFile(url) },
                        onNavigate: { navigateTo(url) }
                    )
                    .padding(.vertical, 4)
                    
                    if url != directoryContents.last {
                        Divider()
                            .padding(.leading, 40)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    // Grid view of files
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: ScriptexPadding.medium) {
                ForEach(directoryContents, id: \.absoluteString) { url in
                    FileGridItemView(
                        url: url,
                        isSelected: selectedFile?.absoluteString == url.absoluteString,
                        onSelect: { selectFile(url) },
                        onNavigate: { navigateTo(url) }
                    )
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    // Path components for breadcrumb navigation
    private var pathComponents: [String] {
        var components = currentDirectory.pathComponents
        if components.first == "/" {
            components[0] = ""
        }
        return components
    }
    
    private func selectFile(_ url: URL) {
        if selectedFile?.absoluteString == url.absoluteString {
            // If already selected, try to preview
            if !url.hasDirectoryPath {
                selectedFile = url
                showQuickLookPreview = true
            }
        } else {
            // Just select
            selectedFile = url
        }
    }
    
    private func navigateToComponent(at index: Int) {
        let components = pathComponents
        if index < components.count - 1 {
            // Reconstruct path up to the selected component
            var path = "/"
            for i in 1...index {
                path = (path as NSString).appendingPathComponent(components[i])
            }
            currentDirectory = URL(fileURLWithPath: path)
            loadDirectoryContents()
        }
    }
    
    private func navigateTo(_ url: URL) {
        if url.hasDirectoryPath {
            withAnimation {
                currentDirectory = url
                loadDirectoryContents()
            }
        }
    }
    
    private func navigateUp() {
        if currentDirectory.pathComponents.count > 1 {
            withAnimation {
                currentDirectory = currentDirectory.deletingLastPathComponent()
                loadDirectoryContents()
            }
        }
    }
    
    private func refreshDirectory() {
        withAnimation {
            loadDirectoryContents()
        }
    }
    
    private func loadDirectoryContents() {
        withAnimation {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let contents = try FileManager.default.contentsOfDirectory(
                    at: currentDirectory,
                    includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey],
                    options: [.skipsHiddenFiles]
                )
                
                let sortedContents = contents.sorted { lhs, rhs in
                    let lhsIsDir = (try? lhs.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    let rhsIsDir = (try? rhs.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    
                    if lhsIsDir && !rhsIsDir {
                        return true
                    } else if !lhsIsDir && rhsIsDir {
                        return false
                    } else {
                        return lhs.lastPathComponent.localizedStandardCompare(rhs.lastPathComponent) == .orderedAscending
                    }
                }
                
                withAnimation {
                    directoryContents = sortedContents
                    isLoading = false
                }
            } catch {
                withAnimation {
                    errorMessage = "Error loading directory: \(error.localizedDescription)"
                    directoryContents = []
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - File Row View

struct FileRowView: View {
    let url: URL
    let isSelected: Bool
    let onSelect: () -> Void
    let onNavigate: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: ScriptexPadding.medium) {
            // File icon
            Image(systemName: url.hasDirectoryPath ? "folder.fill" : fileSystemIcon(for: url))
                .font(.system(size: 18))
                .foregroundColor(url.hasDirectoryPath ? ScriptexColors.primary : ScriptexColors.textSecondary)
                .frame(width: 24)
            
            // File name
            Text(url.lastPathComponent)
                .font(ScriptexFonts.body)
                .foregroundColor(ScriptexColors.text)
                .lineLimit(1)
            
            Spacer()
            
            // File details
            if !url.hasDirectoryPath {
                Text(fileSizeString(for: url))
                    .font(ScriptexFonts.caption)
                    .foregroundColor(ScriptexColors.textSecondary)
            }
            
            // Actions
            if isHovered || isSelected {
                HStack(spacing: ScriptexPadding.small) {
                    Button(action: {
                        // Preview action
                    }) {
                        Image(systemName: "eye")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(IconButtonStyle())
                    
                    if url.hasDirectoryPath {
                        Button(action: onNavigate) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(IconButtonStyle())
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(ScriptexPadding.small)
        .background(
            RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                .fill(isSelected ? ScriptexColors.accent.opacity(0.2) : 
                       (isHovered ? ScriptexColors.accent.opacity(0.1) : Color.clear))
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                onSelect()
            }
        }
        .onTapGesture(count: 2) {
            onNavigate()
        }
    }
    
    private func fileSystemIcon(for url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif":
            return "photo.fill"
        case "mp3", "wav", "m4a":
            return "music.note"
        case "mp4", "mov", "avi":
            return "film.fill"
        case "swift", "java", "py", "js", "html", "css":
            return "doc.plaintext.fill"
        case "zip", "rar", "tar", "gz":
            return "archivebox.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func fileSizeString(for url: URL) -> String {
        do {
            let resources = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resources.fileSize {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useKB, .useMB, .useGB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: Int64(fileSize))
            }
        } catch {
            // Silently fail
        }
        return ""
    }
}

// MARK: - File Grid Item View

struct FileGridItemView: View {
    let url: URL
    let isSelected: Bool
    let onSelect: () -> Void
    let onNavigate: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: ScriptexPadding.small) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                    .fill(url.hasDirectoryPath ? 
                          ScriptexColors.primary.opacity(0.2) : 
                          ScriptexColors.accent.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: url.hasDirectoryPath ? "folder.fill" : fileSystemIcon(for: url))
                    .font(.system(size: 30))
                    .foregroundColor(url.hasDirectoryPath ? 
                                     ScriptexColors.primary : 
                                     ScriptexColors.textSecondary)
            }
            
            // Filename
            Text(url.lastPathComponent)
                .font(ScriptexFonts.caption)
                .foregroundColor(ScriptexColors.text)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 36)
            
            // Size (only for files)
            if !url.hasDirectoryPath {
                Text(fileSizeString(for: url))
                    .font(ScriptexFonts.caption)
                    .foregroundColor(ScriptexColors.textSecondary)
            }
        }
        .padding(ScriptexPadding.small)
        .frame(width: 120, height: 140)
        .background(
            RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                .fill(isSelected ? ScriptexColors.accent.opacity(0.2) : 
                       (isHovered ? ScriptexColors.accent.opacity(0.1) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: ScriptexRadius.medium)
                .stroke(isSelected ? ScriptexColors.primary.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                onSelect()
            }
        }
        .onTapGesture(count: 2) {
            onNavigate()
        }
    }
    
    private func fileSystemIcon(for url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return "doc.fill"
        case "jpg", "jpeg", "png", "gif":
            return "photo.fill"
        case "mp3", "wav", "m4a":
            return "music.note"
        case "mp4", "mov", "avi":
            return "film.fill"
        case "swift", "java", "py", "js", "html", "css":
            return "doc.plaintext.fill"
        case "zip", "rar", "tar", "gz":
            return "archivebox.fill"
        default:
            return "doc.fill"
        }
    }
    
    private func fileSizeString(for url: URL) -> String {
        do {
            let resources = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resources.fileSize {
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useKB, .useMB, .useGB]
                formatter.countStyle = .file
                return formatter.string(fromByteCount: Int64(fileSize))
            }
        } catch {
            // Silently fail
        }
        return ""
    }
}

// MARK: - QuickLook Preview

struct QuickLookPreview: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // In a real implementation, you would use QLPreviewPanel to show previews
        // but that's beyond the scope of this example
    }
}
