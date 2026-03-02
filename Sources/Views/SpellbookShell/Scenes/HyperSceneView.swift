import SwiftUI

// MARK: - Scene

struct HyperSceneView: View {
    let onNext: () -> Void
    let onOpenModal: (SpellModalKey) -> Void
    @Binding var mathReveal: Bool

    @State private var learningRate: Double = 10
    @State private var batchSize: Double    = 32
    @State private var epochs: Double       = 20

    private var params: HyperCurveParameters {
        HyperCurveParameters(lrRaw: Int(learningRate), batchSize: Int(batchSize), epochs: Int(epochs))
    }

    private var isWon: Bool {
        params.mode == .normal && params.finalLoss < 0.25
    }

    // ── Live consequence per slider ───────────────────────────────────────────

    private var lrConsequence: (text: String, color: Color) {
        if learningRate > 70 {
            return ("Way too high — training will explode",           Color(red: 0.85, green: 0.19, blue: 0.38))
        } else if learningRate < 6 {
            return ("Too low — almost no learning happening",         Color(red: 0.91, green: 0.72, blue: 0.29))
        } else if learningRate < 20 {
            return ("Low but stable — try raising it a bit",          Color(red: 0.91, green: 0.72, blue: 0.29))
        } else if learningRate < 55 {
            return ("Good range — smooth, efficient learning",        Color(red: 0.24, green: 0.84, blue: 0.75))
        } else {
            return ("Getting high — watch for instability",           Color(red: 1.00, green: 0.42, blue: 0.21))
        }
    }

    private var batchConsequence: (text: String, color: Color) {
        if batchSize < 6 {
            return ("Very small — noisy, unstable updates",           Color(red: 0.85, green: 0.19, blue: 0.38))
        } else if batchSize < 16 {
            return ("Small — some noise, trains fast",                Color(red: 0.91, green: 0.72, blue: 0.29))
        } else if batchSize < 64 {
            return ("Balanced — stable, reliable updates",            Color(red: 0.24, green: 0.84, blue: 0.75))
        } else {
            return ("Large — very smooth but needs more epochs",      Color(red: 0.63, green: 0.50, blue: 1.00))
        }
    }

    private var epochsConsequence: (text: String, color: Color) {
        if epochs < 15 {
            return ("Too few — barely any time to learn",             Color(red: 0.85, green: 0.19, blue: 0.38))
        } else if epochs < 40 {
            return ("Moderate — may not fully converge",              Color(red: 0.91, green: 0.72, blue: 0.29))
        } else if epochs < 100 {
            return ("Good — enough rounds to learn properly",         Color(red: 0.24, green: 0.84, blue: 0.75))
        } else {
            return ("Plenty — ample training time",                   Color(red: 0.24, green: 0.84, blue: 0.75))
        }
    }

    private var verdictText: String {
        switch params.mode {
        case .explode:
            return "Learning rate is too high — training is exploding. Lower it."
        case .slow:
            return "Learning rate is too low — barely any progress. Increase it."
        case .normal:
            if params.finalLoss < 0.25 {
                return "Loss below target. The spell is mastered."
            } else if params.finalLoss < 0.40 {
                return "Getting close — try more epochs or a slightly higher learning rate."
            } else {
                return "Not there yet. Raise learning rate or add more epochs."
            }
        }
    }

    private var lossColor: Color {
        if isWon                         { return Color(red: 0.24, green: 0.84, blue: 0.75) }
        if params.mode == .explode       { return Color(red: 0.85, green: 0.19, blue: 0.38) }
        if params.finalLoss < 0.35       { return Color(red: 0.91, green: 0.72, blue: 0.29) }
        return Color(red: 0.85, green: 0.19, blue: 0.38)
    }

    // ── Body ──────────────────────────────────────────────────────────────────

    var body: some View {
        ZStack(alignment: .bottom) {

            HyperAmbientView(mode: params.mode, finalLoss: params.finalLoss, isWon: isWon)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Header ────────────────────────────────────────────────
                    VStack(spacing: 3) {
                        Text("CHAPTER IV")
                            .font(.custom("AvenirNext-DemiBold", size: 9.5))
                            .tracking(3.5)
                            .foregroundStyle(Color(red: 0.56, green: 0.43, blue: 0.16))
                        Text("Tune the Spell")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(red: 0.91, green: 0.72, blue: 0.29),
                                         Color(red: 0.86, green: 0.85, blue: 1.0)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 14)

                    // ── Goal + current loss row ───────────────────────────────
                    HStack(alignment: .center) {

                        // Target badge
                        VStack(alignment: .leading, spacing: 3) {
                            Text("TARGET")
                                .font(.custom("AvenirNext-DemiBold", size: 9))
                                .tracking(2.5)
                                .foregroundStyle(.white.opacity(0.30))
                            Text("Loss < 0.25")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.08),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(red: 0.24, green: 0.84, blue: 0.75)
                                    .opacity(isWon ? 0.60 : 0.22), lineWidth: 1)
                        )

                        Spacer()

                        // Current loss (live)
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.3f", params.finalLoss))
                                .font(.system(size: 34, weight: .bold, design: .monospaced))
                                .foregroundStyle(lossColor)
                                .contentTransition(.numericText())
                                .animation(.linear(duration: 0.06), value: params.finalLoss)
                            Text("CURRENT LOSS")
                                .font(.custom("AvenirNext-DemiBold", size: 9))
                                .tracking(2)
                                .foregroundStyle(.white.opacity(0.25))
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 14)

                    // ── Loss curve (live, with target line) ───────────────────
                    HyperLossCurveView(parameters: params, isWon: isWon)
                        .padding(.horizontal, 14)
                        .frame(height: 160)
                        .padding(.bottom, 10)

                    // ── Verdict sentence ─────────────────────────────────────
                    Text(verdictText)
                        .font(.system(size: 15, weight: .light, design: .serif))
                        .foregroundStyle(.white.opacity(0.70))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .animation(.easeInOut(duration: 0.25), value: verdictText)

                    // ── Victory badge ─────────────────────────────────────────
                    if isWon {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13))
                            Text("TRAINING MASTERED")
                                .font(.custom("AvenirNext-DemiBold", size: 13))
                                .tracking(2)
                        }
                        .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.10),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.42), lineWidth: 1)
                        )
                        .padding(.top, 12)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                    }

                    Spacer(minLength: 20)

                    // ── Slider cards ──────────────────────────────────────────
                    VStack(spacing: 10) {
                        HyperSliderCard(
                            name: "Learning Rate",
                            hint: "How big each correction step is",
                            valueText: String(format: "%.3f", learningRate / 1000),
                            value: $learningRate,
                            range: 1...100,
                            tint: Color(red: 0.63, green: 0.50, blue: 1.00),
                            consequence: lrConsequence
                        )
                        HyperSliderCard(
                            name: "Batch Size",
                            hint: "How many examples the AI sees at once",
                            valueText: "\(Int(batchSize))",
                            value: $batchSize,
                            range: 1...128,
                            tint: Color(red: 0.24, green: 0.84, blue: 0.75),
                            consequence: batchConsequence
                        )
                        HyperSliderCard(
                            name: "Epochs",
                            hint: "How many full passes through the data",
                            valueText: "\(Int(epochs))",
                            value: $epochs,
                            range: 1...200,
                            tint: Color(red: 0.91, green: 0.72, blue: 0.29),
                            consequence: epochsConsequence
                        )
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 140)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isWon)

            // ── Bottom gradient ───────────────────────────────────────────────
            LinearGradient(
                colors: [.clear, Color(red: 0.03, green: 0.01, blue: 0.09).opacity(0.97)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 170)
            .allowsHitTesting(false)

            // ── Bottom buttons ────────────────────────────────────────────────
            VStack(spacing: 8) {
                if isWon {
                    SpellButton(title: "Inspect the Runes →", tone: .spirit, isPulsing: true) {
                        onNext()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                SpellButton(title: "✦ Deep Dive", tone: .gold) {
                    onOpenModal(.hyper)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 90)
            .animation(.spring(response: 0.45, dampingFraction: 0.78), value: isWon)
        }
    }
}

// MARK: - Slider card

private struct HyperSliderCard: View {
    let name: String
    let hint: String
    let valueText: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let tint: Color
    let consequence: (text: String, color: Color)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Name + value
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.90))
                    Text(hint)
                        .font(.custom("AvenirNext-Regular", size: 11))
                        .foregroundStyle(.white.opacity(0.35))
                }
                Spacer()
                Text(valueText)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(tint)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.05), value: valueText)
            }

            // Slider
            Slider(value: $value, in: range, step: 1)
                .tint(tint)

            // Live consequence
            HStack(spacing: 6) {
                Circle()
                    .fill(consequence.color)
                    .frame(width: 6, height: 6)
                    .shadow(color: consequence.color.opacity(0.65), radius: 4)
                Text(consequence.text)
                    .font(.custom("AvenirNext-Regular", size: 12))
                    .foregroundStyle(consequence.color.opacity(0.88))
            }
            .animation(.easeInOut(duration: 0.20), value: consequence.text)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            tint.opacity(0.05),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - Ambient background

private struct HyperAmbientView: View {
    let mode: HyperCurveMode
    let finalLoss: Double
    let isWon: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let pulse = CGFloat(0.78 + 0.22 * sin(t * 0.65))
                let modeColor: Color = isWon
                    ? Color(red: 0.24, green: 0.84, blue: 0.75)
                    : mode == .explode
                    ? Color(red: 0.85, green: 0.19, blue: 0.38)
                    : mode == .slow
                    ? Color(red: 0.91, green: 0.72, blue: 0.29)
                    : (finalLoss < 0.12
                       ? Color(red: 0.24, green: 0.84, blue: 0.75)
                       : Color(red: 0.63, green: 0.50, blue: 1.00))

                ctx.fill(
                    Path(ellipseIn: CGRect(x: -size.width * 0.05, y: size.height * 0.20,
                                           width: size.width * 0.65, height: size.height * 0.70)),
                    with: .radialGradient(
                        Gradient(colors: [modeColor.opacity(0.09 * pulse), .clear]),
                        center: CGPoint(x: size.width * 0.10, y: size.height * 0.60),
                        startRadius: 0, endRadius: size.width * 0.42
                    )
                )
                ctx.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.55, y: -size.height * 0.10,
                                           width: size.width * 0.55, height: size.height * 0.45)),
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

// MARK: - Loss curve with target line

private struct HyperLossCurveView: View {
    let parameters: HyperCurveParameters
    let isWon: Bool

    private let spirit = Color(red: 0.24, green: 0.84, blue: 0.75)

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.014, green: 0.010, blue: 0.048).opacity(0.92))
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)

                Canvas { context, _ in
                    let points = parameters.makePoints(in: size)
                    drawGrid(context: &context, size: size)
                    drawTargetLine(context: &context, size: size)
                    drawCurve(context: &context, points: points, size: size)
                }
            }
        }
    }

    private func drawGrid(context: inout GraphicsContext, size: CGSize) {
        let mana = Color(red: 0.49, green: 0.38, blue: 1.0)
        for i in 1..<4 {
            let y = size.height * CGFloat(i) / 4
            var line = Path()
            line.move(to: CGPoint(x: 0, y: y))
            line.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(line, with: .color(mana.opacity(0.08)), lineWidth: 0.5)

            let x = size.width * CGFloat(i) / 4
            var v = Path()
            v.move(to: CGPoint(x: x, y: 0))
            v.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(v, with: .color(mana.opacity(0.08)), lineWidth: 0.5)
        }

        let gold = Color(red: 0.91, green: 0.72, blue: 0.29)
        context.draw(
            Text("LOSS").font(.custom("AvenirNext-DemiBold", size: 8)).foregroundStyle(gold.opacity(0.35)),
            at: CGPoint(x: 8, y: 10), anchor: .leading
        )
        context.draw(
            Text("EPOCHS →").font(.custom("AvenirNext-DemiBold", size: 8)).foregroundStyle(gold.opacity(0.35)),
            at: CGPoint(x: size.width - 6, y: size.height - 4), anchor: .trailing
        )
    }

    private func drawTargetLine(context: inout GraphicsContext, size: CGSize) {
        // Dashed horizontal line at loss = 0.25
        let targetY = size.height - 0.25 * size.height * 0.90 - 5

        var line = Path()
        line.move(to:    CGPoint(x: 0, y: targetY))
        line.addLine(to: CGPoint(x: size.width, y: targetY))
        context.stroke(
            line,
            with: .color(spirit.opacity(isWon ? 0.70 : 0.42)),
            style: StrokeStyle(lineWidth: 1.2, dash: [5, 4])
        )

        context.draw(
            Text("TARGET")
                .font(.custom("AvenirNext-DemiBold", size: 7.5))
                .foregroundStyle(spirit.opacity(isWon ? 0.80 : 0.55)),
            at: CGPoint(x: 8, y: targetY - 9), anchor: .leading
        )
    }

    private func drawCurve(context: inout GraphicsContext, points: [CGPoint], size: CGSize) {
        guard let last = points.last else { return }

        // Area fill
        var area = Path()
        area.move(to: CGPoint(x: 0, y: size.height))
        for p in points { area.addLine(to: p) }
        area.addLine(to: CGPoint(x: size.width, y: size.height))
        area.closeSubpath()
        context.fill(area, with: .linearGradient(
            Gradient(colors: [
                Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.10),
                Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.02)
            ]),
            startPoint: CGPoint(x: size.width / 2, y: 0),
            endPoint:   CGPoint(x: size.width / 2, y: size.height)
        ))

        // Curve stroke
        var curve = Path()
        for (i, p) in points.enumerated() {
            if i == 0 { curve.move(to: p) } else { curve.addLine(to: p) }
        }
        context.stroke(
            curve,
            with: .linearGradient(
                Gradient(colors: [
                    Color(red: 0.85, green: 0.19, blue: 0.38),
                    Color(red: 0.91, green: 0.72, blue: 0.29),
                    isWon ? spirit : Color(red: 0.91, green: 0.72, blue: 0.29)
                ]),
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: 0)
            ),
            lineWidth: 2.2
        )

        // End dot
        let dotColor: Color = isWon
            ? spirit
            : (parameters.finalLoss < 0.15 ? Color(red: 0.91, green: 0.72, blue: 0.29)
                                            : Color(red: 0.85, green: 0.19, blue: 0.38))

        context.fill(
            Path(ellipseIn: CGRect(x: last.x - 8, y: last.y - 8, width: 16, height: 16)),
            with: .radialGradient(
                Gradient(colors: [dotColor.opacity(0.70), .clear]),
                center: last, startRadius: 0, endRadius: 8
            )
        )
        context.fill(
            Path(ellipseIn: CGRect(x: last.x - 3.5, y: last.y - 3.5, width: 7, height: 7)),
            with: .color(dotColor)
        )
        context.stroke(
            Path(ellipseIn: CGRect(x: last.x - 3.5, y: last.y - 3.5, width: 7, height: 7)),
            with: .color(.white.opacity(0.80)),
            lineWidth: 1.5
        )

        // Final loss label
        context.draw(
            Text(String(format: "%.3f", parameters.finalLoss))
                .font(.custom("AvenirNext-DemiBold", size: 9))
                .foregroundStyle(dotColor.opacity(0.90)),
            at: CGPoint(x: size.width - 6, y: max(12, last.y - 10)),
            anchor: .trailing
        )
    }
}

// MARK: - Curve math (unchanged)

private enum HyperCurveMode: String {
    case explode
    case slow
    case normal
}

private struct HyperCurveParameters {
    let lrRaw: Int
    let batchSize: Int
    let epochs: Int
    let mode: HyperCurveMode
    let finalLoss: Double
    let noiseAmplitude: Double
    let decayRate: Double

    init(lrRaw: Int, batchSize: Int, epochs: Int) {
        self.lrRaw     = lrRaw
        self.batchSize = batchSize
        self.epochs    = epochs

        if lrRaw > 70 {
            mode           = .explode
            finalLoss      = 0.6 + Double(lrRaw - 70) / 100
            noiseAmplitude = 0.3 + Double(lrRaw - 70) / 150
            decayRate      = 0
        } else if lrRaw < 6 {
            mode           = .slow
            decayRate      = Double(lrRaw) / 6 * 0.8
            noiseAmplitude = 0.008
            finalLoss      = max(0.55, 0.92 - Double(epochs) * decayRate * 0.003)
        } else {
            mode      = .normal
            decayRate = Double(lrRaw - 6) / 64 * 5.0
            if batchSize < 6 {
                noiseAmplitude = 0.18
            } else if batchSize < 16 {
                noiseAmplitude = 0.10
            } else if batchSize < 40 {
                noiseAmplitude = 0.04
            } else {
                noiseAmplitude = 0.008
            }
            let bsBonus     = log(Double(batchSize + 1)) / log(129) * 0.12
            let convergence = 1 - exp(-decayRate * (Double(epochs) / 50))
            finalLoss       = max(0.015, (0.88 - bsBonus) * (1 - convergence) + 0.015)
        }
    }

    func makePoints(in size: CGSize) -> [CGPoint] {
        let seed = UInt64(max(1, lrRaw * 31 + batchSize * 17 + epochs * 13 + Int(finalLoss * 1000) * 7))
        var rng  = SeededRandom(seed: seed)
        let n    = 140

        return (0...n).map { index in
            let t      = Double(index) / Double(n)
            let random = Double(rng.nextFloat(in: -1...1))
            let loss: Double

            switch mode {
            case .explode:
                let base = 0.5 + noiseAmplitude * 1.2 * sin(t * 22 + 0.8) * exp(t * 0.8)
                loss = min(1.0, max(0.05, base + random * noiseAmplitude * 0.6))
            case .slow:
                let decay = 0.88 * exp(-decayRate * t * (Double(epochs) / 100)) + finalLoss * 0.12
                loss = min(1.0, max(0.01, decay + random * noiseAmplitude))
            case .normal:
                let noiseScale = noiseAmplitude * exp(-t * 2.5) + noiseAmplitude * 0.15
                let envelope   = (0.88 - finalLoss) * exp(-decayRate * t) + finalLoss
                loss = min(1.0, max(0.01, envelope + random * noiseScale * 2))
            }

            return CGPoint(
                x: CGFloat(t) * size.width,
                y: size.height - CGFloat(loss) * size.height * 0.90 - 5
            )
        }
    }
}
