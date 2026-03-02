import SwiftUI

// MARK: - Arcane level intro card

struct IntroBeatSceneTemplate: View {
    let chapterNumber: Int
    let chapterTitle: String
    let missionText: String
    let whyText: String
    let buttonTitle: String
    let onBegin: () -> Void

    // Staggered entrance
    @State private var showBadge   = false
    @State private var showTitle   = false
    @State private var showDivider = false
    @State private var showMission = false
    @State private var showWhy     = false
    @State private var showButton  = false

    private let roman  = ["I", "II", "III", "IV", "V"]
    private let accents: [Color] = [
        Color(red: 0.91, green: 0.72, blue: 0.29),  // I   gold
        Color(red: 0.85, green: 0.19, blue: 0.38),  // II  crimson
        Color(red: 1.00, green: 0.42, blue: 0.21),  // III ember
        Color(red: 0.63, green: 0.50, blue: 1.00),  // IV  mana
        Color(red: 0.24, green: 0.84, blue: 0.75),  // V   spirit
    ]
    private let spirit = Color(red: 0.24, green: 0.84, blue: 0.75)
    private let void   = Color(red: 0.03, green: 0.01, blue: 0.09)

    private var accent: Color {
        accents.indices.contains(chapterNumber - 1) ? accents[chapterNumber - 1] : accents[0]
    }
    private var numeral: String {
        roman.indices.contains(chapterNumber - 1) ? roman[chapterNumber - 1] : "I"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {

                Spacer(minLength: 32)

                // ── Chapter badge ──────────────────────────────────────────
                HStack(spacing: 9) {
                    ArcaneSmallDiamond(color: accent)
                    Text("CHAPTER  \(numeral)")
                        .font(.custom("AvenirNext-DemiBold", size: 11))
                        .tracking(5)
                        .foregroundStyle(accent.opacity(0.80))
                    ArcaneSmallDiamond(color: accent)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .opacity(showBadge ? 1 : 0)
                .animation(.easeIn(duration: 0.50), value: showBadge)

                Spacer(minLength: 20)

                // ── Breathing ghost numeral ────────────────────────────────
                ZStack {
                    TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
                        let t = tl.date.timeIntervalSinceReferenceDate
                        let pulse = 0.045 + 0.025 * sin(t * 0.55)
                        Text(numeral)
                            .font(.system(size: 168, weight: .bold, design: .serif))
                            .foregroundStyle(accent.opacity(pulse))
                            .blur(radius: 4)
                    }
                    TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { tl in
                        let t = tl.date.timeIntervalSinceReferenceDate
                        let pulse = 0.03 + 0.015 * sin(t * 0.55 + 0.3)
                        Text(numeral)
                            .font(.system(size: 168, weight: .bold, design: .serif))
                            .foregroundStyle(accent.opacity(pulse))
                    }
                }
                .frame(height: 130)
                .opacity(showTitle ? 1 : 0)
                .animation(.easeIn(duration: 0.70), value: showTitle)

                // ── Chapter title ──────────────────────────────────────────
                Text(chapterTitle)
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 36)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 12)
                    .animation(.spring(response: 0.60, dampingFraction: 0.82), value: showTitle)

                Spacer(minLength: 22)

                // ── Ornamental divider ─────────────────────────────────────
                ArcaneDivider(accent: accent)
                    .padding(.horizontal, 44)
                    .opacity(showDivider ? 1 : 0)
                    .animation(.easeIn(duration: 0.45), value: showDivider)

                Spacer(minLength: 32)

                // ── Mission block ──────────────────────────────────────────
                ArcaneInfoBlock(
                    icon: { RuneCompassIcon(color: accent) },
                    label: "YOU WILL",
                    bodyText: missionText,
                    accent: accent
                )
                .padding(.horizontal, 26)
                .opacity(showMission ? 1 : 0)
                .offset(y: showMission ? 0 : 14)
                .animation(.spring(response: 0.55, dampingFraction: 0.78), value: showMission)

                Spacer(minLength: 14)

                // ── Why block ──────────────────────────────────────────────
                ArcaneInfoBlock(
                    icon: { RuneRadiantIcon(color: spirit) },
                    label: "WHY IT MATTERS",
                    bodyText: whyText,
                    accent: spirit
                )
                .padding(.horizontal, 26)
                .opacity(showWhy ? 1 : 0)
                .offset(y: showWhy ? 0 : 14)
                .animation(.spring(response: 0.55, dampingFraction: 0.78), value: showWhy)

                Spacer(minLength: 38)

                // ── Start button ───────────────────────────────────────────
                ArcaneStartButton(title: buttonTitle, accent: accent, action: onBegin)
                    .padding(.horizontal, 26)
                    .opacity(showButton ? 1 : 0)
                    .scaleEffect(showButton ? 1 : 0.90)
                    .animation(.spring(response: 0.55, dampingFraction: 0.70), value: showButton)

                Spacer(minLength: 56)
            }
        }
        .scrollIndicators(.hidden)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showBadge   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { showTitle   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.46) { showDivider = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.58) { showMission = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) { showWhy     = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.88) { showButton  = true }
        }
    }
}

// MARK: - Ornamental divider with central diamond

private struct ArcaneDivider: View {
    let accent: Color

    var body: some View {
        Canvas { ctx, size in
            let cy = size.height / 2
            let cx = size.width / 2
            let ds: CGFloat = 5.5   // diamond half-size
            let gap: CGFloat = ds * 1.6

            // Left fade line
            var left = Path()
            left.move(to: CGPoint(x: 0, y: cy))
            left.addLine(to: CGPoint(x: cx - gap, y: cy))
            ctx.stroke(left, with: .linearGradient(
                Gradient(colors: [accent.opacity(0), accent.opacity(0.45)]),
                startPoint: CGPoint(x: 0, y: cy),
                endPoint: CGPoint(x: cx - gap, y: cy)
            ), lineWidth: 0.75)

            // Right fade line
            var right = Path()
            right.move(to: CGPoint(x: cx + gap, y: cy))
            right.addLine(to: CGPoint(x: size.width, y: cy))
            ctx.stroke(right, with: .linearGradient(
                Gradient(colors: [accent.opacity(0.45), accent.opacity(0)]),
                startPoint: CGPoint(x: cx + gap, y: cy),
                endPoint: CGPoint(x: size.width, y: cy)
            ), lineWidth: 0.75)

            // Central diamond
            var d = Path()
            d.move(to: CGPoint(x: cx,       y: cy - ds))
            d.addLine(to: CGPoint(x: cx + ds * 0.65, y: cy))
            d.addLine(to: CGPoint(x: cx,       y: cy + ds))
            d.addLine(to: CGPoint(x: cx - ds * 0.65, y: cy))
            d.closeSubpath()
            ctx.fill(d, with: .color(accent.opacity(0.16)))
            ctx.stroke(d, with: .color(accent.opacity(0.72)), lineWidth: 1.0)

            // Flanking dots
            let dotR: CGFloat = 2.0
            let dotOff = gap * 1.55
            for xOff in [cx - dotOff, cx + dotOff] {
                ctx.fill(
                    Path(ellipseIn: CGRect(x: xOff - dotR, y: cy - dotR,
                                           width: dotR * 2, height: dotR * 2)),
                    with: .color(accent.opacity(0.40))
                )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 14)
    }
}

// MARK: - Small inline diamond glyph

private struct ArcaneSmallDiamond: View {
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let s: CGFloat = 4
            var d = Path()
            d.move(to: CGPoint(x: cx,       y: cy - s))
            d.addLine(to: CGPoint(x: cx + s * 0.7, y: cy))
            d.addLine(to: CGPoint(x: cx,       y: cy + s))
            d.addLine(to: CGPoint(x: cx - s * 0.7, y: cy))
            d.closeSubpath()
            ctx.fill(d, with: .color(color.opacity(0.70)))
        }
        .frame(width: 10, height: 10)
    }
}

// MARK: - Compass rune icon ("YOU WILL" — forward, action, objective)

private struct RuneCompassIcon: View {
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let r = min(cx, cy) - 3

            // Outer ring
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                with: .color(color.opacity(0.52)), lineWidth: 1.0
            )

            // 8 tick marks around the ring
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4.0
                let isCardinal = i % 2 == 0
                let len: CGFloat = isCardinal ? 5 : 3
                let innerR = r - len
                var tick = Path()
                tick.move(to: CGPoint(x: cx + CGFloat(cos(angle)) * innerR,
                                      y: cy + CGFloat(sin(angle)) * innerR))
                tick.addLine(to: CGPoint(x: cx + CGFloat(cos(angle)) * r,
                                         y: cy + CGFloat(sin(angle)) * r))
                ctx.stroke(tick, with: .color(color.opacity(isCardinal ? 0.55 : 0.28)),
                           lineWidth: isCardinal ? 1.0 : 0.65)
            }

            // Inner ring
            let r2 = r * 0.42
            ctx.stroke(
                Path(ellipseIn: CGRect(x: cx - r2, y: cy - r2, width: r2 * 2, height: r2 * 2)),
                with: .color(color.opacity(0.28)), lineWidth: 0.65
            )

            // Forward arrow (pointing right — "moving through")
            let aLen = r * 0.48
            var arrow = Path()
            arrow.move(to: CGPoint(x: cx - aLen * 0.55, y: cy))
            arrow.addLine(to: CGPoint(x: cx + aLen, y: cy))
            arrow.move(to: CGPoint(x: cx + aLen - 4, y: cy - 3.5))
            arrow.addLine(to: CGPoint(x: cx + aLen, y: cy))
            arrow.addLine(to: CGPoint(x: cx + aLen - 4, y: cy + 3.5))
            ctx.stroke(arrow, with: .color(color.opacity(0.92)), lineWidth: 1.5)

            // Center dot
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx - 2.8, y: cy - 2.8, width: 5.6, height: 5.6)),
                with: .color(color.opacity(1.0))
            )
        }
        .frame(width: 46, height: 46)
    }
}

// MARK: - Radiant gem icon ("WHY IT MATTERS" — significance, universal)

private struct RuneRadiantIcon: View {
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let r = min(cx, cy) - 4

            // 8 radiating rays — alternating long/short
            for i in 0..<8 {
                let angle = Double(i) * .pi / 4.0
                let isMain = i % 2 == 0
                let inner: CGFloat = r * 0.52
                let outer: CGFloat = isMain ? r : r * 0.78
                var ray = Path()
                ray.move(to: CGPoint(x: cx + CGFloat(cos(angle)) * inner,
                                     y: cy + CGFloat(sin(angle)) * inner))
                ray.addLine(to: CGPoint(x: cx + CGFloat(cos(angle)) * outer,
                                        y: cy + CGFloat(sin(angle)) * outer))
                ctx.stroke(ray, with: .color(color.opacity(isMain ? 0.65 : 0.30)),
                           lineWidth: isMain ? 1.1 : 0.7)
            }

            // Central diamond gem
            let dR = r * 0.44
            var d = Path()
            d.move(to: CGPoint(x: cx,          y: cy - dR))
            d.addLine(to: CGPoint(x: cx + dR * 0.65, y: cy))
            d.addLine(to: CGPoint(x: cx,          y: cy + dR))
            d.addLine(to: CGPoint(x: cx - dR * 0.65, y: cy))
            d.closeSubpath()
            ctx.fill(d, with: .color(color.opacity(0.15)))
            ctx.stroke(d, with: .color(color.opacity(0.78)), lineWidth: 1.1)

            // Center glow dot
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx - 2.8, y: cy - 2.8, width: 5.6, height: 5.6)),
                with: .color(color.opacity(0.95))
            )
        }
        .frame(width: 46, height: 46)
    }
}

// MARK: - Info block (centered, with canvas icon)

private struct ArcaneInfoBlock<Icon: View>: View {
    let icon: Icon
    let label: String
    let bodyText: String
    let accent: Color

    init(@ViewBuilder icon: () -> Icon, label: String, bodyText: String, accent: Color) {
        self.icon    = icon()
        self.label   = label
        self.bodyText = bodyText
        self.accent  = accent
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            icon

            Text(label)
                .font(.custom("AvenirNext-DemiBold", size: 10))
                .tracking(3.5)
                .foregroundStyle(accent.opacity(0.78))
                .multilineTextAlignment(.center)

            Text(bodyText)
                .font(.system(size: 15, weight: .light, design: .serif))
                .foregroundStyle(.white.opacity(0.84))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(accent.opacity(0.05),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - Arcane start button with breathing glow

private struct ArcaneStartButton: View {
    let title: String
    let accent: Color
    let action: () -> Void

    @State private var glow = false
    private let void = Color(red: 0.03, green: 0.01, blue: 0.09)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(void)

                // Canvas-drawn forward chevron
                Canvas { ctx, size in
                    let cx = size.width / 2, cy = size.height / 2
                    var v = Path()
                    v.move(to: CGPoint(x: cx - 3.5, y: cy - 4.5))
                    v.addLine(to: CGPoint(x: cx + 3.5, y: cy))
                    v.addLine(to: CGPoint(x: cx - 3.5, y: cy + 4.5))
                    ctx.stroke(v, with: .color(void.opacity(0.85)), lineWidth: 1.8)
                }
                .frame(width: 18, height: 18)
            }
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: accent.opacity(glow ? 0.68 : 0.28), radius: glow ? 26 : 12, y: 5)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}
