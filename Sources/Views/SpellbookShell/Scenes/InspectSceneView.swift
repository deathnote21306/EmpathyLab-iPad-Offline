import SwiftUI

private struct InspectRune: Identifiable, Equatable {
    let id: String
    let glyph: String
    let name: String
    let layer: String
    let nodeID: String        // math notation: x₁, h₁, ŷ₁
    let activation: Double
    let forwardRole: String   // what this node did during the forward pass
    let description: String
    let weights: String
    let gradient: String
    let math: String
}

struct InspectSceneView: View {
    let onNext: () -> Void
    @Binding var mathReveal: Bool

    @State private var selectedRuneID: String?

    private let inputRunes: [InspectRune] = [
        .init(id: "alpha", glyph: "◈", name: "Alpha", layer: "Input", nodeID: "x₁",
              activation: 0.92,
              forwardRole: "Received raw signal x₁ = 0.80. Fed into all 4 hidden nodes via 4 weighted connections — its high value dominated the first layer.",
              description: "Strongly activated. At 92% capacity, this rune drove the information flow into the hidden layer.",
              weights: "4 out", gradient: "0.007",
              math: "a = σ(W·x + b)\n= σ(0.80×0.50 + 0.10)\n= σ(0.50) = 0.92\n\nGradient 0.007 — least blame (furthest from output)."),
        .init(id: "beta", glyph: "⬡", name: "Beta", layer: "Input", nodeID: "x₂",
              activation: 0.41,
              forwardRole: "Received x₂ = 0.30. Its negative weight (−0.30) pulled some hidden activations down, opposing x₁.",
              description: "Partially active. A moderate input with a negative weight — this rune subtly suppressed a hidden layer pattern.",
              weights: "4 out", gradient: "0.024",
              math: "a = σ(W·x + b)\n= σ(0.30×(−0.30) + 0.05)\n= σ(−0.04) = 0.41\n\nGradient 0.024 — negative weight pulled prediction down."),
        .init(id: "gamma", glyph: "⊕", name: "Gamma", layer: "Input", nodeID: "x₃",
              activation: 0.67,
              forwardRole: "Received x₃ = 0.60. Combined with x₁, it triggered the key hidden pattern that led to the final prediction.",
              description: "Moderately active. Co-activated with Alpha to unlock a critical hidden feature.",
              weights: "4 out", gradient: "0.015",
              math: "a = σ(W·x + b)\n= σ(0.60×0.80 + 0.00)\n= σ(0.48) = 0.67\n\nGradient 0.015 — moderate blame.")
    ]

    private let hiddenRunes: [InspectRune] = [
        .init(id: "delta", glyph: "✦", name: "Delta", layer: "Hidden I", nodeID: "h₁",
              activation: 0.83,
              forwardRole: "Weighted x₁, x₂, x₃ together. Fired strongly when x₁ and x₃ were both high — it learned to detect this co-occurrence pattern.",
              description: "Highly active. This rune learned a specific conjunction of inputs and is the dominant contributor to the output.",
              weights: "3 in · 2 out", gradient: "0.011",
              math: "a = ReLU(Σ W·x + b)\n= ReLU(0.92×0.6 + 0.41×0.2 + 0.67×0.8 − 0.3)\n= ReLU(0.76) = 0.83"),
        .init(id: "epsilon", glyph: "◉", name: "Epsilon", layer: "Hidden I", nodeID: "h₂",
              activation: 0.28,
              forwardRole: "Mostly dormant for these inputs. Specializes in patterns not present here — passed only a weak signal forward.",
              description: "Near-dormant. A near-zero activation means its pattern wasn't triggered — yet it absorbed the most blame during backprop.",
              weights: "3 in · 2 out", gradient: "0.031",
              math: "a = ReLU(Σ W·x + b)\n= ReLU(0.13) = 0.28\n\nHighest gradient 0.031 — most blame, needs most correction."),
        .init(id: "zeta", glyph: "⟁", name: "Zeta", layer: "Hidden I", nodeID: "h₃",
              activation: 0.74,
              forwardRole: "Detected a curved feature mix. Contributed 74% signal to the output layer — the second-strongest hidden influence.",
              description: "Well activated. Responds to a combination of mid-range inputs and contributes meaningfully.",
              weights: "3 in · 2 out", gradient: "0.023",
              math: "a = ReLU(Σ W·x + b)\n= ReLU(0.62) = 0.74\n\nGradient 0.023 means a noticeable correction was applied."),
        .init(id: "eta", glyph: "⊗", name: "Eta", layer: "Hidden I", nodeID: "h₄",
              activation: 0.55,
              forwardRole: "Acted as a gate. Selectively forwarded roughly half its input signal, filtering information rather than amplifying it.",
              description: "Gating signal. Balances the output by half-activating — neither amplifying nor suppressing.",
              weights: "3 in · 2 out", gradient: "0.018",
              math: "a = ReLU(Σ W·x + b)\n= ReLU(0.42) = 0.55")
    ]

    private let outputRunes: [InspectRune] = [
        .init(id: "theta", glyph: "◬", name: "Theta", layer: "Output", nodeID: "ŷ₁",
              activation: 0.91,
              forwardRole: "Collected weighted signals from all 4 hidden nodes. Produced the final prediction ŷ₁ = 0.91, which was compared to the truth label to compute loss.",
              description: "Primary output sigil. 91% activation is the network's final answer — directly compared to truth 1.0.",
              weights: "4 in", gradient: "0.005",
              math: "a = σ(Σ W·h + b)\n= σ(1.30) = 0.91\n\nLoss = (1.0 − 0.91)² = 0.0081\nGradient 0.005 — small correction from output."),
        .init(id: "iota", glyph: "⬟", name: "Iota", layer: "Output", nodeID: "ŷ₂",
              activation: 0.09,
              forwardRole: "Alternative class output. The network rejected class 2 at 9%. Theta and Iota together form a probability distribution — one must dominate.",
              description: "Alternative sigil. At 9%, the network firmly rejected class 2. Together with Theta they sum to ≈ 1.00.",
              weights: "4 in", gradient: "0.005",
              math: "a = σ(Σ W·h + b)\n≈ 1 − 0.91 = 0.09\n\nTheta and Iota are inverse — a softmax-like distribution.")
    ]

    private var allRunes: [InspectRune] { inputRunes + hiddenRunes + outputRunes }

    private var selectedRune: InspectRune? {
        allRunes.first(where: { $0.id == selectedRuneID })
    }

    // Colors per layer
    private let goldC   = Color(red: 0.91, green: 0.72, blue: 0.29)
    private let manaC   = Color(red: 0.49, green: 0.38, blue: 1.00)
    private let spiritC = Color(red: 0.24, green: 0.84, blue: 0.75)

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {

                // Ambient glow
                InspectAmbientView(selectedRune: selectedRune)

                VStack(spacing: 0) {

                    // ── HEADER ────────────────────────────────────────────────
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CHAPTER V")
                                .font(.custom("AvenirNext-DemiBold", size: 9.5))
                                .tracking(3.5)
                                .foregroundStyle(Color(red: 0.56, green: 0.43, blue: 0.16))
                            Text("Pause & Inspect")
                                .font(.system(size: 22, weight: .bold, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [goldC, Color(red: 0.86, green: 0.85, blue: 1.0)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                        }
                        Spacer()
                        Toggle("Math", isOn: $mathReveal)
                            .toggleStyle(.switch)
                            .font(.custom("AvenirNext-DemiBold", size: 11))
                            .foregroundStyle(.white.opacity(0.72))
                            .frame(width: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                    // ── INVITE / SELECTION HEADER ─────────────────────────────
                    VStack(spacing: 5) {
                        Text(selectedRune == nil
                             ? "Tap any neuron to see what it learned and how it contributed"
                             : "✦  \(selectedRune!.nodeID)  ·  \(selectedRune!.name.uppercased())  ·  \(selectedRune!.layer.uppercased())  ✦")
                            .font(selectedRune == nil
                                  ? .system(size: 14, weight: .regular, design: .serif)
                                  : .custom("AvenirNext-DemiBold", size: 11))
                            .tracking(selectedRune == nil ? 0 : 2.5)
                            .foregroundStyle(goldC.opacity(selectedRune == nil ? 0.55 : 0.70))
                            .multilineTextAlignment(.center)
                            .animation(.easeInOut(duration: 0.25), value: selectedRuneID)

                        if selectedRune == nil {
                            Text("Activation = how strongly a neuron fired · 0.00 = silent · 1.00 = full power")
                                .font(.custom("AvenirNext-DemiBold", size: 10))
                                .tracking(0.5)
                                .foregroundStyle(.white.opacity(0.28))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    .animation(.easeInOut(duration: 0.25), value: selectedRuneID)

                    // ── LAYERED RUNE GRID ──────────────────────────────────────
                    let isWide = geo.size.width > 620
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {

                            // Input layer
                            InspectLayerHeader(
                                title: "Input Layer", nodeIDs: "x₁ · x₂ · x₃",
                                description: "Raw inputs to the network",
                                color: goldC
                            )
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                                spacing: 10
                            ) {
                                ForEach(inputRunes) { rune in
                                    runeButton(rune)
                                }
                            }

                            // Hidden layer
                            InspectLayerHeader(
                                title: "Hidden Layer", nodeIDs: "h₁ · h₂ · h₃ · h₄",
                                description: "Learned internal features",
                                color: manaC
                            )
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10),
                                               count: isWide ? 4 : 2),
                                spacing: 10
                            ) {
                                ForEach(hiddenRunes) { rune in
                                    runeButton(rune)
                                }
                            }

                            // Output layer
                            InspectLayerHeader(
                                title: "Output Layer", nodeIDs: "ŷ₁ · ŷ₂",
                                description: "Final class predictions",
                                color: spiritC
                            )
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                                spacing: 10
                            ) {
                                ForEach(outputRunes) { rune in
                                    runeButton(rune)
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                    }

                    Spacer(minLength: 0)

                    // ── BOTTOM CONTROLS ───────────────────────────────────────
                    HStack(spacing: 10) {
                        SpellButton(title: "Final Evolution →", tone: .spirit, isPulsing: true) { onNext() }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, selectedRune != nil ? 4 : 90)
                }

                // ── SLIDING DETAIL PANEL ───────────────────────────────────────
                if let rune = selectedRune {
                    InspectDetailPanel(rune: rune, mathReveal: mathReveal) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            selectedRuneID = nil
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(2)
                }
            }
            .animation(.spring(response: 0.42, dampingFraction: 0.84), value: selectedRuneID)
        }
    }

    @ViewBuilder
    private func runeButton(_ rune: InspectRune) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                selectedRuneID = rune.id == selectedRuneID ? nil : rune.id
            }
        } label: {
            InspectRuneCard(rune: rune, isSelected: rune.id == selectedRuneID)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Layer section header

private struct InspectLayerHeader: View {
    let title: String
    let nodeIDs: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(color)
                .frame(width: 3, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.custom("AvenirNext-DemiBold", size: 10))
                    .tracking(2.5)
                    .foregroundStyle(color.opacity(0.90))
                Text(nodeIDs + "  ·  " + description)
                    .font(.system(size: 12, weight: .light, design: .serif))
                    .italic()
                    .foregroundStyle(.white.opacity(0.36))
            }

            Spacer()
        }
        .padding(.top, 4)
    }
}

// MARK: - Rune card

private struct InspectRuneCard: View {
    let rune: InspectRune
    let isSelected: Bool

    private var runeColor: Color {
        if rune.layer == "Output"   { return Color(red: 0.24, green: 0.84, blue: 0.75) }
        if rune.layer.hasPrefix("Hidden") { return Color(red: 0.49, green: 0.38, blue: 1.0) }
        return Color(red: 0.91, green: 0.72, blue: 0.29)
    }

    var body: some View {
        VStack(spacing: 5) {
            // NodeID badge
            Text(rune.nodeID)
                .font(.system(size: 12, weight: .medium, design: .serif))
                .italic()
                .foregroundStyle(runeColor.opacity(isSelected ? 0.95 : 0.55))

            Text(rune.glyph)
                .font(.system(size: 28))
                .shadow(color: runeColor.opacity(isSelected ? 0.80 : 0.30), radius: isSelected ? 14 : 6)

            Text(String(format: "%.2f", rune.activation))
                .font(.custom("AvenirNext-Bold", size: 16))
                .foregroundStyle(runeColor)

            Text(rune.name)
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundStyle(.white.opacity(0.85))

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.06))
                    Capsule()
                        .fill(LinearGradient(
                            colors: [runeColor.opacity(0.85), runeColor.opacity(0.35)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: g.size.width * CGFloat(rune.activation))
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 6)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    runeColor.opacity(isSelected ? 0.18 : 0.08),
                    Color(red: 0.04, green: 0.02, blue: 0.10).opacity(0.96)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? runeColor : runeColor.opacity(0.22),
                        lineWidth: isSelected ? 1.5 : 1)
        )
        .shadow(color: isSelected ? runeColor.opacity(0.30) : .clear, radius: 16, y: 6)
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.80), value: isSelected)
    }
}

// MARK: - Inspect ambient

private struct InspectAmbientView: View {
    let selectedRune: InspectRune?

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let pulse = CGFloat(0.78 + 0.22 * sin(t * 0.60))
                let layerColor: Color = {
                    guard let r = selectedRune else { return Color(red: 0.49, green: 0.38, blue: 1.0) }
                    if r.layer == "Output"          { return Color(red: 0.24, green: 0.84, blue: 0.75) }
                    if r.layer.hasPrefix("Hidden")  { return Color(red: 0.49, green: 0.38, blue: 1.0) }
                    return Color(red: 0.91, green: 0.72, blue: 0.29)
                }()

                ctx.fill(
                    Path(ellipseIn: CGRect(x: -size.width * 0.10, y: size.height * 0.25,
                                           width: size.width * 0.65, height: size.height * 0.70)),
                    with: .radialGradient(
                        Gradient(colors: [layerColor.opacity(0.08 * pulse), .clear]),
                        center: CGPoint(x: size.width * 0.10, y: size.height * 0.65),
                        startRadius: 0, endRadius: size.width * 0.42
                    )
                )
                ctx.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.50, y: -size.height * 0.08,
                                           width: size.width * 0.60, height: size.height * 0.45)),
                    with: .radialGradient(
                        Gradient(colors: [Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.06 * pulse), .clear]),
                        center: CGPoint(x: size.width * 0.88, y: 0),
                        startRadius: 0, endRadius: size.width * 0.34
                    )
                )
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Sliding detail panel

private struct InspectDetailPanel: View {
    let rune: InspectRune
    let mathReveal: Bool
    let onDismiss: () -> Void

    private var runeColor: Color {
        if rune.layer == "Output"          { return Color(red: 0.24, green: 0.84, blue: 0.75) }
        if rune.layer.hasPrefix("Hidden")  { return Color(red: 0.49, green: 0.38, blue: 1.0) }
        return Color(red: 0.91, green: 0.72, blue: 0.29)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(.white.opacity(0.20))
                .frame(width: 40, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .onTapGesture { onDismiss() }

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // ── Context strip ─────────────────────────────────────────
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(runeColor.opacity(0.60))
                        Text("You are looking at one neuron inside the network — its firing strength, its role, and its share of the prediction error.")
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.50))
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.04),
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    // ── Hero row ──────────────────────────────────────────────
                    HStack(alignment: .center, spacing: 16) {
                        ZStack(alignment: .topTrailing) {
                            Text(rune.glyph)
                                .font(.system(size: 52))
                                .shadow(color: runeColor.opacity(0.70), radius: 18)
                            Text(rune.nodeID)
                                .font(.system(size: 13, weight: .medium, design: .serif))
                                .italic()
                                .foregroundStyle(runeColor)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(runeColor.opacity(0.14),
                                            in: Capsule(style: .continuous))
                                .offset(x: 14, y: -10)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(rune.name)
                                .font(.system(size: 26, weight: .bold, design: .serif))
                                .foregroundStyle(.white)
                            Text(rune.layer.uppercased())
                                .font(.custom("AvenirNext-DemiBold", size: 11))
                                .tracking(2)
                                .foregroundStyle(.white.opacity(0.44))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(String(format: "%.2f", rune.activation))
                                .font(.system(size: 38, weight: .bold, design: .monospaced))
                                .foregroundStyle(runeColor)
                            Text("ACTIVATION")
                                .font(.custom("AvenirNext-DemiBold", size: 9))
                                .tracking(1.5)
                                .foregroundStyle(.white.opacity(0.30))
                            Text("0 = off · 1 = full")
                                .font(.custom("AvenirNext-Regular", size: 9))
                                .foregroundStyle(runeColor.opacity(0.45))
                        }
                    }

                    // Activation bar with end labels
                    VStack(spacing: 4) {
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(.white.opacity(0.06))
                                Capsule()
                                    .fill(LinearGradient(
                                        colors: [runeColor, runeColor.opacity(0.45)],
                                        startPoint: .leading, endPoint: .trailing
                                    ))
                                    .frame(width: g.size.width * CGFloat(rune.activation))
                                    .shadow(color: runeColor.opacity(0.50), radius: 8)
                            }
                        }
                        .frame(height: 8)
                        HStack {
                            Text("Silent")
                                .font(.custom("AvenirNext-Regular", size: 9))
                                .foregroundStyle(.white.opacity(0.22))
                            Spacer()
                            Text("Full power")
                                .font(.custom("AvenirNext-Regular", size: 9))
                                .foregroundStyle(.white.opacity(0.22))
                        }
                    }

                    // Badges
                    HStack(spacing: 10) {
                        inspectBadge(title: "Connections", value: rune.weights, tint: Color(red: 0.63, green: 0.50, blue: 1.0))
                        inspectBadge(title: "Error share", value: gradientLabel, tint: gradientColor)
                        inspectBadge(title: "Fired at", value: "\(Int(rune.activation * 100))%", tint: runeColor)
                    }

                    // ── What it did ───────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.forward.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(runeColor.opacity(0.75))
                            Text("WHAT THIS NEURON DID")
                                .font(.custom("AvenirNext-DemiBold", size: 10))
                                .tracking(2)
                                .foregroundStyle(runeColor.opacity(0.75))
                        }
                        Text(rune.forwardRole)
                            .font(.system(size: 17, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineSpacing(5)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(runeColor.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(runeColor.opacity(0.22), lineWidth: 1))

                    // ── Why it matters ────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.75))
                            Text("WHY THIS MATTERS")
                                .font(.custom("AvenirNext-DemiBold", size: 10))
                                .tracking(2)
                                .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.75))
                        }
                        Text(rune.description)
                            .font(.system(size: 17, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineSpacing(5)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.05),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.16), lineWidth: 1))

                    // Math reveal
                    if mathReveal {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "function")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.75))
                                Text("THE MATH BEHIND IT")
                                    .font(.custom("AvenirNext-DemiBold", size: 10))
                                    .tracking(2)
                                    .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.75))
                            }
                            Text(rune.math)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75))
                                .lineSpacing(5)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.08),
                                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.22), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color(red: 0.04, green: 0.02, blue: 0.11).opacity(0.98),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(runeColor.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: runeColor.opacity(0.20), radius: 30, y: -8)
    }

    // Gradient badge helpers
    private var gradientColor: Color {
        let g = Double(rune.gradient) ?? 0
        if g > 0.025 { return Color(red: 0.85, green: 0.19, blue: 0.38) }
        if g > 0.015 { return Color(red: 0.91, green: 0.72, blue: 0.29) }
        return Color(red: 0.24, green: 0.84, blue: 0.75)
    }

    private var gradientLabel: String {
        let g = Double(rune.gradient) ?? 0
        if g > 0.025 { return "HEAVY" }
        if g > 0.015 { return "MED" }
        return "LIGHT"
    }

    private func inspectBadge(title: String, value: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.custom("AvenirNext-DemiBold", size: 15))
                .foregroundStyle(tint)
            Text(title)
                .font(.custom("AvenirNext-DemiBold", size: 9))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.50))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(tint.opacity(0.22), lineWidth: 1))
    }
}
