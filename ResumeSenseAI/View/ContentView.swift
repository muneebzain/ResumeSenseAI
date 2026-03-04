//
//  ContentView.swift
//  ResumeSenseAI
//
//  Created by Muneeb Zain on 04/03/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ResumeMatcherVM()
    @State private var showPicker = false
    @State private var didRunOnce = false

    @State private var mode: Mode = .analyze

    enum Mode: String, CaseIterable, Identifiable {
        case analyze = "Analyze"
        case rewrite = "Rewrite"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 14) {
                        header

                        Picker("", selection: $mode) {
                            ForEach(Mode.allCases) { m in
                                Text(m.rawValue).tag(m)
                            }
                        }
                        .pickerStyle(.segmented)

                        serverCard
                        resumeCard
                        jdCard

                        actionButtons(proxy: proxy)

                        if let err = vm.errorText {
                            ErrorBanner(text: err)
                        }

                        if didRunOnce {
                            resultsSection
                                .id("results")
                        }

                        Spacer(minLength: 18)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                .overlay {
                    if vm.isLoading {
                        LoadingOverlay(title: mode == .analyze ? "Analyzing..." : "Generating rewrite...")
                    }
                }
                // ✅ Simplified onChange to avoid type-check explosion
                .onChange(of: vm.analyzeResult != nil) { _ in
                    if vm.analyzeResult != nil {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            proxy.scrollTo("results", anchor: .top)
                        }
                    }
                }
                .onChange(of: vm.rewriteResult != nil) { _ in
                    if vm.rewriteResult != nil {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            proxy.scrollTo("results", anchor: .top)
                        }
                    }
                }
                .sheet(isPresented: $showPicker) {
                    PDFPicker { data, filename in
                        vm.setPDF(data: data, filename: filename)
                        showPicker = false
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.black.opacity(0.08))
                        .frame(width: 44, height: 44)
                    Text("RS")
                        .font(.headline)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("ResumeSenseAI")
                        .font(.title2.weight(.semibold))
                    Text("OCR + Embeddings + Local LLM")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Divider().opacity(0.5)
        }
    }

    // MARK: Cards

    private var serverCard: some View {
        Card(
            title: "Backend URL",
            subtitle: "Use your Mac LAN IP when testing on a real iPhone"
        ) {
            TextField("http://192.168.x.x:8000", text: Binding(
                get: { APIClient.shared.baseURL },
                set: { APIClient.shared.baseURL = $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            ))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.callout)
            .padding(12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var resumeCard: some View {
        Card(title: "Resume PDF", subtitle: "Select a PDF from Files") {
            HStack(spacing: 10) {
                Image(systemName: "doc.fill")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.pdfData == nil ? "No file selected" : vm.pdfFilename)
                        .font(.callout.weight(.medium))
                        .lineLimit(1)
                    Text(vm.pdfData == nil ? "Choose a resume to start" : "Ready to upload")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    showPicker = true
                } label: {
                    Text("Select")
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var jdCard: some View {
        Card(title: "Job Description", subtitle: "Paste JD text here") {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $vm.jobDescription)
                    .frame(minHeight: 180)
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                if vm.jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Paste the job description...")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
        }
    }

    // MARK: Actions

    private func actionButtons(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: 10) {
            Button {
                Task {
                    didRunOnce = true
                    if mode == .analyze {
                        await vm.runAnalyze()
                    } else {
                        await vm.runRewrite()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: mode == .analyze ? "magnifyingglass" : "sparkles")
                    Text(mode == .analyze ? "Run Analysis" : "Generate Rewrite")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isLoading)

            Button {
                withAnimation {
                    vm.resetResults()
                    didRunOnce = false
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.bordered)
            .disabled(vm.isLoading)
        }
        .padding(.top, 2)
    }

    // MARK: Results

    private var resultsSection: some View {
        VStack(spacing: 12) {
            if mode == .analyze {
                if let res = vm.analyzeResult {
                    AnalyzeResultCard(res: res)
                } else {
                    Card(title: "Results") {
                        Text("Run analysis to see scores and matches.")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                            .padding(.vertical, 6)
                    }
                }
            } else {
                if let res = vm.rewriteResult {
                    RewriteResultCard(res: res)
                } else {
                    Card(title: "Results") {
                        Text("Generate rewrite to get improved summary and bullets.")
                            .foregroundStyle(.secondary)
                            .font(.callout)
                            .padding(.vertical, 6)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Analysis Card

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

// MARK: - Rewrite Card

struct RewriteResultCard: View {
    let res: RewriteResponse

    var body: some View {
        Card(title: "Rewrite", subtitle: subtitleLine) {
            VStack(alignment: .leading, spacing: 12) {

                if !res.rewrite.tailored_summary.isEmpty {
                    SectionHeader("Tailored summary")
                    Text(res.rewrite.tailored_summary)
                        .font(.callout)
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if !res.rewrite.skills_section.isEmpty {
                    SectionHeader("Suggested skills section")
                    ChipFlow(items: res.rewrite.skills_section)
                }

                if !res.rewrite.rewritten_bullets.isEmpty {
                    SectionHeader("Rewritten bullets")
                    BulletList(items: res.rewrite.rewritten_bullets)
                }

                if !res.rewrite.gap_notes.isEmpty {
                    SectionHeader("Gap notes")
                    BulletList(items: res.rewrite.gap_notes, secondary: true)
                }
            }
        }
    }

    private var subtitleLine: String {
        var parts: [String] = []
        if let method = res.extraction_method { parts.append("Extraction: \(method)") }
        if let score = res.keyword_score { parts.append("Keyword: \(String(format: "%.1f", score))") }
        return parts.isEmpty ? "Ollama output" : parts.joined(separator: " • ")
    }
}
