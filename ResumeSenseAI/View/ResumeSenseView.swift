//
//  ContentView.swift
//  ResumeSenseAI
//
//  Created by Muneeb Zain on 04/03/2026.
//

import SwiftUI

struct ResumeSenseView: View {
    @StateObject private var vm = ResumeMatcherVM()
    @State private var showPicker = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    Text("Resume Matcher AI")
                        .font(.title2.bold())

                    GroupBox("Backend URL") {
                        TextField("http://192.168.x.x:8000", text: Binding(
                            get: { APIClient.shared.baseURL },
                            set: { APIClient.shared.baseURL = $0 }
                        ))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    }

                    GroupBox("Resume PDF") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(vm.pdfData == nil ? "No PDF selected" : vm.pdfFilename)
                                .font(.subheadline)

                            Button("Select PDF") { showPicker = true }
                        }
                    }

                    GroupBox("Job Description") {
                        TextEditor(text: $vm.jobDescription)
                            .frame(minHeight: 180)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.gray.opacity(0.3)))
                    }

                    if let err = vm.errorText {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }

                    HStack {
                        Button {
                            Task { await vm.runAnalyze() }
                        } label: {
                            Text("Analyze (V1+V2)")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.isLoading)

                        Button {
                            Task { await vm.runRewrite() }
                        } label: {
                            Text("Rewrite (V3 Ollama)")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(vm.isLoading)
                    }

                    if vm.isLoading {
                        ProgressView("Working...")
                            .padding(.top, 6)
                    }

                    if let res = vm.analyzeResult {
                        AnalyzeResultView(res: res)
                    }

                    if let rw = vm.rewriteResult {
                        RewriteResultView(res: rw)
                    }

                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPicker) {
            PDFPicker { data, filename in
                vm.setPDF(data: data, filename: filename)
                showPicker = false
            }
        }
    }
}

struct AnalyzeResultView: View {
    let res: AnalyzeResponse

    var body: some View {
        GroupBox("Analysis Result") {
            VStack(alignment: .leading, spacing: 10) {

                if let method = res.extraction_method {
                    Text("Extraction: \(method)")
                        .font(.subheadline)
                }

                let keyword = res.keyword_score ?? res.score
                if let keyword {
                    Text("Keyword score: \(String(format: "%.1f", keyword))")
                }
                if let semantic = res.semantic_score {
                    Text("Semantic score: \(String(format: "%.1f", semantic))")
                }
                if let final = res.final_score {
                    Text("Final score: \(String(format: "%.1f", final))")
                        .font(.headline)
                }

                if let matched = res.matched_keywords, !matched.isEmpty {
                    Text("Matched keywords")
                        .font(.subheadline.bold())
                    WrapChips(items: matched)
                }

                if let missing = res.missing_keywords, !missing.isEmpty {
                    Text("Missing keywords")
                        .font(.subheadline.bold())
                    WrapChips(items: missing)
                }

                if let suggestions = res.suggestions, !suggestions.isEmpty {
                    Text("Suggestions")
                        .font(.subheadline.bold())
                    ForEach(suggestions, id: \.self) { s in
                        Text("• \(s)")
                    }
                }

                if let matches = res.semantic_matches, !matches.isEmpty {
                    Text("Semantic matches (top)")
                        .font(.subheadline.bold())

                    ForEach(matches.prefix(3)) { m in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("JD: \(m.jd_requirement)")
                                .font(.caption)
                            if let t = m.matched_resume_text {
                                Text("Resume: \(t)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            if let sim = m.similarity {
                                Text("Similarity: \(String(format: "%.3f", sim))")
                                    .font(.caption2)
                            }
                        }
                        .padding(.vertical, 6)
                        Divider()
                    }
                }
            }
        }
    }
}

struct RewriteResultView: View {
    let res: RewriteResponse

    var body: some View {
        GroupBox("Rewrite Result (Ollama)") {
            VStack(alignment: .leading, spacing: 10) {

                if let method = res.extraction_method {
                    Text("Extraction: \(method)")
                        .font(.subheadline)
                }
                if let ks = res.keyword_score {
                    Text("Keyword score: \(String(format: "%.1f", ks))")
                        .font(.subheadline)
                }

                Text("Tailored summary")
                    .font(.subheadline.bold())
                Text(res.rewrite.tailored_summary)

                Text("Skills section")
                    .font(.subheadline.bold())
                WrapChips(items: res.rewrite.skills_section)

                Text("Rewritten bullets")
                    .font(.subheadline.bold())
                ForEach(res.rewrite.rewritten_bullets, id: \.self) { b in
                    Text("• \(b)")
                }

                if !res.rewrite.gap_notes.isEmpty {
                    Text("Gap notes")
                        .font(.subheadline.bold())
                    ForEach(res.rewrite.gap_notes, id: \.self) { n in
                        Text("• \(n)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct WrapChips: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.gray.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}
