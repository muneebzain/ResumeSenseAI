
import SwiftUI

struct RewriteResultCard: View {
    let res: RewriteResponse

    var body: some View {
        Card(title: "Rewrite", subtitle: "Ollama output") {
            VStack(alignment: .leading, spacing: 12) {

                if let summary = res.rewrite.tailored_summary, !summary.isEmpty {
                    SectionHeader("Tailored summary")
                    Text(summary)
                        .font(.callout)
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                if let skills = res.rewrite.skills_section, !skills.isEmpty {
                    SectionHeader("Suggested skills section")
                    ChipFlow(items: skills)
                }

                if let bullets = res.rewrite.rewritten_bullets, !bullets.isEmpty {
                    SectionHeader("Rewritten bullets")
                    BulletList(items: bullets)
                }

                if let notes = res.rewrite.gap_notes, !notes.isEmpty {
                    SectionHeader("Gap notes")
                    BulletList(items: notes, secondary: true)
                }
            }
        }
    }
}
