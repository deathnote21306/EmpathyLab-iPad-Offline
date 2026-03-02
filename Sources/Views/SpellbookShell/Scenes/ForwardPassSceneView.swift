import SwiftUI

private enum ForwardNodeKind {
    case input
    case hidden
    case output

    var tint: Color {
        switch self {
        case .input:  return Color(red: 0.91, green: 0.72, blue: 0.29)
        case .hidden: return Color(red: 0.49, green: 0.38, blue: 1.0)
        case .output: return Color(red: 0.24, green: 0.84, blue: 0.75)
        }
    }

    var badgeTitle: String {
        switch self {
        case .input:  return "Input"
        case .hidden: return "Hidden"
        case .output: return "Output"
        }
    }
}

private struct ForwardNodeSnapshot: Identifiable, Equatable {
    let id: String
    let layerIndex: Int
    let nodeIndex: Int
    let label: String
    let title: String
    let kind: ForwardNodeKind
    let activation: Double
    let role: String
    let incoming: String
    let meaning: String
    let whyItMatters: String
}

struct ForwardPassSceneView: View {
    let onNext: () -> Void
    let onOpenModal: (SpellModalKey) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedNodeID: String?
    @State private var castStartTime: Date? = nil
    @State private var isCasting = false
    @State private var didCast = false
    @State private var castToken = UUID()

    private let nodeData: [[ForwardNodeSnapshot]] = [
        [
            .init(id: "l0n0", layerIndex: 0, nodeIndex: 0, label: "x₁", title: "Brightness Glyph",
                  kind: .input, activation: 0.92,
                  role: "High brightness input - fires strongly.",
                  incoming: "Raw sample value: 0.92",
                  meaning: "This glyph enters with strong energy, so it pushes the network to pay attention immediately.",
                  whyItMatters: "Inputs are the evidence. If the evidence changes, every later rune reacts differently."),
            .init(id: "l0n1", layerIndex: 0, nodeIndex: 1, label: "x₂", title: "Texture Glyph",
                  kind: .input, activation: 0.41,
                  role: "Medium texture input - partial signal.",
                  incoming: "Raw sample value: 0.41",
                  meaning: "This signal is present, but quieter. It adds context instead of dominating the decision.",
                  whyItMatters: "Not every feature should shout. Medium signals help the network balance its judgment."),
            .init(id: "l0n2", layerIndex: 0, nodeIndex: 2, label: "x₃", title: "Edge Glyph",
                  kind: .input, activation: 0.67,
                  role: "Edge contrast input - moderate fire.",
                  incoming: "Raw sample value: 0.67",
                  meaning: "This glyph contributes useful edge contrast, so several hidden runes borrow energy from it.",
                  whyItMatters: "Inputs do not decide alone. They become powerful when hidden runes combine them into patterns.")
        ],
        [
            .init(id: "l1n0", layerIndex: 1, nodeIndex: 0, label: "h₁", title: "Pattern Rune H1",
                  kind: .hidden, activation: 0.83,
                  role: "Detects high x₁ + x₃ pattern.",
                  incoming: "Mostly listens to x₁ and x₃",
                  meaning: "This rune lights strongly because brightness and edge energy align with the pattern it learned.",
                  whyItMatters: "Hidden runes turn raw evidence into reusable features."),
            .init(id: "l1n1", layerIndex: 1, nodeIndex: 1, label: "h₂", title: "Pattern Rune H2",
                  kind: .hidden, activation: 0.28,
                  role: "Dormant - pattern absent here.",
                  incoming: "Responds to a softer mix of x₂ and x₃",
                  meaning: "This rune barely wakes up. Its preferred pattern is mostly absent in this sample.",
                  whyItMatters: "A quiet rune is still informative. It tells us which patterns are not present."),
            .init(id: "l1n2", layerIndex: 1, nodeIndex: 2, label: "h₃", title: "Pattern Rune H3",
                  kind: .hidden, activation: 0.74,
                  role: "Responds to edge contrast.",
                  incoming: "Strongly shaped by x₃",
                  meaning: "This rune reacts to contrast, so it joins H1 in sending useful signal forward.",
                  whyItMatters: "Different hidden runes specialize. Together, they give the output layer more nuanced evidence."),
            .init(id: "l1n3", layerIndex: 1, nodeIndex: 3, label: "h₄", title: "Gate Rune H4",
                  kind: .hidden, activation: 0.55,
                  role: "Gate neuron - mid-range filter.",
                  incoming: "Balances all three inputs",
                  meaning: "This rune is partially open. It lets some evidence pass while softening weaker combinations.",
                  whyItMatters: "Moderate activations keep the network flexible.")
        ],
        [
            .init(id: "l2n0", layerIndex: 2, nodeIndex: 0, label: "h₅", title: "Fusion Rune H5",
                  kind: .hidden, activation: 0.91,
                  role: "Strong feature combination.",
                  incoming: "Combines H1, H3, and H4",
                  meaning: "This rune receives strong support from earlier patterns, so it becomes the clearest signal in the network.",
                  whyItMatters: "Deeper layers combine earlier runes into richer concepts."),
            .init(id: "l2n1", layerIndex: 2, nodeIndex: 1, label: "h₆", title: "Fusion Rune H6",
                  kind: .hidden, activation: 0.44,
                  role: "Weak - reinforces caution.",
                  incoming: "Mostly listens to H2 and H4",
                  meaning: "This rune adds a small cautionary signal, but it does not take over the decision.",
                  whyItMatters: "A good network keeps both positive and cautionary evidence in play before the final choice."),
            .init(id: "l2n2", layerIndex: 2, nodeIndex: 2, label: "h₇", title: "Fusion Rune H7",
                  kind: .hidden, activation: 0.68,
                  role: "Moderate output contributor.",
                  incoming: "Built from H1 and H3",
                  meaning: "This rune contributes enough evidence to matter, but not enough to dominate H5.",
                  whyItMatters: "Multiple useful runes make the output more stable than relying on a single path."),
            .init(id: "l2n3", layerIndex: 2, nodeIndex: 3, label: "h₈", title: "Fusion Rune H8",
                  kind: .hidden, activation: 0.37,
                  role: "Low activation - mostly dormant.",
                  incoming: "Weak blend of H2 and H4",
                  meaning: "This rune stays dim, so its influence on the final output is limited.",
                  whyItMatters: "Seeing weak runes helps explain that networks compare many possibilities at once.")
        ],
        [
            .init(id: "l3n0", layerIndex: 3, nodeIndex: 0, label: "ŷ₁", title: "Output Sigil A",
                  kind: .output, activation: 0.68,
                  role: "Class 1 confidence - the network's answer.",
                  incoming: "Receives strongest energy from H5 and H7",
                  meaning: "This sigil wins because strong hidden evidence flowed into it across the network.",
                  whyItMatters: "The output layer summarizes all the evidence gathered by earlier runes."),
            .init(id: "l3n1", layerIndex: 3, nodeIndex: 1, label: "ŷ₂", title: "Output Sigil B",
                  kind: .output, activation: 0.32,
                  role: "Class 2 confidence - rejected.",
                  incoming: "Receives weaker competing evidence",
                  meaning: "This sigil stays lower because the evidence in its favor is weaker.",
                  whyItMatters: "Seeing the losing output makes prediction feel like a comparison, not a magical yes-or-no.")
        ]
    ]

    private var selectedNode: ForwardNodeSnapshot? {
        nodeData.flatMap { $0 }.first(where: { $0.id == selectedNodeID })
    }

    private var buttonTitle: String {
        if isCasting { return "◈ Casting..." }
        if didCast   { return "◈ Cast Again" }
        return "◈ Cast Prediction"
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── FULL-SCREEN NETWORK CANVAS ─────────────────────────────────
            ForwardNetworkCanvasView(
                selectedNodeID: $selectedNodeID,
                nodeData: nodeData,
                castStartTime: castStartTime,
                didCast: didCast,
                isCasting: isCasting
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom gradient vignette for legibility
            LinearGradient(
                colors: [.clear, Color(red: 0.015, green: 0.008, blue: 0.06).opacity(0.97)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 330)
            .allowsHitTesting(false)

            // ── BOTTOM PANEL ───────────────────────────────────────────────
            VStack(spacing: 12) {

                // Dynamic status / info area
                Group {
                    if isCasting {
                        Text(currentCastBeat)
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.84))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .transition(.opacity.combined(with: .scale(scale: 0.97)))

                    } else if let node = selectedNode {
                        ForwardNodeCompactCard(node: node)
                            .transition(.move(edge: .bottom).combined(with: .opacity))

                    } else if !didCast {
                        VStack(spacing: 6) {
                            Text("Press the button below to send a signal through the network")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.90))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            Text("Watch the rays travel left → right, layer by layer")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.65))
                                .multilineTextAlignment(.center)
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: selectedNodeID)
                .animation(.easeInOut(duration: 0.35), value: isCasting)
                .animation(.easeInOut(duration: 0.35), value: didCast)

                if didCast && !isCasting && selectedNodeID == nil {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29))
                        Text("TAP ANY NODE TO INSPECT IT")
                            .font(.custom("AvenirNext-DemiBold", size: 12))
                            .tracking(2.5)
                            .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29))
                    }
                    .transition(.opacity)
                }

                // Main buttons
                HStack(spacing: 10) {
                    SpellButton(title: "✦ Deep Dive", tone: .gold) { onOpenModal(.forward) }
                    SpellButton(title: buttonTitle, tone: .mana,
                                isPulsing: !didCast && !isCasting) { castPrediction() }
                }

                if didCast && !isCasting {
                    VStack(spacing: 3) {
                        Text("Prediction recorded: ŷ₁ = 0.68   ·   Truth = 1.0")
                            .font(.custom("AvenirNext-DemiBold", size: 11))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.32))
                        Text("Loss from this pass → measured in Chapter II")
                            .font(.system(size: 12, weight: .light, design: .serif))
                            .italic()
                            .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.55))
                    }
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
                }

                if didCast {
                    SpellButton(title: "Proceed to Chapter II →", tone: .spirit, isPulsing: true) {
                        onNext()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 90)
            .animation(.spring(response: 0.44, dampingFraction: 0.84), value: selectedNodeID)
            .animation(.easeInOut(duration: 0.35), value: didCast)

            // ── FLOATING CHAPTER CHIP ──────────────────────────────────────
            VStack {
                HStack {
                    Text("CHAPTER I · FORWARD PASS")
                        .font(.custom("AvenirNext-DemiBold", size: 9.5))
                        .tracking(3.5)
                        .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.38))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                Spacer()
            }
            .allowsHitTesting(false)
        }
    }

    // MARK: - Logic

    private var currentCastBeat: String {
        let t = castStartTime.map { min(1.0, Date().timeIntervalSince($0) / 2.0) } ?? 0
        switch t {
        case ..<0.18: return "The spell wakes the input glyphs first — raw signals from the world."
        case ..<0.48: return "Hidden runes absorb and transform simple inputs into patterns."
        case ..<0.78: return "Deeper runes fuse those patterns into richer, layered evidence."
        default:      return "The output sigils compare the final evidence and reveal the prediction."
        }
    }

    private func castPrediction() {
        guard !isCasting else { return }
        let token = UUID()
        castToken = token
        selectedNodeID = nil
        didCast = false
        isCasting = true
        castStartTime = Date()

        Task {
            try? await Task.sleep(nanoseconds: reduceMotion ? 220_000_000 : 2_050_000_000)
            guard token == castToken else { return }
            await MainActor.run {
                isCasting = false
                didCast = true
            }
        }
    }
}

// MARK: - Compact node card

private struct ForwardNodeCompactCard: View {
    let node: ForwardNodeSnapshot

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(node.kind.badgeTitle.uppercased())
                        .font(.custom("AvenirNext-DemiBold", size: 10))
                        .tracking(1.5)
                        .foregroundStyle(node.kind.tint.opacity(0.90))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(node.kind.tint.opacity(0.16), in: Capsule())
                    Text(node.label)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(node.kind.tint)
                    Text("·")
                        .foregroundStyle(.white.opacity(0.30))
                    Text(node.title)
                        .font(.custom("AvenirNext-DemiBold", size: 13))
                        .foregroundStyle(.white.opacity(0.78))
                }
                Text(node.meaning)
                    .font(.custom("AvenirNext-Regular", size: 14))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineSpacing(3)
                    .lineLimit(3)
                Text(node.whyItMatters)
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .foregroundStyle(.white.opacity(0.40))
                    .lineSpacing(2)
                    .lineLimit(2)
            }
            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "%.2f", node.activation))
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .foregroundStyle(node.kind.tint)
                Text("activation")
                    .font(.custom("AvenirNext-DemiBold", size: 9))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.32))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color(red: 0.04, green: 0.02, blue: 0.12).opacity(0.97),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(node.kind.tint.opacity(0.32), lineWidth: 1)
        )
    }
}

// MARK: - Full-screen network canvas

private struct ForwardNetworkCanvasView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var selectedNodeID: String?
    let nodeData: [[ForwardNodeSnapshot]]
    let castStartTime: Date?
    let didCast: Bool
    let isCasting: Bool

    private func liveCastProgress(at date: Date) -> Double {
        guard isCasting, let start = castStartTime else {
            return didCast ? 1.0 : 0.0
        }
        let t = min(1.0, max(0, date.timeIntervalSince(start) / 2.0))
        return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }

    var body: some View {
        GeometryReader { proxy in
            let layout = ForwardNetworkLayout(size: proxy.size, nodeData: nodeData)

            ZStack {
                // Canvas: transparent so cosmic background shows through
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    Canvas { context, _ in
                        let cp = liveCastProgress(at: timeline.date)
                        drawGlow(context: &context, size: proxy.size)
                        drawEdges(context: &context, layout: layout,
                                  timeline: timeline.date.timeIntervalSinceReferenceDate,
                                  castProgress: cp)
                        drawNodes(context: &context, layout: layout,
                                  timeline: timeline.date.timeIntervalSinceReferenceDate,
                                  castProgress: cp)
                        drawLayerLabels(context: &context, layout: layout)
                    }
                }

                // Invisible tap targets over each node
                ForEach(layout.nodes) { node in
                    Button {
                        withAnimation(.spring(response: 0.30, dampingFraction: 0.82)) {
                            selectedNodeID = (node.id == selectedNodeID) ? nil : node.id
                        }
                    } label: {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 56, height: 56)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .position(node.point)
                    .accessibilityLabel("Inspect \(node.title)")
                }
            }
        }
    }

    // MARK: Glow — ambient halos per layer

    private func drawGlow(context: inout GraphicsContext, size: CGSize) {
        let cx = size.width / 2
        let cy = size.height / 2

        // Central mana halo
        context.fill(
            Path(ellipseIn: CGRect(x: cx - size.width * 0.44,
                                   y: cy - size.height * 0.36,
                                   width: size.width * 0.88,
                                   height: size.height * 0.72)),
            with: .radialGradient(
                Gradient(colors: [Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.18), .clear]),
                center: CGPoint(x: cx, y: cy),
                startRadius: 0,
                endRadius: size.width * 0.42
            )
        )

        // Input layer — golden warmth
        let ix = size.width * 0.13
        context.fill(
            Path(ellipseIn: CGRect(x: ix - size.height * 0.26, y: cy - size.height * 0.30,
                                   width: size.height * 0.52, height: size.height * 0.60)),
            with: .radialGradient(
                Gradient(colors: [Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.10), .clear]),
                center: CGPoint(x: ix, y: cy),
                startRadius: 0, endRadius: size.height * 0.30
            )
        )

        // Output layer — spirit cyan glow
        let ox = size.width * 0.91
        context.fill(
            Path(ellipseIn: CGRect(x: ox - size.height * 0.25, y: cy - size.height * 0.26,
                                   width: size.height * 0.50, height: size.height * 0.52)),
            with: .radialGradient(
                Gradient(colors: [Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.09), .clear]),
                center: CGPoint(x: ox, y: cy),
                startRadius: 0, endRadius: size.height * 0.26
            )
        )
    }

    // MARK: Edges — progressive ray extension with tip spark

    private func drawEdges(context: inout GraphicsContext, layout: ForwardNetworkLayout, timeline: TimeInterval, castProgress: Double) {
        let hasSelection = selectedNodeID != nil

        for edge in layout.edges {
            let path = bezierPath(from: edge.from.point, to: edge.to.point)
            let highlighted = isHighlighted(edge: edge)
            let active = edgeEnergy(for: edge, castProgress: castProgress)

            let fromColor = highlighted
                ? Color(red: 0.91, green: 0.72, blue: 0.29)
                : Color(red: 0.36, green: 0.19, blue: 1.0)
            let toColor   = Color(red: 0.24, green: 0.84, blue: 0.75)
            let glowBase  = highlighted
                ? Color(red: 0.91, green: 0.72, blue: 0.29)
                : Color(red: 0.49, green: 0.38, blue: 1.0)

            // ── Always show dim skeleton so the network is readable ────────
            context.stroke(path,
                           with: .color(glowBase.opacity(hasSelection ? (highlighted ? 0.22 : 0.02) : 0.05)),
                           style: StrokeStyle(lineWidth: 1.0, lineCap: .round))

            guard active > 0.005 || highlighted else { continue }

            // ── Determine drawn path ───────────────────────────────────────
            // During animation: trim from source node, extend progressively toward dest.
            // After cast: draw full edge at settled opacity.
            let rayProgress = isCasting ? active : 1.0
            let drawnPath   = (isCasting && active < 0.995)
                ? path.trimmedPath(from: 0, to: rayProgress)
                : path

            // ── LAYER 1: Outer bloom ───────────────────────────────────────
            let glowOp: Double
            if highlighted       { glowOp = 0.30 }
            else if hasSelection { glowOp = 0.0  }
            else                 { glowOp = 0.05 + active * 0.16 }

            if glowOp > 0.005 {
                context.stroke(drawnPath,
                               with: .color(glowBase.opacity(glowOp)),
                               style: StrokeStyle(lineWidth: 9, lineCap: .round))
            }

            // ── LAYER 2: Mid gradient ──────────────────────────────────────
            let midOp: Double
            if highlighted       { midOp = 0.88 }
            else if hasSelection { midOp = 0.04 }
            else                 { midOp = 0.28 + active * 0.52 }

            context.stroke(
                drawnPath,
                with: .linearGradient(
                    Gradient(colors: [fromColor.opacity(midOp), toColor.opacity(midOp * 0.72)]),
                    startPoint: edge.from.point, endPoint: edge.to.point
                ),
                style: StrokeStyle(lineWidth: highlighted ? 3.2 : CGFloat(1.6 + active * 2.0), lineCap: .round)
            )

            // ── LAYER 3: Bright core ───────────────────────────────────────
            let coreOp: Double
            if highlighted       { coreOp = 0.95 }
            else if hasSelection { coreOp = 0.02 }
            else                 { coreOp = 0.20 + active * 0.48 }

            if coreOp > 0.02 {
                context.stroke(drawnPath,
                               with: .color(fromColor.opacity(coreOp * 0.75)),
                               style: StrokeStyle(lineWidth: 0.75, lineCap: .round))
            }

            // ── Tip spark — travels along the wire during cast ─────────────
            if isCasting && active > 0.01 && active < 0.99 {
                let tip     = point(on: edge, at: active)
                let flicker = CGFloat(0.72 + 0.28 * sin(timeline * 14.0 + Double(edge.from.nodeIndex) * 0.9))
                let sparkR  = 5.5 * flicker

                // Bright inner core
                context.fill(
                    Path(ellipseIn: CGRect(x: tip.x - sparkR, y: tip.y - sparkR,
                                          width: sparkR * 2, height: sparkR * 2)),
                    with: .radialGradient(
                        Gradient(colors: [Color.white.opacity(0.96), fromColor.opacity(0.75), .clear]),
                        center: tip, startRadius: 0, endRadius: sparkR
                    )
                )
                // Outer halo
                context.fill(
                    Path(ellipseIn: CGRect(x: tip.x - sparkR * 2.8, y: tip.y - sparkR * 2.8,
                                          width: sparkR * 5.6, height: sparkR * 5.6)),
                    with: .radialGradient(
                        Gradient(colors: [fromColor.opacity(0.44 * flicker), .clear]),
                        center: tip, startRadius: 0, endRadius: sparkR * 2.8
                    )
                )
            }

            // ── Shimmer ripple (settled or fully lit) ──────────────────────
            guard (active > 0.5 && !hasSelection) || highlighted else { continue }
            let shimmer = 0.15 + 0.15 * sin(timeline * 2.4 + Double(edge.to.layerIndex) * 1.1)
            context.stroke(
                drawnPath,
                with: .linearGradient(
                    Gradient(colors: [
                        (highlighted ? Color(red: 0.91, green: 0.72, blue: 0.29)
                                     : Color(red: 0.24, green: 0.84, blue: 0.75)).opacity(shimmer),
                        Color.clear
                    ]),
                    startPoint: edge.from.point, endPoint: edge.to.point
                ),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
        }
    }

    // MARK: Nodes

    private func drawNodes(context: inout GraphicsContext, layout: ForwardNetworkLayout, timeline: TimeInterval, castProgress: Double) {
        for node in layout.nodes {
            let highlighted = selectedNodeID == node.id
            let reveal  = nodeReveal(for: node, castProgress: castProgress)
            let pulse   = nodePulse(for: node, timeline: timeline, castProgress: castProgress)
            let radius  = 10.0 + reveal * 6.0 + pulse * 2.2 + (highlighted ? 3.5 : 0)
            let tint    = highlighted ? Color(red: 0.91, green: 0.72, blue: 0.29) : node.kind.tint

            // Large halo
            let hR = radius * 3.2
            context.fill(
                Path(ellipseIn: CGRect(x: node.point.x - hR, y: node.point.y - hR, width: hR * 2, height: hR * 2)),
                with: .radialGradient(
                    Gradient(colors: [tint.opacity(highlighted ? 0.36 : 0.16 + reveal * 0.16), .clear]),
                    center: node.point, startRadius: 0, endRadius: hR
                )
            )

            // Node fill
            let rect = CGRect(x: node.point.x - radius, y: node.point.y - radius, width: radius * 2, height: radius * 2)
            context.fill(
                Path(ellipseIn: rect),
                with: .radialGradient(
                    Gradient(colors: [tint.opacity(0.96), Color(red: 0.08, green: 0.04, blue: 0.20).opacity(0.98)]),
                    center: CGPoint(x: node.point.x - 2, y: node.point.y - 2),
                    startRadius: 1, endRadius: radius
                )
            )
            // Node border
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(highlighted ? Color.white.opacity(0.94) : tint.opacity(0.76)),
                lineWidth: highlighted ? 2.2 : 1.1
            )

            // Selected ring
            if highlighted {
                let focusRect = rect.insetBy(dx: -6, dy: -6)
                context.stroke(
                    Path(ellipseIn: focusRect),
                    with: .color(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.60)),
                    style: StrokeStyle(lineWidth: 1.2, dash: [4, 3])
                )
            }

            // Post-cast invite pulse: slow breathing ring to invite taps
            if didCast && !isCasting && !highlighted {
                let invitePulse = 0.30 + 0.22 * CGFloat(sin(timeline * 1.6 + Double(node.nodeIndex) * 0.7 + Double(node.layerIndex) * 1.3))
                let inviteR = radius + 8 + 4 * CGFloat(sin(timeline * 1.6 + Double(node.nodeIndex) * 0.7))
                context.stroke(
                    Path(ellipseIn: CGRect(x: node.point.x - inviteR, y: node.point.y - inviteR, width: inviteR * 2, height: inviteR * 2)),
                    with: .color(tint.opacity(invitePulse)),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [3, 4])
                )
            }

            // Label
            let labelY: CGFloat = node.kind == .input
                ? node.point.y - radius - 12
                : node.point.y + radius + 14
            let labelColor: Color = node.kind == .output
                ? Color(red: 0.24, green: 0.84, blue: 0.75)
                : Color(red: 0.91, green: 0.72, blue: 0.29)
            context.draw(
                Text(node.label)
                    .font(.custom("AvenirNext-DemiBold", size: 14))
                    .foregroundStyle(labelColor.opacity(highlighted ? 1.0 : 0.84)),
                at: CGPoint(x: node.point.x, y: labelY)
            )

            // Activation value (post-cast)
            if didCast || isCasting {
                context.draw(
                    Text(String(format: "%.2f", node.activation))
                        .font(.custom("AvenirNext-DemiBold", size: 12))
                        .foregroundStyle(tint.opacity(0.95)),
                    at: CGPoint(x: node.point.x, y: node.point.y)
                )
            }
        }
    }

    // MARK: Layer labels

    private func drawLayerLabels(context: inout GraphicsContext, layout: ForwardNetworkLayout) {
        let labels = ["INPUT", "HIDDEN", "HIDDEN", "OUTPUT"]
        for (index, label) in labels.enumerated() {
            context.draw(
                Text(label)
                    .font(.custom("AvenirNext-DemiBold", size: 11))
                    .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.36)),
                at: layout.layerAnchors[index]
            )
        }
    }

    // MARK: Helpers

    private func bezierPath(from start: CGPoint, to end: CGPoint) -> Path {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }

    private func point(on edge: ForwardEdge, at t: Double) -> CGPoint {
        CGPoint(
            x: edge.from.point.x + (edge.to.point.x - edge.from.point.x) * CGFloat(t),
            y: edge.from.point.y + (edge.to.point.y - edge.from.point.y) * CGFloat(t)
        )
    }

    private func nodeReveal(for node: ForwardRenderNode, castProgress: Double) -> CGFloat {
        if didCast && !isCasting { return CGFloat(node.activation) }
        let window = layerWindow(for: node.layerIndex)
        let progress = max(0, min(1, (castProgress - window.start) / window.length))
        return CGFloat(node.activation) * progress
    }

    private func nodePulse(for node: ForwardRenderNode, timeline: TimeInterval, castProgress: Double) -> CGFloat {
        let window = layerWindow(for: node.layerIndex)
        let local  = max(0, min(1, (castProgress - window.start) / window.length))
        let burst   = CGFloat(sin(local * .pi))
        let settled = didCast && !isCasting
            ? CGFloat(0.14 + 0.06 * sin(timeline * 2.4 + Double(node.nodeIndex)))
            : 0
        return max(burst, settled)
    }

    private func edgeEnergy(for edge: ForwardEdge, castProgress: Double) -> Double {
        if didCast && !isCasting { return 0.58 + edge.to.activation * 0.24 }
        let window = layerWindow(for: edge.to.layerIndex)
        guard castProgress > window.start else { return 0 }
        return min(1, max(0, (castProgress - window.start) / window.length))
    }

    private func layerWindow(for layerIndex: Int) -> (start: Double, length: Double) {
        switch layerIndex {
        case 0:  return (0.02, 0.16)
        case 1:  return (0.18, 0.24)
        case 2:  return (0.44, 0.24)
        default: return (0.72, 0.20)
        }
    }

    private func isHighlighted(edge: ForwardEdge) -> Bool {
        guard let selectedNodeID else { return false }
        return edge.from.id == selectedNodeID || edge.to.id == selectedNodeID
    }
}

// MARK: - Layout

private struct ForwardNetworkLayout {
    let nodes: [ForwardRenderNode]
    let edges: [ForwardEdge]
    let layerAnchors: [CGPoint]

    init(size: CGSize, nodeData: [[ForwardNodeSnapshot]]) {
        let xPositions: [CGFloat] = [0.13, 0.39, 0.70, 0.91].map { size.width * $0 }
        let spacing: [CGFloat] = [58, 50, 50, 62]

        var builtNodes: [ForwardRenderNode] = []
        var anchors: [CGPoint] = []

        for layerIndex in 0..<nodeData.count {
            let layer = nodeData[layerIndex]
            let count = layer.count
            // Place label just above the topmost node of this layer
            let topNodeY = size.height * 0.46 - CGFloat(count - 1) / 2.0 * spacing[layerIndex]
            anchors.append(CGPoint(x: xPositions[layerIndex], y: topNodeY - 44))
            for nodeIndex in 0..<count {
                let y = size.height * 0.46 + (CGFloat(nodeIndex) - CGFloat(count - 1) / 2) * spacing[layerIndex]
                let snapshot = layer[nodeIndex]
                builtNodes.append(ForwardRenderNode(
                    id: snapshot.id,
                    layerIndex: snapshot.layerIndex,
                    nodeIndex: snapshot.nodeIndex,
                    title: snapshot.title,
                    label: snapshot.label,
                    kind: snapshot.kind,
                    activation: snapshot.activation,
                    point: CGPoint(x: xPositions[layerIndex], y: y)
                ))
            }
        }

        nodes = builtNodes
        layerAnchors = anchors

        var builtEdges: [ForwardEdge] = []
        for layerIndex in 0..<(nodeData.count - 1) {
            let fromNodes = builtNodes.filter { $0.layerIndex == layerIndex }
            let toNodes   = builtNodes.filter { $0.layerIndex == layerIndex + 1 }
            for from in fromNodes {
                for to in toNodes {
                    builtEdges.append(ForwardEdge(from: from, to: to))
                }
            }
        }
        edges = builtEdges
    }
}

private struct ForwardRenderNode: Identifiable, Equatable {
    let id: String
    let layerIndex: Int
    let nodeIndex: Int
    let title: String
    let label: String
    let kind: ForwardNodeKind
    let activation: Double
    let point: CGPoint
}

private struct ForwardEdge: Equatable {
    let from: ForwardRenderNode
    let to: ForwardRenderNode
}
