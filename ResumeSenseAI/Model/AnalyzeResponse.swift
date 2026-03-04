//
//  AnalyzeResponse.swift
//  ResumeSenseAI
//
//  Created by Muneeb Zain on 04/03/2026.
//

import Foundation

struct AnalyzeResponse: Decodable {
    let keyword_score: Double?
    let semantic_score: Double?
    let final_score: Double?

    let score: Double?
    let matched_keywords: [String]?
    let missing_keywords: [String]?

    let suggestions: [String]?
    let extraction_method: String?
    let resume_text_chars: Int?
    let resume_sections_found: [String]?
    
    let semantic_matches: [SemanticMatch]?
}

struct SemanticMatch: Decodable, Identifiable {
    let id: String
    let jd_requirement: String
    let matched_resume_text: String?
    let similarity: Double?
}
