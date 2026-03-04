//
//  ResumeMatcherVM.swift
//  ResumeSenseAI
//
//  Created by Muneeb Zain on 04/03/2026.
//

import Foundation
import Combine

@MainActor
final class ResumeMatcherVM: ObservableObject {
    @Published var pdfData: Data?
    @Published var pdfFilename: String = "resume.pdf"
    @Published var jobDescription: String = ""

    @Published var isLoading: Bool = false
    @Published var errorText: String?

    @Published var analyzeResult: AnalyzeResponse?
    @Published var rewriteResult: RewriteResponse?

    func setPDF(data: Data, filename: String) {
        self.pdfData = data
        self.pdfFilename = filename
        self.errorText = nil
    }

    func runAnalyze() async {
        guard let pdfData else {
            errorText = "Please select a PDF resume first."
            return
        }
        if jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorText = "Please paste a job description."
            return
        }

        isLoading = true
        errorText = nil
        rewriteResult = nil

        do {
            let res = try await APIClient.shared.analyze(
                pdfData: pdfData,
                filename: pdfFilename,
                jobDescription: jobDescription
            )
            analyzeResult = res
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }

    func runRewrite() async {
        guard let pdfData else {
            errorText = "Please select a PDF resume first."
            return
        }
        if jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorText = "Please paste a job description."
            return
        }

        isLoading = true
        errorText = nil

        do {
            let res = try await APIClient.shared.rewrite(
                pdfData: pdfData,
                filename: pdfFilename,
                jobDescription: jobDescription
            )
            rewriteResult = res
        } catch {
            errorText = error.localizedDescription
        }

        isLoading = false
    }
}
