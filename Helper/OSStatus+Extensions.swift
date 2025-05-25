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

// MARK: - Check error

extension OSStatus {

    /// If the status is not a success, get the error out of it and throw it.
    func checkError(_ functionName: String) throws {
        if self == errSecSuccess { return }
        throw SecurityError(status: self, functionName: functionName)
    }
}

// MARK: - SecError

extension OSStatus {

    /// An error that might be thrown by the
    /// [Security Framework](https://developer.apple.com/documentation/security/1542001-security_framework_result_codes)
    struct SecurityError: Error {

        // MARK: Properties

        let localizedDescription: String

        // MARK: Init

        init(status: OSStatus, functionName: String) {
            let statusMessage = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown sec error"
            localizedDescription = "[\(functionName)] \(statusMessage)"
        }
    }
}
