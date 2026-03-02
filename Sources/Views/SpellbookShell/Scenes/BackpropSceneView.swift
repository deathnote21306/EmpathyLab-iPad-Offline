import SwiftUI
import UIKit

// MARK: - Layer data

private struct BackpropLayerInfo {
    let name: String
    let subtitle: String
    let correctedSubtitle: String
    let nodes: Int
    let blame: Double
    let correctedBlame: Double
    let color: Color
}

// MARK: - Scene

struct BackpropSceneView: View {
    let onNext: () -> Void
    let onOpenModal: (SpellModalKey) -> Void
    @Binding var mathReveal: Bool

    @State private var step: Int = 0
    @State private var correctedLayers: Set<Int> = []
    @State private var showPencilHint = false

    private let crimson = Color(red: 0.85, green: 0.19, blue: 0.38)
    private let spirit  = Color(red: 0.24, green: 0.84, blue: 0.75)

    private var allDone: Bool { correctedLayers.count == layers.count }

    private let layers: [BackpropLayerInfo] = [
        .init(name: "OUTPUT",     subtitle: "The source of the mistake",
              correctedSubtitle: "Weights nudged — output adjusted",
              nodes: 2, blame: 0.86, correctedBlame: 0.52,
              color: Color(red: 0.85, green: 0.19, blue: 0.38)),
        .init(name: "DEEP LAYER", subtitle: "Close to the error",
              correctedSubtitle: "Hidden patterns recalibrated",
              nodes: 4, blame: 0.62, correctedBlame: 0.38,
              color: Color(red: 1.00, green: 0.42, blue: 0.21)),
        .init(name: "MID LAYER",  subtitle: "Further from the source",
              correctedSubtitle: "Mid-layer features tuned",
              nodes: 4, blame: 0.46, correctedBlame: 0.28,
              color: Color(red: 0.91, green: 0.72, blue: 0.29)),
        .init(name: "INPUT",      subtitle: "Faintest echo of the mistake",
              correctedSubtitle: "Input weights refined",
              nodes: 3, blame: 0.30, correctedBlame: 0.18,
              color: Color(red: 0.63, green: 0.50, blue: 1.00)),
    ]

    private var narratorText: String {
        if allDone { return "Weights corrected. Blame shrinks across every layer — the network is now smarter." }
        switch step {
        case 0: return "The AI made a wrong prediction. Something went wrong — but where exactly?"
        case 1: return "The output layer felt it first. It carries the heaviest blame."
        case 2: return "It passes part of the blame to the layer behind it."
        case 3: return "Blame keeps traveling, fading with each layer it crosses."
        default: return "Every layer now holds a share of blame. Hold your Pencil on each one to correct it."
        }
    }

    private var actionLabel: String {
        switch step {
        case 0:       return "REVEAL THE CULPRIT"
        case 1, 2, 3: return "PASS BLAME DEEPER  ↓"
        default:      return ""
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            BackpropAmbientView(step: allDone ? 5 : step)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Chapter label
                    HStack {
                        Text("CHAPTER III · BACKPROPAGATION")
                            .font(.custom("AvenirNext-DemiBold", size: 9.5))
                            .tracking(3.5)
                            .foregroundStyle(crimson.opacity(0.45))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer(minLength: 16)

                    // ── Narrator
                    Text(narratorText)
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .id("\(step)-\(allDone)")
                        .transition(.opacity.combined(with: .offset(y: 5)))
                        .animation(.easeInOut(duration: 0.35), value: step)
                        .animation(.easeInOut(duration: 0.35), value: allDone)

                    Spacer(minLength: 24)

                    // ── Layer stack
                    VStack(spacing: 0) {
                        ForEach(Array(layers.enumerated()), id: \.offset) { index, layer in

                            LayerBlameCard(
                                layer: layer,
                                isRevealed: step > index,
                                isDone: correctedLayers.contains(index),
                                isActive: step == index + 1,
                                canCorrect: step >= 4 && !correctedLayers.contains(index),
                                onCorrect: {
                                    withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                                        correctedLayers.insert(index)
                                    }
                                    let gen = UIImpactFeedbackGenerator(style: .heavy)
                                    gen.impactOccurred()
                                }
                            )
                            .padding(.horizontal, 16)

                            if index < layers.count - 1 {
                                BlameFlowConnector(
                                    color: layer.color,
                                    nextBlame: layers[index + 1].blame,
                                    isVisible: step >= index + 2,
                                    isActive: step == index + 2,
                                    isDone: allDone
                                )
                            }
                        }
                    }

                    Spacer(minLength: 130)
                }
            }

            // ── Bottom gradient
            LinearGradient(
                colors: [.clear, Color(red: 0.03, green: 0.01, blue: 0.07).opacity(0.97)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 170)
            .allowsHitTesting(false)

            // ── Pencil hint banner (appears when all layers are revealed)
            if showPencilHint {
                InteractionHintBanner(
                    icon: "applepencil",
                    text: "Hold your Apple Pencil — or finger — on each layer to apply the correction"
                )
                .padding(.horizontal, 18)
                .padding(.bottom, 185)
                .transition(.opacity.combined(with: .offset(y: 6)))
            }

            // ── Buttons
            VStack(spacing: 8) {
                if step < 4 {
                    SpellButton(
                        title: actionLabel,
                        tone: .danger,
                        isPulsing: step == 0
                    ) {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
                            step = min(step + 1, 4)
                        }
                    }
                } else if allDone {
                    HStack(spacing: 10) {
                        SpellButton(title: "✦ Deep Dive", tone: .gold) {
                            onOpenModal(.backprop)
                        }
                        SpellButton(title: "Chapter IV →", tone: .spirit, isPulsing: true) {
                            onNext()
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if step > 0 || !correctedLayers.isEmpty {
                    Button("↺ Start over") {
                        withAnimation(.easeInOut(duration: 0.30)) {
                            step = 0
                            correctedLayers = []
                            showPencilHint = false
                        }
                    }
                    .font(.custom("AvenirNext-DemiBold", size: 11))
                    .foregroundStyle(.white.opacity(0.28))
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 90)
            .animation(.easeInOut(duration: 0.35), value: step)
            .animation(.easeInOut(duration: 0.35), value: allDone)
        }
        .onChange(of: step) { _, newStep in
            if newStep == 4 {
                withAnimation(.easeInOut(duration: 0.40)) { showPencilHint = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    withAnimation(.easeOut(duration: 0.40)) { showPencilHint = false }
                }
            }
        }
    }
}

// MARK: - Layer blame card

private struct LayerBlameCard: View {
    let layer: BackpropLayerInfo
    let isRevealed: Bool
    let isDone: Bool
    let isActive: Bool
    let canCorrect: Bool
    let onCorrect: () -> Void

    @State private var holdProgress: CGFloat = 0

    private let spirit = Color(red: 0.24, green: 0.84, blue: 0.75)

    private var displayColor: Color     { isDone ? spirit : layer.color }
    private var displayBlame: Double    { isDone ? layer.correctedBlame : layer.blame }
    private var displaySubtitle: String { isDone ? layer.correctedSubtitle : layer.subtitle }

    var body: some View {
        ZStack {
            // ── Main card content
            HStack(spacing: 14) {

                // Rune orbs
                HStack(spacing: 5) {
                    ForEach(0..<layer.nodes, id: \.self) { i in
                        RuneOrb(isLit: isRevealed, color: displayColor, phase: Double(i) * 0.55)
                    }
                }
                .frame(minWidth: 70, alignment: .leading)

                // Name + subtitle
                VStack(alignment: .leading, spacing: 3) {
                    Text(layer.name)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundStyle(isRevealed ? displayColor : .white.opacity(0.22))

                    if isRevealed {
                        Text(displaySubtitle)
                            .font(.custom("AvenirNext-Regular", size: 11))
                            .foregroundStyle(displayColor.opacity(0.62))
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.30), value: isRevealed)
                .animation(.easeInOut(duration: 0.35), value: isDone)

                Spacer()

                // Blame % + bar
                if isRevealed {
                    VStack(alignment: .trailing, spacing: 5) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(String(format: "%.0f%%", displayBlame * 100))
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundStyle(displayColor)
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.55, dampingFraction: 0.72), value: isDone)

                            if isDone {
                                let delta = Int(round((layer.correctedBlame - layer.blame) * 100))
                                Text(String(format: "%d", delta))
                                    .font(.custom("AvenirNext-DemiBold", size: 10))
                                    .foregroundStyle(spirit)
                                    .transition(.scale(scale: 0.7).combined(with: .opacity))
                            }
                        }

                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule().fill(.white.opacity(0.06))
                                Capsule()
                                    .fill(LinearGradient(
                                        colors: [displayColor, displayColor.opacity(0.52)],
                                        startPoint: .leading, endPoint: .trailing
                                    ))
                                    .frame(width: proxy.size.width * CGFloat(displayBlame))
                                    .shadow(color: displayColor.opacity(0.50), radius: 6)
                                    .animation(.spring(response: 0.65, dampingFraction: 0.74), value: isDone)
                            }
                        }
                        .frame(width: 80, height: 6)

                        // Bottom label: HOLD progress, CORRECTED, or BLAME
                        if canCorrect {
                            HStack(spacing: 3) {
                                Image(systemName: holdProgress > 0 ? "circle.fill" : "hand.point.up.fill")
                                    .font(.system(size: 7))
                                Text(holdProgress > 0
                                     ? String(format: "%.0f%%", holdProgress * 100)
                                     : "HOLD")
                                    .font(.custom("AvenirNext-DemiBold", size: 8))
                                    .tracking(1.5)
                            }
                            .foregroundStyle(layer.color.opacity(0.85))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(layer.color.opacity(0.14), in: Capsule())
                        } else {
                            Text(isDone ? "CORRECTED ✦" : "BLAME")
                                .font(.custom("AvenirNext-DemiBold", size: 8))
                                .tracking(2)
                                .foregroundStyle(isDone ? spirit.opacity(0.70) : .white.opacity(0.25))
                                .animation(.easeInOut(duration: 0.25), value: isDone)
                        }
                    }
                    .transition(.opacity.combined(with: .offset(x: 8)))
                    .animation(.easeInOut(duration: 0.25), value: isDone)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                displayColor.opacity(isRevealed ? (isDone ? 0.12 : (canCorrect ? 0.10 : 0.08)) : 0.03),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(displayColor.opacity(isRevealed ? (isDone ? 0.50 : 0.32) : 0.08), lineWidth: 1.5)
            )

            // ── Hold progress ring
            if canCorrect && holdProgress > 0 {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .trim(from: 0, to: holdProgress)
                    .stroke(
                        layer.color,
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                    )
                    .allowsHitTesting(false)
            }

            // ── Touch capture overlay (finger or Pencil)
            if canCorrect {
                PencilHoldView(
                    holdDuration: 1.5,
                    onProgress: { p in holdProgress = p },
                    onComplete: onCorrect
                )
            }
        }
        .opacity(isRevealed ? 1.0 : 0.38)
        .scaleEffect(isActive ? 1.015 : 1.0)
        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: isRevealed)
        .animation(.spring(response: 0.55, dampingFraction: 0.78), value: isDone)
        .animation(.spring(response: 0.50, dampingFraction: 0.80), value: isActive)
    }
}

// MARK: - Rune orb

private struct RuneOrb: View {
    let isLit: Bool
    let color: Color
    let phase: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            let pulse = isLit ? CGFloat(0.65 + 0.35 * sin(t * 2.2 + phase)) : 0

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            isLit
                                ? color.opacity(0.80 * pulse)
                                : Color(red: 0.10, green: 0.05, blue: 0.22),
                            Color(red: 0.04, green: 0.02, blue: 0.10)
                        ],
                        center: .center, startRadius: 0, endRadius: 12
                    )
                )
                .frame(width: 20, height: 20)
                .overlay(
                    Circle().stroke(
                        isLit ? color.opacity(0.65 + 0.35 * pulse) : Color.white.opacity(0.10),
                        lineWidth: 1.5
                    )
                )
                .shadow(color: isLit ? color.opacity(0.45 * pulse) : .clear, radius: 6)
        }
    }
}

// MARK: - Blame flow connector

private struct BlameFlowConnector: View {
    let color: Color
    let nextBlame: Double
    let isVisible: Bool
    let isActive: Bool
    let isDone: Bool

    private var displayColor: Color {
        isDone ? Color(red: 0.24, green: 0.84, blue: 0.75) : color
    }

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            VStack(spacing: 4) {
                TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
                    let t    = tl.date.timeIntervalSinceReferenceDate
                    let glow = isActive ? CGFloat(0.55 + 0.45 * sin(t * 3.5)) : CGFloat(1.0)

                    VStack(spacing: 3) {
                        Rectangle()
                            .fill(isVisible
                                  ? displayColor.opacity(0.65 * glow)
                                  : Color.white.opacity(0.07))
                            .frame(width: 2, height: 14)
                            .shadow(color: isActive ? displayColor.opacity(0.60 * glow) : .clear,
                                    radius: 6)

                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(isVisible
                                             ? displayColor.opacity(0.80 * glow)
                                             : .white.opacity(0.07))
                    }
                }

                if isVisible {
                    Text(String(format: "%.0f%%  passed", nextBlame * 100))
                        .font(.custom("AvenirNext-DemiBold", size: 9))
                        .tracking(0.5)
                        .foregroundStyle(displayColor.opacity(0.58))
                        .transition(.opacity)
                }
            }
            .frame(width: 90)
            .animation(.easeInOut(duration: 0.35), value: isVisible)

            Spacer()
        }
        .frame(height: isVisible ? 48 : 30)
        .animation(.easeInOut(duration: 0.30), value: isVisible)
    }
}

// MARK: - Ambient background

private struct BackpropAmbientView: View {
    let step: Int

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let pulse     = CGFloat(0.75 + 0.25 * sin(t * 0.65))
                let intensity = CGFloat(0.04 + Double(min(step, 4)) * 0.022) * pulse
                let isDone    = step >= 5
                let glowColor = isDone
                    ? Color(red: 0.24, green: 0.84, blue: 0.75)
                    : Color(red: 0.85, green: 0.19, blue: 0.38)

                ctx.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.50, y: -size.height * 0.08,
                                           width: size.width * 0.72, height: size.height * 0.62)),
                    with: .radialGradient(
                        Gradient(colors: [glowColor.opacity(intensity), .clear]),
                        center: CGPoint(x: size.width * 0.88, y: 0),
                        startRadius: 0, endRadius: size.width * 0.46
                    )
                )
                ctx.fill(
                    Path(ellipseIn: CGRect(x: -size.width * 0.12, y: size.height * 0.30,
                                           width: size.width * 0.58, height: size.height * 0.58)),
                    with: .radialGradient(
                        Gradient(colors: [Color(red: 1.0, green: 0.42, blue: 0.21).opacity(intensity * 0.65), .clear]),
                        center: CGPoint(x: 0, y: size.height * 0.62),
                        startRadius: 0, endRadius: size.width * 0.40
                    )
                )
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
