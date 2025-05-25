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
import Network
import SystemConfiguration

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        VStack(spacing: ScriptexPadding.large) {
            // Time Information
            CardView {
                HStack(alignment: .top, spacing: ScriptexPadding.large) {
                    // Local Time Card
                    timeCard(
                        title: "Local Time",
                        time: viewModel.currentTime,
                        icon: "clock.fill",
                        color: ScriptexColors.primary
                    )
                    
                    // UTC Time Card
                    timeCard(
                        title: "UTC Time",
                        time: viewModel.utcTime,
                        icon: "globe.americas.fill",
                        color: ScriptexColors.secondary
                    )
                    
                    // Uptime Card
                    timeCard(
                        title: "System Uptime",
                        time: viewModel.systemUptime,
                        icon: "timer",
                        color: ScriptexColors.success
                    )
                }
                .frame(maxWidth: .infinity)
            }
            
            // Network Information
            CardView {
                VStack(alignment: .leading, spacing: ScriptexPadding.medium) {
                    HStack {
                        Image(systemName: "network")
                            .font(.system(size: 18))
                            .foregroundColor(ScriptexColors.primary)
                        
                        Text("Network Information")
                            .font(ScriptexFonts.subtitle)
                            .foregroundColor(ScriptexColors.text)
                        
                        Spacer()
                        
                        Button(action: viewModel.refreshNetworkInfo) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(ScriptexColors.primary)
                        }
                        .buttonStyle(IconButtonStyle())
                    }
                    
                    Divider()
                    
                    // Public IP
                    HStack(spacing: ScriptexPadding.medium) {
                        Text("Public IP:")
                            .font(ScriptexFonts.body.bold())
                            .foregroundColor(ScriptexColors.text)
                            .frame(width: 120, alignment: .leading)
                        
                        if viewModel.isLoadingPublicIP {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.7)
                        } else {
                            Text(viewModel.publicIP)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(ScriptexColors.text)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.copyToClipboard(viewModel.publicIP)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(ScriptexColors.primary)
                        }
                        .buttonStyle(IconButtonStyle())
                        .opacity(viewModel.publicIP.isEmpty || viewModel.isLoadingPublicIP ? 0.3 : 1)
                        .disabled(viewModel.publicIP.isEmpty || viewModel.isLoadingPublicIP)
                    }
                    .padding(.vertical, 4)
                    
                    // Local IPs
                    VStack(alignment: .leading, spacing: ScriptexPadding.small) {
                        Text("Local IPs:")
                            .font(ScriptexFonts.body.bold())
                            .foregroundColor(ScriptexColors.text)
                        
                        ForEach(viewModel.localIPs, id: \.self) { ip in
                            HStack {
                                Text(ip)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(ScriptexColors.text)
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.copyToClipboard(ip)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(ScriptexColors.primary)
                                }
                                .buttonStyle(IconButtonStyle())
                            }
                            .padding(.leading, ScriptexPadding.medium)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Network Speed
                    HStack(spacing: ScriptexPadding.medium) {
                        Text("Network Speed:")
                            .font(ScriptexFonts.body.bold())
                            .foregroundColor(ScriptexColors.text)
                            .frame(width: 120, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Image(systemName: "arrow.down")
                                    .foregroundColor(ScriptexColors.success)
                                
                                Text("Download: \(viewModel.downloadSpeed)")
                                    .font(ScriptexFonts.body)
                                    .foregroundColor(ScriptexColors.text)
                            }
                            
                            HStack {
                                Image(systemName: "arrow.up")
                                    .foregroundColor(ScriptexColors.secondary)
                                
                                Text("Upload: \(viewModel.uploadSpeed)")
                                    .font(ScriptexFonts.body)
                                    .foregroundColor(ScriptexColors.text)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Storage Information
            CardView {
                VStack(alignment: .leading, spacing: ScriptexPadding.medium) {
                    HStack {
                        Image(systemName: "externaldrive.fill")
                            .font(.system(size: 18))
                            .foregroundColor(ScriptexColors.primary)
                        
                        Text("Storage Information")
                            .font(ScriptexFonts.subtitle)
                            .foregroundColor(ScriptexColors.text)
                        
                        Spacer()
                        
                        Button(action: viewModel.refreshStorageInfo) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(ScriptexColors.primary)
                        }
                        .buttonStyle(IconButtonStyle())
                    }
                    
                    Divider()
                    
                    VStack(spacing: ScriptexPadding.medium) {
                        ForEach(viewModel.volumes, id: \.path) { volume in
                            VStack(alignment: .leading, spacing: ScriptexPadding.small) {
                                HStack {
                                    Image(systemName: volume.isRemovable ? "externaldrive.fill" : "internaldrive.fill")
                                        .foregroundColor(ScriptexColors.primary)
                                    
                                    Text(volume.name)
                                        .font(ScriptexFonts.body.bold())
                                        .foregroundColor(ScriptexColors.text)
                                    
                                    Spacer()
                                    
                                    Text("\(volume.availableSpace) free of \(volume.totalSpace)")
                                        .font(ScriptexFonts.caption)
                                        .foregroundColor(ScriptexColors.textSecondary)
                                }
                                
                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: ScriptexRadius.small)
                                            .fill(ScriptexColors.accent.opacity(0.3))
                                            .frame(height: 8)
                                        
                                        RoundedRectangle(cornerRadius: ScriptexRadius.small)
                                            .fill(usageColor(for: volume.usagePercentage))
                                            .frame(width: max(0, min(geometry.size.width * volume.usagePercentage / 100, geometry.size.width)), height: 8)
                                    }
                                }
                                .frame(height: 8)
                                
                                Text("\(Int(volume.usagePercentage))% used")
                                    .font(ScriptexFonts.caption)
                                    .foregroundColor(ScriptexColors.textSecondary)
                            }
                            .padding(.vertical, 4)
                            
                            if volume != viewModel.volumes.last {
                                Divider()
                            }
                        }
                    }
                }
            }
            
            // System Information
            CardView {
                VStack(alignment: .leading, spacing: ScriptexPadding.medium) {
                    HStack {
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 18))
                            .foregroundColor(ScriptexColors.primary)
                        
                        Text("System Information")
                            .font(ScriptexFonts.subtitle)
                            .foregroundColor(ScriptexColors.text)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: ScriptexPadding.small) {
                            infoRow(label: "Computer Name", value: viewModel.computerName)
                            infoRow(label: "macOS Version", value: viewModel.osVersion)
                            infoRow(label: "CPU", value: viewModel.cpuInfo)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: ScriptexPadding.small) {
                            infoRow(label: "Memory", value: viewModel.memoryInfo)
                            infoRow(label: "Graphics", value: viewModel.graphicsInfo)
                            infoRow(label: "Serial Number", value: viewModel.serialNumber)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.startUpdatingTime()
            viewModel.fetchSystemInformation()
        }
        .onDisappear {
            viewModel.stopUpdatingTime()
        }
    }
    
    // Helper function to create a time card
    private func timeCard(title: String, time: String, icon: String, color: Color) -> some View {
        VStack(alignment: .center, spacing: ScriptexPadding.small) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                
                Text(title)
                    .font(ScriptexFonts.body.bold())
                    .foregroundColor(ScriptexColors.text)
            }
            
            Text(time)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(ScriptexColors.text)
                .padding(.vertical, ScriptexPadding.small)
        }
        .frame(maxWidth: .infinity)
        .padding(ScriptexPadding.medium)
        .background(color.opacity(0.1))
        .cornerRadius(ScriptexRadius.medium)
    }
    
    // Helper function to create info rows
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: ScriptexPadding.medium) {
            Text(label + ":")
                .font(ScriptexFonts.body.bold())
                .foregroundColor(ScriptexColors.text)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(ScriptexFonts.body)
                .foregroundColor(ScriptexColors.text)
        }
        .padding(.vertical, 2)
    }
    
    // Helper function to determine color based on usage percentage
    private func usageColor(for percentage: Double) -> Color {
        if percentage < 70 {
            return ScriptexColors.success
        } else if percentage < 90 {
            return ScriptexColors.warning
        } else {
            return ScriptexColors.error
        }
    }
}

// MARK: - Dashboard ViewModel
class DashboardViewModel: ObservableObject {
    // Time properties
    @Published var currentTime = ""
    @Published var utcTime = ""
    @Published var systemUptime = ""
    
    // Network properties
    @Published var publicIP = ""
    @Published var localIPs: [String] = []
    @Published var downloadSpeed = "0 KB/s"
    @Published var uploadSpeed = "0 KB/s"
    @Published var isLoadingPublicIP = false
    
    // Storage properties
    @Published var volumes: [VolumeInfo] = []
    
    // System properties
    @Published var computerName = ""
    @Published var osVersion = ""
    @Published var cpuInfo = ""
    @Published var memoryInfo = ""
    @Published var graphicsInfo = ""
    @Published var serialNumber = ""
    
    private var timer: Timer?
    
    // Initialize and start updating time
    func startUpdatingTime() {
        updateTime()
        
        // Update every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    func stopUpdatingTime() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTime() {
        let dateFormatter = DateFormatter()
        let now = Date()
        
        // Local time
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        currentTime = dateFormatter.string(from: now)
        
        // UTC time
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        utcTime = dateFormatter.string(from: now)
        
        // System uptime
        let uptime = ProcessInfo.processInfo.systemUptime
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        let seconds = Int(uptime) % 60
        systemUptime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Fetch network information
    func refreshNetworkInfo() {
        fetchLocalIPs()
        fetchPublicIP()
        simulateNetworkSpeed() // In a real app, you would measure actual network speed
    }
    
    private func fetchLocalIPs() {
        // This is a simplified implementation to get local IPs
        // A real implementation would use Network framework or ifaddrs
        var addresses = [String]()
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            localIPs = ["Unable to fetch IP addresses"]
            return
        }
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: (interface?.ifa_name)!)
                if name == "en0" || name == "en1" || name == "en2" || name == "en3" || name == "en4" || name == "en5" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), 
                                &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                    addresses.append(String(cString: hostname))
                }
            }
        }
        
        freeifaddrs(ifaddr)
        
        DispatchQueue.main.async {
            self.localIPs = addresses.isEmpty ? ["No IP addresses found"] : addresses
        }
    }
    
    private func fetchPublicIP() {
        isLoadingPublicIP = true
        
        guard let url = URL(string: "https://api.ipify.org") else {
            publicIP = "Unable to determine"
            isLoadingPublicIP = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingPublicIP = false
                
                if let data = data, let ipString = String(data: data, encoding: .utf8) {
                    self?.publicIP = ipString
                } else {
                    self?.publicIP = "Unable to determine"
                }
            }
        }.resume()
    }
    
    private func simulateNetworkSpeed() {
        // In a real implementation, you would measure actual network throughput
        // This is just a simulation for demonstration purposes
        let downloadKBps = Int.random(in: 1000...10000)
        let uploadKBps = Int.random(in: 500...2000)
        
        if downloadKBps > 1000 {
            downloadSpeed = String(format: "%.1f MB/s", Double(downloadKBps) / 1000.0)
        } else {
            downloadSpeed = "\(downloadKBps) KB/s"
        }
        
        if uploadKBps > 1000 {
            uploadSpeed = String(format: "%.1f MB/s", Double(uploadKBps) / 1000.0)
        } else {
            uploadSpeed = "\(uploadKBps) KB/s"
        }
    }
    
    // Fetch storage information
    func refreshStorageInfo() {
        let fileManager = FileManager.default
        
        // Get the main volume first
        if let volumeURL = fileManager.urls(for: .applicationDirectory, in: .localDomainMask).first {
            let mainVolumePath = volumeURL.deletingLastPathComponent().path
            
            do {
                let attributes = try fileManager.attributesOfFileSystem(forPath: mainVolumePath)
                
                if let totalSize = attributes[.systemSize] as? NSNumber,
                   let freeSize = attributes[.systemFreeSize] as? NSNumber {
                    
                    let totalSizeBytes = totalSize.int64Value
                    let freeSizeBytes = freeSize.int64Value
                    let usedSizeBytes = totalSizeBytes - freeSizeBytes
                    
                    let volume = VolumeInfo(
                        name: "Macintosh HD",
                        path: mainVolumePath,
                        totalSpace: formatBytes(totalSizeBytes),
                        availableSpace: formatBytes(freeSizeBytes),
                        usagePercentage: Double(usedSizeBytes) / Double(totalSizeBytes) * 100,
                        isRemovable: false
                    )
                    
                    // Add any external volumes (this is simplified)
                    let allVolumes = [volume]
                    
                    // In a real implementation, you'd enumerate all mounted volumes
                    
                    DispatchQueue.main.async {
                        self.volumes = allVolumes
                    }
                }
            } catch {
                print("Error getting storage info: \(error.localizedDescription)")
            }
        }
    }
    
    // Format bytes to human-readable string
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    // Fetch system information
    func fetchSystemInformation() {
        // Computer name
        computerName = Host.current().localizedName ?? "Unknown"
        
        // OS Version
        let os = ProcessInfo.processInfo.operatingSystemVersion
        osVersion = "macOS \(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        
        // These values would normally be obtained from IOKit or system_profiler
        // For demo purposes, we'll use placeholder values
        cpuInfo = "Apple M1 Pro (8-core)"
        memoryInfo = "16 GB"
        graphicsInfo = "Apple M1 Pro GPU"
        serialNumber = "C02XL0GUJGH6"
    }
    
    // Copy text to clipboard
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

// Model for volume information
struct VolumeInfo: Equatable {
    let name: String
    let path: String
    let totalSpace: String
    let availableSpace: String
    let usagePercentage: Double
    let isRemovable: Bool
}
