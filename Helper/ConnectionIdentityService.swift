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

// MARK: - ConnectionIdentityService

enum ConnectionIdentityService {

    // MARK: Constants

    static private let requirementString =
        #"anchor apple generic and identifier "\#(HelperConstants.bundleID)" and certificate leaf[subject.OU] = "\#(HelperConstants.subject)""# as CFString
}

// MARK: - Check

extension ConnectionIdentityService {

    /// Check that the connection originates from the client app.
    ///
    /// - throws: If validation failed.
    static func checkConnectionIsValid(connection: NSXPCConnection) throws {
        let tokenData = try tokenData(in: connection)
        let secCode = try secCode(from: tokenData)
        try? logInfo(about: secCode)
        try verifySecCode(secCode: secCode)
    }
}

// MARK: - Token

extension ConnectionIdentityService {

    /// Get the property `auditToken` from a `NSXPCConnection`.
    ///
    /// - note: This is a hack, see [Woody's Findings](https://www.woodys-findings.com/posts/cocoa-implement-privileged-helper).
    private static func tokenData(in connection: NSXPCConnection) throws -> Data {
        let property = "auditToken"

        guard connection.responds(to: NSSelectorFromString(property)) else {
            throw ScriptexError.helperConnection("'NSXPCConnection' has no member '\(property)'")
        }
        guard let auditToken = connection.value(forKey: property) else {
            throw ScriptexError.helperConnection("'\(property)' from connection is 'nil'")
        }
        guard let auditTokenValue = auditToken as? NSValue else {
            throw ScriptexError.helperConnection("Unable to get 'NSValue' from '\(property)' in 'NSXPCConnection'")
        }
        guard var auditTokenOpaque = auditTokenValue.value(of: audit_token_t.self) else {
            throw ScriptexError.helperConnection("'\(property)' 'NSValue' is not of type 'audit_token_t'")
        }

        return Data(bytes: &auditTokenOpaque, count: MemoryLayout<audit_token_t>.size)
    }
}

// MARK: - SecCode

extension ConnectionIdentityService {

    private static func secCode(from token: Data) throws -> SecCode {
        let attributesDict = [kSecGuestAttributeAudit: token]

        var secCode: SecCode?
        try SecCodeCopyGuestWithAttributes(nil, attributesDict as CFDictionary, [], &secCode)
            .checkError("SecCodeCopyGuestWithAttributes")

        guard let secCode else {
            throw ScriptexError.helperConnection("Unable to get secCode from token using 'SecCodeCopyGuestWithAttributes'")
        }

        return secCode
    }

    private static func verifySecCode(secCode: SecCode) throws {
        var secRequirements: SecRequirement?

        try SecRequirementCreateWithString(requirementString, [], &secRequirements)
            .checkError("SecRequirementCreateWithString")
        try SecCodeCheckValidity(secCode, [], secRequirements)
            .checkError("SecCodeCheckValidity")
    }

    private static func logInfo(about secCode: SecCode) throws {
        var secStaticCode: SecStaticCode?
        var cfDictionary: CFDictionary?

        try SecCodeCopyStaticCode(secCode, [], &secStaticCode)
            .checkError("SecCodeCopyStaticCode")

        guard let secStaticCode else {
            throw ScriptexError.helperConnection("Unable to get a 'SecStaticCode' from 'SecCode'")
        }

        try SecCodeCopySigningInformation(secStaticCode, [], &cfDictionary)
            .checkError("SecCodeCopySigningInformation")

        guard 
            let dict = cfDictionary as NSDictionary?,
            let info = dict["info-plist"] as? NSDictionary
        else { return }

        let bundleID = info[kCFBundleIdentifierKey as String] as? NSString ?? "Unknown"
        NSLog("Received connection request from app with bundle ID '\(bundleID)'")
    }
}
