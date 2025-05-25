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

// MARK: - ContentView

struct ContentView: View {

    @State private var scriptPath = ""
    @State private var scriptOutput = ""
    @State private var isDropTarget = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("/script/path", text: $scriptPath)
                    .onDrop(of: [.fileURL], isTargeted: $isDropTarget) { providers in
                        providers.first?.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                            guard
                                let data,
                                let path = URL(dataRepresentation: data, relativeTo: nil)
                            else { return }
                            scriptPath = path.path
                        }
                        return true
                    }
                Button("Execute") {
                    executeScript()
                }
            }
            Text("Output:")
            TextEditor(text: $scriptOutput)
        }
        .padding()
    }
}

// MARK: - Execute

extension ContentView {

    @MainActor
    private func executeScript() {
        guard !scriptPath.isEmpty else { return }

        Task {
            do {
                let result = try await ExecutionService.executeScript(at: scriptPath)
                scriptOutput = result
            } catch {
                scriptOutput = error.localizedDescription
            }
        }
    }
}
