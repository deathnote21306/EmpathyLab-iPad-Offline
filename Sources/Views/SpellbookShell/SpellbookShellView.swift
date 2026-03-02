import SwiftUI

struct SpellbookShellView: View {
    let onExit: () -> Void

    @State private var currentScene: SpellSceneID = .awakening
    @State private var transitionDirection: Int = 1
    @State private var activeModal: SpellModalKey?
    @State private var revealMath: Bool = false
    @State private var resetSeed: Int = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(onExit: @escaping () -> Void = {}) {
        self.onExit = onExit
    }

    private var scenes: [SpellSceneID] {
        SpellSceneID.allCases
    }

    private var currentIndex: Int {
        scenes.firstIndex(of: currentScene) ?? 0
    }

    private var progressValue: CGFloat {
        guard scenes.count > 1 else { return 0 }
        return CGFloat(currentIndex) / CGFloat(scenes.count - 1)
    }

    private var sceneTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }

        let insertionEdge: Edge = transitionDirection >= 0 ? .trailing : .leading
        let removalEdge: Edge = transitionDirection >= 0 ? .leading : .trailing

        return .asymmetric(
            insertion: .opacity.combined(with: .move(edge: insertionEdge)),
            removal: .opacity.combined(with: .move(edge: removalEdge))
        )
    }

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()
            SpellCosmosBackgroundView()

            sceneLayer
                .padding(.top, 26)

            VStack(spacing: 0) {
                SpellProgressBarView(progress: progressValue)
                Spacer()
            }
            .ignoresSafeArea(edges: .top)

            topBar

            if let activeModal {
                SpellModalOverlayView(modal: activeModal) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.activeModal = nil
                    }
                }
                .zIndex(2)
            }
        }
    }

    private var topBar: some View {
        VStack {
            HStack(spacing: 12) {
                SpellButton(title: "Home", tone: .gold) {
                    resetAndReturnToStart()
                }

                Spacer()

                SpellNavDotsView(scenes: scenes, activeScene: currentScene) { scene in
                    go(to: scene)
                }

                Spacer()

                Text("\(currentIndex + 1)/\(scenes.count)")
                    .font(.custom("AvenirNext-DemiBold", size: 11))
                    .tracking(1.3)
                    .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.24), in: Capsule(style: .continuous))
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            Spacer()
        }
    }

    private var sceneLayer: some View {
        ZStack {
            ForEach(scenes) { scene in
                if scene == currentScene {
                    sceneView(scene)
                        .id("\(scene.id)-\(resetSeed)")
                        .transition(sceneTransition)
                }
            }
        }
        .animation(.easeInOut(duration: 0.9), value: currentScene)
    }

    @ViewBuilder
    private func sceneView(_ scene: SpellSceneID) -> some View {
        switch scene {
        case .awakening:
            AwakeningSceneView {
                go(to: .introForward)
            }

        case .introForward:
            IntroForwardSceneView {
                go(to: .sceneForward)
            }

        case .sceneForward:
            ForwardPassSceneView(
                onNext: { go(to: .introLoss) },
                onOpenModal: { openModal($0) }
            )

        case .introLoss:
            IntroLossSceneView {
                go(to: .sceneLoss)
            }

        case .sceneLoss:
            LossSceneView(
                onNext: { go(to: .introBackprop) },
                onOpenModal: { openModal($0) }
            )

        case .introBackprop:
            IntroBackpropSceneView {
                go(to: .sceneBackprop)
            }

        case .sceneBackprop:
            BackpropSceneView(
                onNext: { go(to: .introHyper) },
                onOpenModal: { openModal($0) },
                mathReveal: $revealMath
            )

        case .introHyper:
            IntroHyperSceneView {
                go(to: .sceneHyper)
            }

        case .sceneHyper:
            HyperSceneView(
                onNext: { go(to: .introInspect) },
                onOpenModal: { openModal($0) },
                mathReveal: $revealMath
            )

        case .introInspect:
            IntroInspectSceneView {
                go(to: .sceneInspect)
            }

        case .sceneInspect:
            InspectSceneView(onNext: {
                go(to: .sceneFinale)
            }, mathReveal: $revealMath)

        case .sceneFinale:
            FinaleSceneView {
                resetAndReturnToStart()
            }
        }
    }

    private func openModal(_ key: SpellModalKey) {
        withAnimation(.easeInOut(duration: 0.3)) {
            activeModal = key
        }
    }

    private func go(to scene: SpellSceneID) {
        guard scene != currentScene,
              let oldIndex = scenes.firstIndex(of: currentScene),
              let newIndex = scenes.firstIndex(of: scene)
        else { return }

        transitionDirection = newIndex >= oldIndex ? 1 : -1

        if reduceMotion {
            currentScene = scene
        } else {
            withAnimation(.easeInOut(duration: 0.9)) {
                currentScene = scene
            }
        }
    }

    private func resetAndReturnToStart() {
        revealMath = false
        activeModal = nil
        resetSeed += 1
        go(to: .awakening)
    }
}
