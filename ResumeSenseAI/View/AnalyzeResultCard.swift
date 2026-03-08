//
//  AnalyzeResultCard.swift
//  ResumeSenseAI
//
//  Created by Muneeb Zain on 08/03/2026.
//

import SwiftUI

struct AnalyzeResultCard: View {
    let res: AnalyzeResponse

    var body: some View {
        Card(title: "Analysis", subtitle: subtitleLine) {
            VStack(alignment: .leading, spacing: 12) {

                HStack(spacing: 12) {
                    let keyword = res.keyword_score ?? res.score
                    let semantic = res.semantic_score
                    let computedFinal = computeFinalScore(keyword: keyword, semantic: semantic)

                    ScorePill(title: "Keyword", value: keyword)
                    ScorePill(title: "Semantic", value: semantic)
                    ScorePill(title: "Final", value: res.final_score ?? computedFinal, emphasize: true)
                }

                if let matched = res.matched_keywords, !matched.isEmpty {
                    SectionHeader("Matched keywords")
                    ChipFlow(items: matched)
                }

                if let missing = res.missing_keywords, !missing.isEmpty {
                    SectionHeader("Missing keywords")
                    ChipFlow(items: missing)
                }

                if let suggestions = res.suggestions, !suggestions.isEmpty {
                    SectionHeader("Suggestions")
                    BulletList(items: suggestions)
                }

                if let matches = res.semantic_matches, !matches.isEmpty {
                    SectionHeader("Top semantic matches")
                    VStack(spacing: 10) {
                        ForEach(matches.prefix(4)) { m in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(m.jd_requirement)
                                    .font(.callout.weight(.semibold))

                                if let t = m.matched_resume_text {
                                    Text(t)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(3)
                                }

                                if let sim = m.similarity {
                                    Text("Similarity: \(String(format: "%.3f", sim))")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(12)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
            }
        }
    }

    private var subtitleLine: String {
        var parts: [String] = []
        if let method = res.extraction_method { parts.append("Extraction: \(method)") }
        if let chars = res.resume_text_chars { parts.append("Text: \(chars) chars") }
        return parts.isEmpty ? "V1 + V2 results" : parts.joined(separator: " • ")
    }
    
    private func computeFinalScore(keyword: Double?, semantic: Double?) -> Double? {
        guard let keyword, let semantic else { return nil }
        return (0.4 * keyword) + (0.6 * semantic)
    }
}


