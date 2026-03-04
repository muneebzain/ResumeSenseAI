//
//  PDFPicker.swift
//  ResumeSenseAI
//
//  Created by Muneeb Zain on 04/03/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct PDFPicker: UIViewControllerRepresentable {
    let onPick: (Data, String) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (Data, String) -> Void

        init(onPick: @escaping (Data, String) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            do {
                let data = try Data(contentsOf: url)
                onPick(data, url.lastPathComponent)
            } catch {
                // Ignore for MVP; surface later if needed.
            }
        }
    }
}
