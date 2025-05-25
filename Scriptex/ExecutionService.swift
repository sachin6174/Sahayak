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

import Foundation

// MARK: - ExecutionService

/// Execute a script.
enum ExecutionService {

    // MARK: Constants

    static let programURL = URL(fileURLWithPath: "/usr/bin/env")

    // MARK: Execute
    
    /// Execute the script at the provided URL with completion handler for macOS 11 compatibility
    static func executeScript(at path: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let helper = try getHelperRemote()
                // Fix: Explicitly use withReply parameter name to match @objc protocol
                helper.executeScript(at: path, withReply: { output, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let output = output {
                        completion(.success(output))
                    } else {
                        completion(.failure(ScriptexError.unknown))
                    }
                })
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // For macOS 12+ compatibility we'll keep the async version too
    @available(macOS 12.0, *)
    static func executeScript(at path: String) async throws -> String {
        try await HelperRemoteProvider.remote().executeScript(at: path)
    }
    
    // Helper method to get remote without async/await
    private static func getHelperRemote() throws -> HelperProtocol {
        // This is a simplified implementation - in a real app you'd need a proper non-async implementation
        // of HelperRemoteProvider.remote()
        let connection = NSXPCConnection(machServiceName: HelperConstants.domain, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection.resume()
        
        guard let helper = connection.remoteObjectProxy as? HelperProtocol else {
            throw ScriptexError.helperConnection("Unable to get a valid helper connection")
        }
        
        return helper
    }
}
