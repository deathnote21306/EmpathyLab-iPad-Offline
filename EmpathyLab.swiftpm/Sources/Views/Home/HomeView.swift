import SwiftUI

struct HomeView: View {
    let onStartGuidedPath: () -> Void
    let onOpenPlayground: () -> Void
    let onOpenHelp: () -> Void

    @EnvironmentObject private var appState: AppState

    @State private var showRecipeWizard = false
    @State private var recipeDataChoice: RecipeDataChoice = .points2D
    @State private var recipeTaskChoice: RecipeTaskChoice = .classify
    @State private var recipeConstraintChoice: RecipeConstraintChoice = .balanced

    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Guided Path (3–5 min)", systemImage: "sparkles")
                                .font(Typography.title)
                            Text("Learn through six tiny interactive lessons. Move one control, see one clear effect.")
                                .font(Typography.body)
                                .foregroundStyle(.secondary)
                            PrimaryActionButton(title: "Start Guided Path", systemImage: "play.fill", action: onStartGuidedPath)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Free Playground", systemImage: "brain")
                                .font(Typography.title)
                            Text("Build a tiny MLP, train it step-by-step, and inspect tensors live.")
                                .font(Typography.body)
                                .foregroundStyle(.secondary)
                            PrimaryActionButton(title: "Open Playground", systemImage: "slider.horizontal.3", action: onOpenPlayground)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Smart Recipe", systemImage: "wand.and.stars")
                                .font(Typography.title)
                            Text("Answer 3 quick questions and apply recommended defaults in one tap.")
                                .font(Typography.body)
                                .foregroundStyle(.secondary)
                            PrimaryActionButton(title: "Open Recipe Wizard", systemImage: "lightbulb", action: {
                                showRecipeWizard = true
                            })
                        }
                    }

                    Button("About & Help", action: onOpenHelp)
                        .buttonStyle(.bordered)
                        .tint(.white)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding(24)
                .frame(maxWidth: 920)
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showRecipeWizard) {
            recipeWizard
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.title)
                Text("Neural Lab")
                    .font(Typography.hero)
                    .foregroundStyle(.white)
            }
            Text("A glass-box neural network playground for curious beginners.")
                .font(Typography.body)
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private var recipeWizard: some View {
        NavigationStack {
            Form {
                Section("1) Data type") {
                    Picker("Data", selection: $recipeDataChoice) {
                        ForEach(RecipeDataChoice.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }

                Section("2) Task") {
                    Picker("Task", selection: $recipeTaskChoice) {
                        ForEach(RecipeTaskChoice.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }

                Section("3) Constraint") {
                    Picker("Constraint", selection: $recipeConstraintChoice) {
                        ForEach(RecipeConstraintChoice.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Recipe Wizard")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { showRecipeWizard = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        let answers = RecipeAnswers(
                            dataChoice: recipeDataChoice,
                            taskChoice: recipeTaskChoice,
                            constraintChoice: recipeConstraintChoice
                        )
                        let recommendation = RecipeEngine.recommend(for: answers)
                        appState.playgroundViewModel.applyRecipe(recommendation)
                        showRecipeWizard = false
                    }
                }
            }
        }
    }
}
