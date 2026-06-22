import Foundation
import CryptoKit

/// Lightweight OAuth 1.0 HMAC-SHA1 signer for FatSecret Platform API.
///
/// Stateless utility — no tokens stored, only consumer credentials.
/// Uses CryptoKit (iOS 13+) for HMAC-SHA1 — no external dependencies.
enum FatSecretOAuth {
    /// Sign a request with OAuth 1.0.
    /// - Returns: OAuth parameters including signature. Use in Authorization header.
    static func sign(
        httpMethod: String,
        baseURL: String,
        parameters: [String: String],
        consumerKey: String,
        consumerSecret: String
    ) -> [String: String] {
        var oauthParams: [String: String] = [
            "oauth_consumer_key": consumerKey,
            "oauth_signature_method": "HMAC-SHA1",
            "oauth_timestamp": String(Int(Date().timeIntervalSince1970)),
            "oauth_nonce": UUID().uuidString,
            "oauth_version": "1.0",
        ]

        // Merge all params for the signature base string (excluding oauth_signature itself)
        var allParams = parameters
        for (key, value) in oauthParams { allParams[key] = value }

        let signature = createSignature(
            httpMethod: httpMethod,
            baseURL: baseURL,
            parameters: allParams,
            consumerSecret: consumerSecret
        )

        oauthParams["oauth_signature"] = signature
        return oauthParams
    }

    // MARK: - Signature Computation

    private static func createSignature(
        httpMethod: String,
        baseURL: String,
        parameters: [String: String],
        consumerSecret: String
    ) -> String {
        // 1. Sort by key, build param string
        let sortedKeys = parameters.keys.sorted()
        let paramString = sortedKeys.compactMap { key -> String? in
            guard let value = parameters[key] else { return nil }
            return "\(key.oauthPercentEncoded)=\(value.oauthPercentEncoded)"
        }.joined(separator: "&")

        // 2. Signature base string
        let base = [
            httpMethod.uppercased(),
            baseURL.oauthPercentEncoded,
            paramString.oauthPercentEncoded,
        ].joined(separator: "&")

        // 3. Signing key
        let signingKey = SymmetricKey(data: Data("\(consumerSecret.oauthPercentEncoded)&".utf8))

        // 4. HMAC-SHA1 → Base64
        let hmac = HMAC<Insecure.SHA1>.authenticationCode(for: Data(base.utf8), using: signingKey)
        return Data(hmac).base64EncodedString()
    }
}

// MARK: - OAuth Percent Encoding (RFC 3986)

private extension String {
    var oauthPercentEncoded: String {
        let unreserved = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~"
        )
        return addingPercentEncoding(withAllowedCharacters: unreserved) ?? self
    }
}
