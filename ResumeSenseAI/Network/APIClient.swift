//
//  APIClient.swift
//  ResumeSenseAI
//
//  Created by Muneeb Zain on 04/03/2026.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case http(Int, String)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL."
        case .invalidResponse:
            return "Invalid server response."
        case .http(let code, let msg):
            return "Server error (\(code)): \(msg)"
        case .decoding(let msg):
            return "Failed to decode response: \(msg)"
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    /// IMPORTANT:
    /// - If you run backend on your Mac and test on iPhone, use Mac LAN IP, e.g. http://192.168.1.20:8000
    var baseURL: String = "http://127.0.0.1:8000"

    private init() {}

    func analyze(pdfData: Data, filename: String, jobDescription: String) async throws -> AnalyzeResponse {
        try await uploadMultipart(
            endpoint: "/api/analyze",
            pdfData: pdfData,
            filename: filename,
            jobDescription: jobDescription,
            responseType: AnalyzeResponse.self
        )
    }

    func rewrite(pdfData: Data, filename: String, jobDescription: String) async throws -> RewriteResponse {
        try await uploadMultipart(
            endpoint: "/api/rewrite",
            pdfData: pdfData,
            filename: filename,
            jobDescription: jobDescription,
            responseType: RewriteResponse.self
        )
    }

    private func uploadMultipart<T: Decodable>(
        endpoint: String,
        pdfData: Data,
        filename: String,
        jobDescription: String,
        responseType: T.Type
    ) async throws -> T {
        let cleanedBase = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: cleanedBase + endpoint) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // job_description
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"job_description\"\r\n\r\n")
        body.appendString(jobDescription)
        body.appendString("\r\n")

        // resume file
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"resume\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: application/pdf\r\n\r\n")
        body.append(pdfData)
        body.appendString("\r\n")

        body.appendString("--\(boundary)--\r\n")
        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        if !(200...299).contains(http.statusCode) {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.http(http.statusCode, msg)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? ""
            throw APIError.decoding("\(error.localizedDescription)\nRaw: \(raw)")
        }
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
