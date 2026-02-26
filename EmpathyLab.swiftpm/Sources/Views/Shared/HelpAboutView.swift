import SwiftUI

struct HelpAboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Neural Lab")
                        .font(Typography.hero)

                    Text("Neural Lab is a fully offline, glass-box experience to explore neural networks.")
                        .font(Typography.body)

                    Label("No analytics, no login, no network.", systemImage: "lock.shield")
                    Label("Use Guided Path for 3–5 minute lessons.", systemImage: "sparkles")
                    Label("Use Playground for free experiments.", systemImage: "slider.horizontal.3")

                    Text("Tip: If training is unstable, open Diagnostics and tap a fix.")
                        .font(Typography.body)
                        .padding(.top, 4)
                }
                .padding(24)
            }
            .navigationTitle("About & Help")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
