//
//  RewriteResponse.swift
//  ResumeSenseAI
//
//  Created by Muneeb Zain on 04/03/2026.
//

import Foundation

struct RewriteResponse: Decodable {
    let extraction_method: String?
    let keyword_score: Double?
    let missing_keywords: [String]?
    let rewrite: RewritePayload
}

struct RewritePayload: Decodable {
    let tailored_summary: String
    let skills_section: [String]
    let rewritten_bullets: [String]
    let gap_notes: [String]
}
