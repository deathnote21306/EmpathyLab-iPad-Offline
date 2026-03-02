import SwiftUI

struct AwakeningSceneView: View {
    let onActivate: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isNavigating = false
    @State private var rippleID: UUID? = nil

    // Staggered entrance
    @State private var showTitle    = false
    @State private var showSub      = false
    @State private var showCircle   = false
    @State private var showHint     = false
    @State private var showChapters = false

    private let gold    = Color(red: 0.91, green: 0.72, blue: 0.29)
    private let mana    = Color(red: 0.49, green: 0.38, blue: 1.0)
    private let spirit  = Color(red: 0.24, green: 0.84, blue: 0.75)
    private let crimson = Color(red: 0.85, green: 0.19, blue: 0.38)
    private let ember   = Color(red: 1.00, green: 0.42, blue: 0.21)
    private let manaLt  = Color(red: 0.63, green: 0.50, blue: 1.00)

    private let chapterInfo: [(numeral: String, label: String, color: Color)] = [
        ("I",   "Decisions",  Color(red: 0.91, green: 0.72, blue: 0.29)),
        ("II",  "Mistakes",   Color(red: 0.85, green: 0.19, blue: 0.38)),
        ("III", "Learning",   Color(red: 1.00, green: 0.42, blue: 0.21)),
        ("IV",  "Training",   Color(red: 0.63, green: 0.50, blue: 1.00)),
        ("V",   "Discovery",  Color(red: 0.24, green: 0.84, blue: 0.75)),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            // ── Title block ────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("Neural Spellbook")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [gold, manaLt, spirit],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)

                Text("Discover how AI really thinks")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(red: 0.78, green: 0.73, blue: 1.0).opacity(0.55))
                    .multilineTextAlignment(.center)
            }
            .opacity(showTitle ? 1 : 0)
            .offset(y: showTitle ? 0 : 20)
            .animation(.spring(response: 0.60, dampingFraction: 0.80), value: showTitle)

            Color.clear.frame(height: 30)

            // ── Chapter preview pills ──────────────────────────────────────
            HStack(spacing: 8) {
                ForEach(Array(chapterInfo.enumerated()), id: \.offset) { i, chapter in
                    VStack(spacing: 5) {
                        Text(chapter.numeral)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(chapter.color)
                        Text(chapter.label)
                            .font(.custom("AvenirNext-DemiBold", size: 10))
                            .tracking(0.5)
                            .foregroundStyle(chapter.color.opacity(0.70))
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 10)
                    .background(chapter.color.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(chapter.color.opacity(0.28), lineWidth: 1)
                    )
                    .opacity(showChapters ? 1 : 0)
                    .offset(y: showChapters ? 0 : 10)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.78)
                            .delay(Double(i) * 0.07),
                        value: showChapters
                    )
                }
            }
            .padding(.horizontal, 14)

            Color.clear.frame(height: 28)

            // ── Magic circle ───────────────────────────────────────────────
            ZStack {
                // Pulsing attention ring (behind circle)
                if showCircle {
                    PulsingRing(color: mana)
                }

                if !reduceMotion {
                    MagicCircleView()
                        .frame(width: 214, height: 214)
                } else {
                    StaticMagicCircle()
                        .frame(width: 214, height: 214)
                }

                if let id = rippleID {
                    RippleCircleView()
                        .id(id)
                }
            }
            .frame(width: 214, height: 214)
            .contentShape(Circle())
            .onTapGesture {
                guard !isNavigating else { return }
                isNavigating = true
                rippleID = UUID()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                    onActivate()
                }
            }
            .opacity(showCircle ? 1 : 0)
            .scaleEffect(showCircle ? 1 : 0.75)
            .animation(.spring(response: 0.65, dampingFraction: 0.70), value: showCircle)
            .accessibilityLabel("Tap to begin the Neural Spellbook")
            .accessibilityAddTraits(.isButton)

            // Fixed spacing — prevents layout shift during entrance animations
            Color.clear.frame(height: 24)

            // ── Tap hint ───────────────────────────────────────────────────
            TapHintLabel()
                .opacity(showHint ? 1 : 0)
                .animation(.easeIn(duration: 0.40), value: showHint)

            Color.clear.frame(height: 20)

            // ── Meta info ──────────────────────────────────────────────────
            Text("5 interactive chapters  ·  no coding required")
                .font(.custom("AvenirNext-DemiBold", size: 11))
                .tracking(1.2)
                .foregroundStyle(Color(red: 0.55, green: 0.50, blue: 0.80).opacity(0.45))
                .multilineTextAlignment(.center)
                .opacity(showSub ? 1 : 0)
                .animation(.easeIn(duration: 0.40), value: showSub)

            Spacer(minLength: 12)

            // ── Challenge credit ───────────────────────────────────────────
            Text("✦ Apple Swift Student Challenge 2026 · Williams Lendjoungou")
                .font(.custom("AvenirNext-DemiBold", size: 11))
                .tracking(0.8)
                .foregroundStyle(gold.opacity(0.55))
                .multilineTextAlignment(.center)
                .opacity(showSub ? 1 : 0)
                .animation(.easeIn(duration: 0.40), value: showSub)

            Spacer(minLength: 16)
        }
        .padding(.horizontal, 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) { showTitle    = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) { showChapters = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { showCircle   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) { showHint     = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.00) { showSub      = true }
        }
    }
}

// MARK: - Pulsing attention ring (draws the eye to the circle)

private struct PulsingRing: View {
    let color: Color
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.40

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 1.5)
            .frame(width: 214, height: 214)
            .scaleEffect(scale)
            .opacity(opacity)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.8).repeatForever(autoreverses: false)
                ) {
                    scale = 1.55
                    opacity = 0
                }
            }
    }
}

// MARK: - Tap hint

private struct TapHintLabel: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.75))
            Text("TAP TO BEGIN")
                .font(.custom("AvenirNext-DemiBold", size: 14))
                .tracking(3.5)
                .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.75))
        }
    }
}

// MARK: - Ripple animation

private struct RippleCircleView: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.70

    var body: some View {
        Circle()
            .stroke(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.65), lineWidth: 2.5)
            .frame(width: 214, height: 214)
            .scaleEffect(scale)
            .opacity(opacity)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeOut(duration: 0.68)) {
                    scale = 2.4
                    opacity = 0
                }
            }
    }
}

// MARK: - Animated Magic Circle

private struct MagicCircleView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawCircle(&ctx, size: size, t: t)
            }
        }
        .allowsHitTesting(false)
    }

    private func drawCircle(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let cx = size.width / 2
        let cy = size.height / 2
        let center = CGPoint(x: cx, y: cy)

        // Background glow
        ctx.fill(
            Path(ellipseIn: CGRect(x: cx - 103, y: cy - 103, width: 206, height: 206)),
            with: .radialGradient(
                Gradient(colors: [Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.28), .clear]),
                center: center, startRadius: 0, endRadius: 103
            )
        )

        // Outer ring — mana, 22s clockwise
        let p1 = CGFloat(t.truncatingRemainder(dividingBy: 22) / 22) * 450
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 97, y: cy - 97, width: 194, height: 194)),
            with: .color(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.5)),
            style: StrokeStyle(lineWidth: 1.1, dash: [6, 3], dashPhase: -p1)
        )

        // Middle ring — gold, 14s counter-clockwise
        let p2 = CGFloat(t.truncatingRemainder(dividingBy: 14) / 14) * 450
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 74, y: cy - 74, width: 148, height: 148)),
            with: .color(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.30)),
            style: StrokeStyle(lineWidth: 0.65, dash: [10, 5], dashPhase: p2)
        )

        // Inner ring — spirit, 8s clockwise
        let p3 = CGFloat(t.truncatingRemainder(dividingBy: 8) / 8) * 450
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 51, y: cy - 51, width: 102, height: 102)),
            with: .color(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.22)),
            style: StrokeStyle(lineWidth: 0.45, dash: [3, 8], dashPhase: -p3)
        )

        // Cardinal + diagonal tick marks (fixed)
        let ticks: [(CGPoint, CGPoint)] = [
            (CGPoint(x: cx, y: cy - 97), CGPoint(x: cx, y: cy - 85)),
            (CGPoint(x: cx, y: cy + 85), CGPoint(x: cx, y: cy + 97)),
            (CGPoint(x: cx - 97, y: cy), CGPoint(x: cx - 85, y: cy)),
            (CGPoint(x: cx + 85, y: cy), CGPoint(x: cx + 97, y: cy)),
            (CGPoint(x: cx - 67, y: cy - 67), CGPoint(x: cx - 59, y: cy - 59)),
            (CGPoint(x: cx + 59, y: cy + 59), CGPoint(x: cx + 67, y: cy + 67)),
            (CGPoint(x: cx + 67, y: cy - 67), CGPoint(x: cx + 59, y: cy - 59)),
            (CGPoint(x: cx - 59, y: cy + 59), CGPoint(x: cx - 67, y: cy + 67))
        ]
        for (from, to) in ticks {
            var p = Path(); p.move(to: from); p.addLine(to: to)
            ctx.stroke(p, with: .color(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.35)), lineWidth: 0.65)
        }

        // Triangle 1 — mana, 14s counter-clockwise
        let a1 = -t.truncatingRemainder(dividingBy: 14) / 14 * .pi * 2
        var tri1 = Path()
        let t1pts = (0..<3).map { i -> CGPoint in
            let a = a1 + Double(i) * .pi * 2 / 3 - .pi / 2
            return CGPoint(x: cx + 50 * CGFloat(cos(a)), y: cy + 50 * CGFloat(sin(a)))
        }
        tri1.move(to: t1pts[0]); tri1.addLine(to: t1pts[1]); tri1.addLine(to: t1pts[2]); tri1.closeSubpath()
        ctx.stroke(tri1, with: .color(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.32)), lineWidth: 0.85)

        // Triangle 2 — spirit, 22s clockwise, inverted
        let a2 = t.truncatingRemainder(dividingBy: 22) / 22 * .pi * 2
        var tri2 = Path()
        let t2pts = (0..<3).map { i -> CGPoint in
            let a = a2 + Double(i) * .pi * 2 / 3 + .pi / 2
            return CGPoint(x: cx + 50 * CGFloat(cos(a)), y: cy + 50 * CGFloat(sin(a)))
        }
        tri2.move(to: t2pts[0]); tri2.addLine(to: t2pts[1]); tri2.addLine(to: t2pts[2]); tri2.closeSubpath()
        ctx.stroke(tri2, with: .color(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.22)), lineWidth: 0.65)

        // Pulsing center dot
        let phase = CGFloat(t.truncatingRemainder(dividingBy: 2.2) / 2.2) * 2 * .pi
        let r = 5.75 - 1.75 * CGFloat(cos(phase))
        let op = 0.7 + 0.3 * CGFloat((sin(phase) + 1) / 2)
        ctx.fill(
            Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
            with: .color(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(Double(op)))
        )
    }
}

// MARK: - Static fallback for reduced motion

private struct StaticMagicCircle: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.18))
                .frame(width: 206, height: 206)
            Circle()
                .stroke(Color(red: 0.36, green: 0.19, blue: 1.0).opacity(0.45), lineWidth: 1.1)
                .frame(width: 194, height: 194)
            Circle()
                .stroke(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.28), lineWidth: 0.7)
                .frame(width: 148, height: 148)
            Circle()
                .stroke(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.20), lineWidth: 0.5)
                .frame(width: 102, height: 102)
            Circle()
                .fill(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.75))
                .frame(width: 11, height: 11)
        }
        .allowsHitTesting(false)
    }
}
