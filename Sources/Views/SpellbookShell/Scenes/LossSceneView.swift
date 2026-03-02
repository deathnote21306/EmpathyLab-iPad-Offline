import SwiftUI
import CoreMotion

// MARK: - Loss Scene

struct LossSceneView: View {
    let onNext: () -> Void
    let onOpenModal: (SpellModalKey) -> Void

    @State private var predictedValue: Double = 0.27
    @State private var showPerfectBadge: Bool = false
    @State private var showTiltHint: Bool = false
    @State private var motionManager: CMMotionManager?

    private let truth: Double = 1.0
    private var loss: Double { pow(truth - predictedValue, 2) }
    private var impactRatio: Double { truth - predictedValue }

    private var stageColor: Color {
        if loss < 0.02 { return Color(red: 0.24, green: 0.84, blue: 0.75) }
        if loss < 0.12 { return Color(red: 0.91, green: 0.72, blue: 0.29) }
        if loss < 0.35 { return Color(red: 1.00, green: 0.42, blue: 0.21) }
        return Color(red: 0.85, green: 0.19, blue: 0.38)
    }

    private var stageLabel: String {
        if loss < 0.02 { return "PERFECT HIT" }
        if loss < 0.12 { return "INNER RING" }
        if loss < 0.35 { return "MIDDLE RING" }
        if loss < 0.65 { return "OUTER RING" }
        return "COMPLETE MISS"
    }

    private var stageMessage: String {
        if loss < 0.02 { return "Loss is zero. The spell found its mark." }
        if loss < 0.12 { return "Loss nearly gone — just a hair to perfect." }
        if loss < 0.35 { return "Loss coming down — keep going." }
        if loss < 0.65 { return "Loss is high — tilt right or drag to reduce it." }
        return "Loss is very high. The prediction missed the mark."
    }

    var body: some View {
        ZStack {
            LossAmbientBackgroundView(loss: loss)

            VStack(spacing: 0) {

                // ── HEADER
                VStack(spacing: 4) {
                    Text("CHAPTER II")
                        .font(.custom("AvenirNext-DemiBold", size: 9.5))
                        .tracking(3.5)
                        .foregroundStyle(Color(red: 0.56, green: 0.43, blue: 0.16))
                    Text("The Spell Fails")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.91, green: 0.72, blue: 0.29),
                                         Color(red: 0.86, green: 0.85, blue: 1.0)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    Text("From Chapter I · prediction = 0.27, truth = 1.0")
                        .font(.system(size: 12, weight: .light, design: .serif))
                        .italic()
                        .foregroundStyle(.white.opacity(0.32))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 10)

                // ── BULLSEYE HERO
                BullseyeCanvasView(impactRatio: impactRatio, loss: loss)
                    .frame(width: 226, height: 226)

                // ── STAGE LABEL
                Text(stageLabel)
                    .font(.custom("AvenirNext-DemiBold", size: 12))
                    .tracking(3.5)
                    .foregroundStyle(stageColor)
                    .padding(.top, 10)
                    .animation(.easeInOut(duration: 0.25), value: stageLabel)

                // ── PERFECT BADGE
                if showPerfectBadge {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                        Text("CONVERGENCE ACHIEVED")
                            .font(.custom("AvenirNext-DemiBold", size: 11))
                            .tracking(1.5)
                    }
                    .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.10),
                        in: Capsule()
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.35), lineWidth: 1)
                    )
                    .padding(.top, 6)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
                }

                // ── MESSAGE
                Text(stageMessage)
                    .font(.system(size: 15, weight: .light, design: .serif))
                    .foregroundStyle(.white.opacity(0.58))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.top, 6)
                    .animation(.easeInOut(duration: 0.25), value: stageMessage)

                Spacer(minLength: 12)

                // ── LOSS READOUT
                VStack(spacing: 2) {
                    Text(String(format: "%.0f%%", min(100, loss * 100)))
                        .font(.system(size: 44, weight: .bold, design: .monospaced))
                        .foregroundStyle(stageColor)
                        .contentTransition(.numericText())
                        .animation(.linear(duration: 0.04), value: loss)
                    Text("LOSS")
                        .font(.custom("AvenirNext-DemiBold", size: 9))
                        .tracking(2.5)
                        .foregroundStyle(.white.opacity(0.25))
                }

                Spacer(minLength: 14)

                // ── INTERACTION INSTRUCTIONS
                HStack(spacing: 16) {
                    HStack(spacing: 5) {
                        Image(systemName: "hand.draw")
                            .font(.system(size: 11))
                        Text("DRAG RIGHT")
                            .font(.custom("AvenirNext-DemiBold", size: 9.5))
                            .tracking(2)
                    }
                    .foregroundStyle(.white.opacity(0.25))

                    Text("·")
                        .foregroundStyle(.white.opacity(0.15))

                    HStack(spacing: 5) {
                        Image(systemName: "gyroscope")
                            .font(.system(size: 11))
                        Text("TILT RIGHT")
                            .font(.custom("AvenirNext-DemiBold", size: 9.5))
                            .tracking(2)
                    }
                    .foregroundStyle(.white.opacity(0.25))
                }
                .padding(.bottom, 8)

                // ── DRAG RAIL
                LossDragRailView(value: $predictedValue, thumbColor: stageColor)
                    .padding(.horizontal, 26)

                Spacer(minLength: 18)

                // ── ACTIONS
                HStack(spacing: 10) {
                    SpellButton(title: "✦ Deep Dive", tone: .gold) {
                        onOpenModal(.loss)
                    }
                    SpellButton(title: "Continue →", tone: .spirit, isPulsing: loss < 0.02) {
                        onNext()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 90)
            }

            // ── TILT HINT BANNER
            if showTiltHint {
                VStack {
                    Spacer()
                    InteractionHintBanner(
                        icon: "gyroscope",
                        text: "Tilt your device to the right to reduce the loss — align your prediction with the truth"
                    )
                    .padding(.horizontal, 18)
                    .padding(.bottom, 170)
                }
                .transition(.opacity.combined(with: .offset(y: 6)))
                .allowsHitTesting(false)
            }
        }
        .onAppear { startMotion() }
        .onDisappear { stopMotion() }
        .onChange(of: loss) { _, newLoss in
            if newLoss < 0.02 {
                withAnimation(.spring(response: 0.50, dampingFraction: 0.65)) {
                    showPerfectBadge = true
                }
            } else if showPerfectBadge {
                withAnimation(.easeOut(duration: 0.25)) {
                    showPerfectBadge = false
                }
            }
        }
    }

    // MARK: - Motion

    private func startMotion() {
        let m = CMMotionManager()
        guard m.isDeviceMotionAvailable else { return }
        motionManager = m
        m.deviceMotionUpdateInterval = 1.0 / 30.0
        m.startDeviceMotionUpdates(to: .main) { data, _ in
            guard let data else { return }

            // Map "right side of screen goes down" to the correct gravity axis
            // based on the current interface orientation.
            // Portrait:          device X → screen right  → gravity.x > 0
            // LandscapeLeft:     device Y → screen right  → gravity.y > 0
            // LandscapeRight:    device -Y → screen right → gravity.y < 0
            // PortraitUpsideDown: device -X → screen right → gravity.x < 0
            let orientation = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.interfaceOrientation ?? .portrait

            let rightDown: Double
            switch orientation {
            case .landscapeLeft:      rightDown =  data.gravity.y
            case .landscapeRight:     rightDown = -data.gravity.y
            case .portraitUpsideDown: rightDown = -data.gravity.x
            default:                  rightDown =  data.gravity.x
            }

            if rightDown > 0.12 {
                let strength = min((rightDown - 0.12) * 2.5, 1.0)
                predictedValue = min(0.99, predictedValue + strength * 0.012)
            }
        }
        // Show hint for 5 seconds
        withAnimation(.easeIn(duration: 0.35)) { showTiltHint = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            withAnimation(.easeOut(duration: 0.40)) { showTiltHint = false }
        }
    }

    private func stopMotion() {
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
    }
}

// MARK: - Bullseye Canvas

private struct BullseyeCanvasView: View {
    let impactRatio: Double
    let loss: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                draw(&ctx, size: size, t: t)
            }
        }
        .allowsHitTesting(false)
    }

    private func ringColor(for index: Int) -> Color {
        switch index {
        case 4: return Color(red: 0.24, green: 0.84, blue: 0.75)
        case 3: return Color(red: 0.55, green: 0.88, blue: 0.62)
        case 2: return Color(red: 0.91, green: 0.72, blue: 0.29)
        case 1: return Color(red: 1.00, green: 0.42, blue: 0.21)
        default: return Color(red: 0.85, green: 0.19, blue: 0.38)
        }
    }

    private func activeRingIndex() -> Int {
        if loss < 0.02 { return 4 }
        if loss < 0.12 { return 3 }
        if loss < 0.35 { return 2 }
        if loss < 0.65 { return 1 }
        return 0
    }

    private func draw(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let cx   = size.width  / 2
        let cy   = size.height / 2
        let ctr  = CGPoint(x: cx, y: cy)
        let maxR = min(cx, cy) * 0.88

        let radii: [CGFloat] = [maxR, maxR * 0.76, maxR * 0.54, maxR * 0.33, maxR * 0.13]
        let activeIdx = activeRingIndex()
        let isPerfect = loss < 0.02
        let pulse     = CGFloat(0.80 + 0.20 * sin(t * (isPerfect ? 4.0 : 2.2)))

        let glowCol = isPerfect ? Color(red: 0.24, green: 0.84, blue: 0.75) : ringColor(for: activeIdx)
        ctx.fill(
            Path(ellipseIn: CGRect(x: cx - maxR * 1.30, y: cy - maxR * 1.30,
                                   width: maxR * 2.60, height: maxR * 2.60)),
            with: .radialGradient(
                Gradient(colors: [glowCol.opacity(0.12 * pulse), .clear]),
                center: ctr, startRadius: maxR * 0.20, endRadius: maxR * 1.30
            )
        )

        for i in 0..<5 {
            let r        = radii[i]
            let isActive = isPerfect || (i == activeIdx)
            let col      = isPerfect ? Color(red: 0.24, green: 0.84, blue: 0.75) : ringColor(for: i)
            let strokeA: CGFloat = isActive ? (isPerfect ? 0.88 * pulse : 0.90) : 0.20
            let fillA:   CGFloat = isActive ? (isPerfect ? 0.13 * pulse : 0.09) : 0.03
            let strokeW: CGFloat = isActive ? 2.2 : 0.9
            let rect     = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
            ctx.fill(Path(ellipseIn: rect), with: .color(col.opacity(fillA)))
            ctx.stroke(Path(ellipseIn: rect),
                       with: .color(col.opacity(strokeA)),
                       style: StrokeStyle(lineWidth: strokeW))
        }

        var hLine = Path(); hLine.move(to: CGPoint(x: cx - maxR, y: cy)); hLine.addLine(to: CGPoint(x: cx + maxR, y: cy))
        var vLine = Path(); vLine.move(to: CGPoint(x: cx, y: cy - maxR)); vLine.addLine(to: CGPoint(x: cx, y: cy + maxR))
        ctx.stroke(hLine, with: .color(.white.opacity(0.06)), lineWidth: 0.5)
        ctx.stroke(vLine, with: .color(.white.opacity(0.06)), lineWidth: 0.5)

        for angleDeg in [45.0, 135.0, 225.0, 315.0] {
            let rad = angleDeg * .pi / 180
            var tick = Path()
            tick.move(to: CGPoint(x: cx + (maxR - 7) * CGFloat(cos(rad)),
                                  y: cy + (maxR - 7) * CGFloat(sin(rad))))
            tick.addLine(to: CGPoint(x: cx + maxR * CGFloat(cos(rad)),
                                     y: cy + maxR * CGFloat(sin(rad))))
            ctx.stroke(tick, with: .color(.white.opacity(0.12)), lineWidth: 1.0)
        }

        let impactR  = CGFloat(max(0, impactRatio)) * maxR
        let impactX  = cx
        let impactY  = cy - impactR
        let impactPt = CGPoint(x: impactX, y: impactY)
        let dotColor = isPerfect ? Color(red: 0.24, green: 0.84, blue: 0.75) : ringColor(for: activeIdx)

        if !isPerfect && impactR > 5 {
            var line = Path()
            line.move(to: ctr); line.addLine(to: impactPt)
            ctx.stroke(line, with: .color(dotColor.opacity(0.22)),
                       style: StrokeStyle(lineWidth: 1.0, dash: [3, 4]))
        }

        ctx.fill(
            Path(ellipseIn: CGRect(x: impactX - 22, y: impactY - 22, width: 44, height: 44)),
            with: .radialGradient(
                Gradient(colors: [dotColor.opacity(0.55 * pulse), .clear]),
                center: impactPt, startRadius: 0, endRadius: 22
            )
        )

        let dotR: CGFloat = 7.0
        ctx.fill(Path(ellipseIn: CGRect(x: impactX - dotR, y: impactY - dotR,
                                        width: dotR * 2, height: dotR * 2)),
                 with: .color(dotColor))
        ctx.stroke(Path(ellipseIn: CGRect(x: impactX - dotR, y: impactY - dotR,
                                          width: dotR * 2, height: dotR * 2)),
                   with: .color(.white.opacity(0.90)), lineWidth: 2.0)

        if isPerfect {
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4 + t * 0.5
                var spoke = Path()
                spoke.move(to: CGPoint(x: cx + 5  * CGFloat(cos(angle)),
                                       y: cy + 5  * CGFloat(sin(angle))))
                spoke.addLine(to: CGPoint(x: cx + 22 * CGFloat(cos(angle)),
                                          y: cy + 22 * CGFloat(sin(angle))))
                ctx.stroke(spoke,
                           with: .color(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.72 * pulse)),
                           lineWidth: 2.0)
            }
        }
    }
}

// MARK: - Drag Rail

private struct LossDragRailView: View {
    @Binding var value: Double
    let thumbColor: Color

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { proxy in
                let w = proxy.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.80),
                                    Color(red: 1.00, green: 0.42, blue: 0.21).opacity(0.80),
                                    Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.80),
                                    Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.80),
                                ],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(height: 6)

                    let thumbX = max(0, min(w - 28, CGFloat(value) * w - 14))
                    Circle()
                        .fill(thumbColor)
                        .frame(width: 28, height: 28)
                        .shadow(color: thumbColor.opacity(0.65), radius: 10)
                        .overlay(Circle().stroke(.white.opacity(0.88), lineWidth: 2.0))
                        .offset(x: thumbX, y: 0)
                }
                .frame(height: 28)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { val in
                            value = max(0.01, min(0.99, Double(val.location.x / w)))
                        }
                )
            }
            .frame(height: 28)

            HStack {
                HStack(spacing: 3) {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 10))
                    Text("OFF TARGET").font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1.0)
                }
                .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.60))

                Spacer()

                HStack(spacing: 3) {
                    Text("PERFECT AIM").font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1.0)
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 10))
                }
                .foregroundStyle(Color(red: 0.24, green: 0.84, blue: 0.75).opacity(0.60))
            }
        }
    }
}

// MARK: - Animated ambient background

private struct LossAmbientBackgroundView: View {
    let loss: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawAmbient(&ctx, size: size, t: t, loss: loss)
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private func drawAmbient(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval, loss: Double) {
        let pulse = CGFloat(0.80 + 0.20 * sin(t * 0.65))
        let lossColor: Color = loss < 0.02
            ? Color(red: 0.24, green: 0.84, blue: 0.75)
            : loss < 0.12
            ? Color(red: 0.91, green: 0.72, blue: 0.29)
            : Color(red: 0.85, green: 0.19, blue: 0.38)

        ctx.fill(
            Path(ellipseIn: CGRect(x: -size.width * 0.15, y: size.height * 0.38,
                                   width: size.width * 0.70, height: size.height * 0.70)),
            with: .radialGradient(
                Gradient(colors: [lossColor.opacity(0.10 * pulse), .clear]),
                center: CGPoint(x: size.width * 0.12, y: size.height * 0.72),
                startRadius: 0, endRadius: size.width * 0.48
            )
        )
        ctx.fill(
            Path(ellipseIn: CGRect(x: size.width * 0.50, y: -size.height * 0.10,
                                   width: size.width * 0.60, height: size.height * 0.45)),
            with: .radialGradient(
                Gradient(colors: [Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.06 * pulse), .clear]),
                center: CGPoint(x: size.width * 0.88, y: 0),
                startRadius: 0, endRadius: size.width * 0.36
            )
        )
    }
}
