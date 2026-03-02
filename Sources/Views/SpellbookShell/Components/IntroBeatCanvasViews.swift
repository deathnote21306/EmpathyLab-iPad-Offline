import SwiftUI

// MARK: - Beat 0 · Forward Pass: signal flows left → right

struct IntroBeat0Canvas: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawBeat0(&ctx, size: size, t: t)
            }
        }
    }

    private struct Layer {
        let xFrac: CGFloat; let count: Int
        let rgb: (CGFloat, CGFloat, CGFloat); let label: String
    }

    private let layers: [Layer] = [
        .init(xFrac: 0.11, count: 3, rgb: (0.91, 0.72, 0.29), label: "INPUT"),
        .init(xFrac: 0.38, count: 4, rgb: (0.49, 0.38, 1.00), label: "HIDDEN I"),
        .init(xFrac: 0.68, count: 4, rgb: (0.49, 0.38, 1.00), label: "HIDDEN II"),
        .init(xFrac: 0.92, count: 2, rgb: (0.24, 0.84, 0.75), label: "OUTPUT")
    ]

    private func nodePositions(_ size: CGSize) -> [[CGPoint]] {
        let vCenter = size.height * 0.52
        return layers.map { layer in
            let x = size.width * layer.xFrac
            let step = size.height * 0.14
            let totalH = step * CGFloat(layer.count - 1)
            return (0..<layer.count).map { i in
                CGPoint(x: x, y: vCenter - totalH / 2 + step * CGFloat(i))
            }
        }
    }

    private func drawBeat0(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let flow = CGFloat(t * 0.30).truncatingRemainder(dividingBy: 1.0)
        let pos  = nodePositions(size)
        let activeLayer = min(layers.count - 1, Int(flow * CGFloat(layers.count)))
        let layerFrac   = (flow * CGFloat(layers.count)).truncatingRemainder(dividingBy: 1.0)
        let alpha: CGFloat = layerFrac < 0.5 ? layerFrac * 2 : 2 - layerFrac * 2

        // Title
        ctx.draw(
            Text("FORWARD PASS").font(.custom("AvenirNext-DemiBold", size: 10)).tracking(2.5)
                .foregroundStyle(Color(red: 0.91, green: 0.72, blue: 0.29).opacity(0.55)),
            at: CGPoint(x: size.width / 2, y: 14)
        )

        // Dim connections
        for li in 0..<(pos.count - 1) {
            for a in pos[li] {
                for b in pos[li + 1] {
                    var p = Path(); p.move(to: a); p.addLine(to: b)
                    ctx.stroke(p, with: .color(.white.opacity(0.05)), lineWidth: 0.8)
                }
            }
        }

        // Active connection glow
        if activeLayer < pos.count - 1 {
            let c = layers[activeLayer + 1].rgb
            for a in pos[activeLayer] {
                for b in pos[activeLayer + 1] {
                    var p = Path(); p.move(to: a); p.addLine(to: b)
                    // Outer glow
                    ctx.stroke(p, with: .color(Color(red: c.0, green: c.1, blue: c.2).opacity(alpha * 0.18)),
                               style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    // Core line
                    ctx.stroke(
                        p,
                        with: .linearGradient(
                            Gradient(colors: [
                                Color(red: c.0, green: c.1, blue: c.2).opacity(alpha * 0.75),
                                Color(red: c.0, green: c.1, blue: c.2).opacity(alpha * 0.18)
                            ]),
                            startPoint: a, endPoint: b
                        ),
                        lineWidth: 1.4
                    )
                }
            }
        }

        // Nodes
        let pulse = CGFloat((sin(t * 5) + 1) / 2)
        for (li, layer) in layers.enumerated() {
            let isActive = li == activeLayer
            let c = layer.rgb
            let lp = isActive ? pulse : 0
            let r: CGFloat = isActive ? 9 : 7

            for nd in pos[li] {
                // Halo
                if isActive {
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: nd.x - r*3.2, y: nd.y - r*3.2, width: r*6.4, height: r*6.4)),
                        with: .radialGradient(
                            Gradient(colors: [Color(red: c.0, green: c.1, blue: c.2).opacity(0.22 + lp * 0.16), .clear]),
                            center: nd, startRadius: 0, endRadius: r * 3.2
                        )
                    )
                }
                // Fill
                ctx.fill(
                    Path(ellipseIn: CGRect(x: nd.x - r, y: nd.y - r, width: r*2, height: r*2)),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color(red: c.0, green: c.1, blue: c.2).opacity(isActive ? 0.30 + lp * 0.20 : 0.08),
                            .clear
                        ]),
                        center: nd, startRadius: 0, endRadius: r
                    )
                )
                // Border
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: nd.x - r, y: nd.y - r, width: r*2, height: r*2)),
                    with: .color(Color(red: c.0, green: c.1, blue: c.2).opacity(isActive ? 0.92 + lp * 0.08 : 0.24)),
                    lineWidth: isActive ? 1.6 : 0.8
                )
            }

            // Layer label (top)
            if let first = pos[li].first {
                ctx.draw(
                    Text(layer.label).font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1.5)
                        .foregroundStyle(Color(red: c.0, green: c.1, blue: c.2).opacity(isActive ? 0.75 : 0.22)),
                    at: CGPoint(x: first.x, y: size.height - 12)
                )
            }
        }

        // Flow arrow
        let arrowX = size.width * 0.50
        let arrowY = size.height * 0.10
        ctx.draw(
            Text("signal  →").font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1)
                .foregroundStyle(Color.white.opacity(0.18)),
            at: CGPoint(x: arrowX, y: arrowY)
        )
    }
}

// MARK: - Beat 1 · Loss: predicted vs truth bars

struct IntroBeat1Canvas: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawBeat1(&ctx, size: size, t: t)
            }
        }
    }

    private func drawBeat1(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let predicted = CGFloat(0.28 + 0.24 * sin(t * 0.50))
        let bw: CGFloat = size.width * 0.14
        let bmax: CGFloat = size.height * 0.62
        let by: CGFloat = size.height * 0.14
        let bx1 = size.width * 0.30 - bw / 2
        let bx2 = size.width * 0.70 - bw / 2

        let predColor  = Color(red: 0.63, green: 0.50, blue: 1.0)
        let truthColor = Color(red: 0.24, green: 0.84, blue: 0.75)
        let errColor   = Color(red: 0.85, green: 0.19, blue: 0.38)

        // Title
        ctx.draw(
            Text("LOSS FUNCTION").font(.custom("AvenirNext-DemiBold", size: 10)).tracking(2.5)
                .foregroundStyle(errColor.opacity(0.55)),
            at: CGPoint(x: size.width / 2, y: 14)
        )

        // Background tracks
        ctx.fill(Path(roundedRect: CGRect(x: bx1, y: by, width: bw, height: bmax), cornerRadius: 5),
                 with: .color(predColor.opacity(0.07)))
        ctx.fill(Path(roundedRect: CGRect(x: bx2, y: by, width: bw, height: bmax), cornerRadius: 5),
                 with: .color(truthColor.opacity(0.07)))
        ctx.stroke(Path(roundedRect: CGRect(x: bx1, y: by, width: bw, height: bmax), cornerRadius: 5),
                   with: .color(predColor.opacity(0.30)), lineWidth: 1)
        ctx.stroke(Path(roundedRect: CGRect(x: bx2, y: by, width: bw, height: bmax), cornerRadius: 5),
                   with: .color(truthColor.opacity(0.30)), lineWidth: 1)

        // Prediction fill
        let predH = bmax * predicted
        ctx.fill(
            Path(roundedRect: CGRect(x: bx1, y: by + bmax - predH, width: bw, height: predH), cornerRadius: 5),
            with: .linearGradient(
                Gradient(colors: [predColor.opacity(0.88), predColor.opacity(0.32)]),
                startPoint: CGPoint(x: bx1, y: by + bmax - predH),
                endPoint: CGPoint(x: bx1, y: by + bmax)
            )
        )

        // Truth fill (full)
        ctx.fill(
            Path(roundedRect: CGRect(x: bx2, y: by, width: bw, height: bmax), cornerRadius: 5),
            with: .linearGradient(
                Gradient(colors: [truthColor.opacity(0.88), truthColor.opacity(0.32)]),
                startPoint: CGPoint(x: bx2, y: by),
                endPoint: CGPoint(x: bx2, y: by + bmax)
            )
        )

        // Gap bracket
        let predTop = by + bmax - predH
        let truthTop = by
        let loss = CGFloat(pow(1.0 - Double(predicted), 2))
        if loss > 0.01 {
            let midX = size.width * 0.50
            let pulseDash = CGFloat(0.6 + 0.4 * sin(t * 2.0))
            // Horizontal dashes at each level
            for lineY in [predTop, truthTop] {
                let x1 = bx1 + bw + 4
                let x2 = bx2 - 4
                var hp = Path(); hp.move(to: CGPoint(x: x1, y: lineY)); hp.addLine(to: CGPoint(x: x2, y: lineY))
                ctx.stroke(hp, with: .color(errColor.opacity(0.55 * pulseDash)),
                           style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
            }
            // Vertical gap line
            var vp = Path(); vp.move(to: CGPoint(x: midX, y: truthTop)); vp.addLine(to: CGPoint(x: midX, y: predTop))
            ctx.stroke(vp, with: .color(errColor.opacity(0.60 * pulseDash)),
                       style: StrokeStyle(lineWidth: 1.4, dash: [4, 3]))
            // Loss value
            ctx.draw(
                Text(String(format: "%.2f", loss)).font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(errColor.opacity(0.92)),
                at: CGPoint(x: midX, y: (truthTop + predTop) / 2 + 6)
            )
        }

        // Bar labels
        let labelY = by + bmax + 16
        ctx.draw(Text("PREDICTED").font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1)
            .foregroundStyle(predColor.opacity(0.60)), at: CGPoint(x: bx1 + bw / 2, y: labelY))
        ctx.draw(Text("TRUTH").font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1)
            .foregroundStyle(truthColor.opacity(0.60)), at: CGPoint(x: bx2 + bw / 2, y: labelY))
        ctx.draw(Text(String(format: "%.2f", predicted)).font(.custom("AvenirNext-DemiBold", size: 10))
            .foregroundStyle(.white.opacity(0.44)), at: CGPoint(x: bx1 + bw / 2, y: predTop - 10))
        ctx.draw(Text("1.00").font(.custom("AvenirNext-DemiBold", size: 10))
            .foregroundStyle(.white.opacity(0.44)), at: CGPoint(x: bx2 + bw / 2, y: truthTop - 10))
    }
}

// MARK: - Beat 2 · Backprop: error flows right → left

struct IntroBeat2Canvas: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawBeat2(&ctx, size: size, t: t)
            }
        }
    }

    private struct Layer {
        let xFrac: CGFloat; let count: Int
        let rgb: (CGFloat, CGFloat, CGFloat); let label: String
    }

    // Reversed — error comes from output (right) back to input (left)
    private let layers: [Layer] = [
        .init(xFrac: 0.92, count: 2, rgb: (0.85, 0.19, 0.38), label: "OUTPUT"),
        .init(xFrac: 0.68, count: 4, rgb: (1.00, 0.42, 0.21), label: "HIDDEN II"),
        .init(xFrac: 0.38, count: 4, rgb: (0.91, 0.72, 0.29), label: "HIDDEN I"),
        .init(xFrac: 0.11, count: 3, rgb: (0.63, 0.50, 1.00), label: "INPUT")
    ]

    private func nodePositions(_ size: CGSize) -> [[CGPoint]] {
        let vCenter = size.height * 0.52
        return layers.map { layer in
            let x = size.width * layer.xFrac
            let step = size.height * 0.14
            let totalH = step * CGFloat(layer.count - 1)
            return (0..<layer.count).map { i in
                CGPoint(x: x, y: vCenter - totalH / 2 + step * CGFloat(i))
            }
        }
    }

    private func drawBeat2(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let flow        = CGFloat(t * 0.30).truncatingRemainder(dividingBy: 1.0)
        let pos         = nodePositions(size)
        let activeLayer = min(layers.count - 1, Int(flow * CGFloat(layers.count)))
        let layerFrac   = (flow * CGFloat(layers.count)).truncatingRemainder(dividingBy: 1.0)
        let alpha: CGFloat = layerFrac < 0.5 ? layerFrac * 2 : 2 - layerFrac * 2

        // Title
        ctx.draw(
            Text("BACKPROPAGATION").font(.custom("AvenirNext-DemiBold", size: 10)).tracking(2.5)
                .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.60)),
            at: CGPoint(x: size.width / 2, y: 14)
        )

        // Dim connections
        for li in 0..<(pos.count - 1) {
            for a in pos[li] {
                for b in pos[li + 1] {
                    var p = Path(); p.move(to: a); p.addLine(to: b)
                    ctx.stroke(p, with: .color(.white.opacity(0.05)), lineWidth: 0.8)
                }
            }
        }

        // Active connection glow
        if activeLayer < pos.count - 1 {
            let c = layers[activeLayer + 1].rgb
            for a in pos[activeLayer] {
                for b in pos[activeLayer + 1] {
                    var p = Path(); p.move(to: a); p.addLine(to: b)
                    ctx.stroke(p, with: .color(Color(red: c.0, green: c.1, blue: c.2).opacity(alpha * 0.18)),
                               style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    ctx.stroke(
                        p,
                        with: .linearGradient(
                            Gradient(colors: [
                                Color(red: c.0, green: c.1, blue: c.2).opacity(alpha * 0.80),
                                Color(red: c.0, green: c.1, blue: c.2).opacity(alpha * 0.15)
                            ]),
                            startPoint: a, endPoint: b
                        ),
                        lineWidth: 1.5
                    )
                }
            }
        }

        // Nodes
        let pulse = CGFloat((sin(t * 5) + 1) / 2)
        for (li, layer) in layers.enumerated() {
            let isActive = li == activeLayer
            let c = layer.rgb
            let lp = isActive ? pulse : 0
            let r: CGFloat = isActive ? 9 : 7

            for nd in pos[li] {
                if isActive {
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: nd.x - r*3.2, y: nd.y - r*3.2, width: r*6.4, height: r*6.4)),
                        with: .radialGradient(
                            Gradient(colors: [Color(red: c.0, green: c.1, blue: c.2).opacity(0.25 + lp * 0.15), .clear]),
                            center: nd, startRadius: 0, endRadius: r * 3.2
                        )
                    )
                }
                ctx.fill(
                    Path(ellipseIn: CGRect(x: nd.x - r, y: nd.y - r, width: r*2, height: r*2)),
                    with: .color(Color(red: c.0, green: c.1, blue: c.2).opacity(isActive ? 0.30 + lp * 0.18 : 0.08))
                )
                ctx.stroke(
                    Path(ellipseIn: CGRect(x: nd.x - r, y: nd.y - r, width: r*2, height: r*2)),
                    with: .color(Color(red: c.0, green: c.1, blue: c.2).opacity(isActive ? 0.92 : 0.22)),
                    lineWidth: isActive ? 1.6 : 0.8
                )
            }

            if let first = pos[li].first {
                ctx.draw(
                    Text(layer.label).font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1.5)
                        .foregroundStyle(Color(red: c.0, green: c.1, blue: c.2).opacity(isActive ? 0.75 : 0.22)),
                    at: CGPoint(x: first.x, y: size.height - 12)
                )
            }
        }

        // Direction label
        ctx.draw(
            Text("←  error flows backward").font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1)
                .foregroundStyle(Color(red: 0.85, green: 0.19, blue: 0.38).opacity(0.42)),
            at: CGPoint(x: size.width / 2, y: size.height * 0.10)
        )
    }
}

// MARK: - Beat 3 · Hyper: loss curve morphing across 3 modes

struct IntroBeat3Canvas: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawBeat3(&ctx, size: size, t: t)
            }
        }
    }

    private struct SliderMode {
        let label: String
        let rgb: (CGFloat, CGFloat, CGFloat)
        let fn: (Double) -> Double
    }

    private let modes: [SliderMode] = [
        .init(label: "Learning Rate", rgb: (0.63, 0.50, 1.00)) { x in
            0.5 + 0.35 * sin(x * 18) * exp(-x * 1.5)
        },
        .init(label: "Batch Size", rgb: (0.24, 0.84, 0.75)) { x in
            0.85 * exp(-3 * x) + 0.08 + 0.10 * sin(x * 28) * (1 - x)
        },
        .init(label: "Epochs", rgb: (0.91, 0.72, 0.29)) { x in
            0.90 * exp(-4.5 * x) + 0.04
        }
    ]

    private func drawBeat3(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let phasePeriod = 120.0
        let phase = Int(t / phasePeriod * 3) % 3
        let pf    = CGFloat(t.truncatingRemainder(dividingBy: phasePeriod / 3) / (phasePeriod / 3))
        let prog  = min(1.0, pf * 2.2)

        let pad = (l: size.width * 0.09, r: size.width * 0.04,
                   t: size.height * 0.18, b: size.height * 0.22)
        let gw = size.width  - pad.l - pad.r
        let gh = size.height - pad.t - pad.b

        // Title
        ctx.draw(
            Text("HYPERPARAMETERS").font(.custom("AvenirNext-DemiBold", size: 10)).tracking(2.5)
                .foregroundStyle(.white.opacity(0.40)),
            at: CGPoint(x: size.width / 2, y: 14)
        )

        // Subtle grid lines
        for i in 1...3 {
            let y = pad.t + gh * CGFloat(i) / 4
            var gl = Path()
            gl.move(to: CGPoint(x: pad.l, y: y))
            gl.addLine(to: CGPoint(x: pad.l + gw, y: y))
            ctx.stroke(gl, with: .color(.white.opacity(0.04)), lineWidth: 0.8)
        }

        // Axes
        var axis = Path()
        axis.move(to: CGPoint(x: pad.l, y: pad.t))
        axis.addLine(to: CGPoint(x: pad.l, y: pad.t + gh))
        axis.addLine(to: CGPoint(x: pad.l + gw, y: pad.t + gh))
        ctx.stroke(axis, with: .color(.white.opacity(0.12)), lineWidth: 1)

        // Curve
        let sl = modes[phase]
        var pts: [CGPoint] = []
        for i in 0...100 {
            let x = Double(i) / 100
            guard CGFloat(x) <= prog else { break }
            let y = sl.fn(x)
            pts.append(CGPoint(x: pad.l + CGFloat(x) * gw,
                               y: pad.t + gh - CGFloat(min(y, 1.0)) * gh * 0.90))
        }

        if pts.count > 1 {
            let c = sl.rgb

            // Area fill under curve
            var area = Path()
            area.move(to: CGPoint(x: pad.l, y: pad.t + gh))
            for pt in pts { area.addLine(to: pt) }
            area.addLine(to: CGPoint(x: pts.last!.x, y: pad.t + gh))
            area.closeSubpath()
            ctx.fill(area, with: .linearGradient(
                Gradient(colors: [Color(red: c.0, green: c.1, blue: c.2).opacity(0.18),
                                  Color(red: c.0, green: c.1, blue: c.2).opacity(0.02)]),
                startPoint: CGPoint(x: 0, y: pad.t),
                endPoint: CGPoint(x: 0, y: pad.t + gh)
            ))

            // Line
            var curve = Path()
            curve.move(to: pts[0])
            for pt in pts.dropFirst() { curve.addLine(to: pt) }
            ctx.stroke(curve, with: .color(Color(red: c.0, green: c.1, blue: c.2).opacity(0.88)), lineWidth: 2.2)

            // Leading dot
            let last = pts.last!
            ctx.fill(
                Path(ellipseIn: CGRect(x: last.x - 4.5, y: last.y - 4.5, width: 9, height: 9)),
                with: .color(Color(red: c.0, green: c.1, blue: c.2).opacity(0.95))
            )
            // Dot glow
            ctx.fill(
                Path(ellipseIn: CGRect(x: last.x - 9, y: last.y - 9, width: 18, height: 18)),
                with: .radialGradient(
                    Gradient(colors: [Color(red: c.0, green: c.1, blue: c.2).opacity(0.28), .clear]),
                    center: last, startRadius: 0, endRadius: 9
                )
            )
        }

        // Axis labels
        ctx.draw(Text("LOSS").font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1)
            .foregroundStyle(.white.opacity(0.22)), at: CGPoint(x: pad.l - 4, y: pad.t + 6), anchor: .trailing)
        ctx.draw(Text("TRAINING STEPS").font(.custom("AvenirNext-DemiBold", size: 9)).tracking(1)
            .foregroundStyle(.white.opacity(0.16)), at: CGPoint(x: pad.l + gw / 2, y: pad.t + gh + 12))

        // Current mode label
        let c = modes[phase].rgb
        ctx.draw(
            Text("adjusting: \(sl.label)").font(.custom("AvenirNext-DemiBold", size: 10)).tracking(0.5)
                .foregroundStyle(Color(red: c.0, green: c.1, blue: c.2).opacity(0.82)),
            at: CGPoint(x: size.width / 2, y: size.height - 10)
        )

        // Mode indicator dots
        for i in 0..<3 {
            let m = modes[i]
            let dx = size.width * 0.32 + CGFloat(i) * size.width * 0.18
            let r: CGFloat = i == phase ? 5.5 : 3.5
            ctx.fill(
                Path(ellipseIn: CGRect(x: dx - r, y: size.height - 22 - r, width: r*2, height: r*2)),
                with: .color(Color(red: m.rgb.0, green: m.rgb.1, blue: m.rgb.2).opacity(i == phase ? 0.95 : 0.22))
            )
        }
    }
}

// MARK: - Beat 4 · Inspect: rune activation bars grouped by layer

struct IntroBeat4Canvas: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawBeat4(&ctx, size: size, t: t)
            }
        }
    }

    private let activations: [CGFloat] = [0.92, 0.41, 0.67, 0.83, 0.28, 0.74, 0.55, 0.91, 0.09]
    private let nodeIDs = ["x₁", "x₂", "x₃", "h₁", "h₂", "h₃", "h₄", "ŷ₁", "ŷ₂"]
    private let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0.91, 0.72, 0.29), (0.91, 0.72, 0.29), (0.91, 0.72, 0.29),
        (0.49, 0.38, 1.00), (0.49, 0.38, 1.00), (0.49, 0.38, 1.00), (0.49, 0.38, 1.00),
        (0.24, 0.84, 0.75), (0.24, 0.84, 0.75)
    ]
    // Layer group boundaries (for separators)
    private let layerLabels = [(index: 1, label: "INPUT"), (index: 4, label: "HIDDEN"), (index: 7, label: "OUTPUT")]

    private func drawBeat4(_ ctx: inout GraphicsContext, size: CGSize, t: TimeInterval) {
        let selected = Int(t * 0.18 * Double(activations.count)) % activations.count
        let pulse    = CGFloat((sin(t * 4) + 1) / 2)

        let n       = activations.count
        let padH    = size.width * 0.05
        let spacing = (size.width - padH * 2) / CGFloat(n)
        let bmax    = size.height * 0.55
        let baseY   = size.height * 0.78
        let barW: CGFloat = max(10, spacing * 0.55)

        // Title
        ctx.draw(
            Text("INSPECT NEURONS").font(.custom("AvenirNext-DemiBold", size: 10)).tracking(2.5)
                .foregroundStyle(.white.opacity(0.38)),
            at: CGPoint(x: size.width / 2, y: 14)
        )

        // Layer group labels (at top)
        let groupXs: [(CGFloat, String, (CGFloat, CGFloat, CGFloat))] = [
            (padH + spacing * 1.0, "INPUT",  (0.91, 0.72, 0.29)),
            (padH + spacing * 4.5, "HIDDEN", (0.49, 0.38, 1.00)),
            (padH + spacing * 7.5, "OUTPUT", (0.24, 0.84, 0.75))
        ]
        for (gx, glabel, gc) in groupXs {
            ctx.draw(
                Text(glabel).font(.custom("AvenirNext-DemiBold", size: 8)).tracking(1.5)
                    .foregroundStyle(Color(red: gc.0, green: gc.1, blue: gc.2).opacity(0.38)),
                at: CGPoint(x: gx, y: size.height * 0.18)
            )
        }

        // Subtle layer separators
        for sepX in [padH + spacing * 3, padH + spacing * 7] {
            var sp = Path()
            sp.move(to: CGPoint(x: sepX, y: size.height * 0.22))
            sp.addLine(to: CGPoint(x: sepX, y: baseY + 4))
            ctx.stroke(sp, with: .color(.white.opacity(0.06)), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
        }

        for i in 0..<n {
            let cx = padH + spacing * CGFloat(i) + spacing / 2
            let a  = activations[i]
            let isS = i == selected
            let c  = colors[i]

            // Track
            ctx.fill(
                Path(roundedRect: CGRect(x: cx - barW/2, y: baseY - bmax, width: barW, height: bmax), cornerRadius: 4),
                with: .color(.white.opacity(0.04))
            )

            // Fill
            let fillH = a * bmax
            let brightness: CGFloat = isS ? 0.90 + pulse * 0.10 : 0.38
            ctx.fill(
                Path(roundedRect: CGRect(x: cx - barW/2, y: baseY - fillH, width: barW, height: fillH), cornerRadius: 4),
                with: .linearGradient(
                    Gradient(colors: [
                        Color(red: c.0, green: c.1, blue: c.2).opacity(brightness),
                        Color(red: c.0, green: c.1, blue: c.2).opacity(0.10)
                    ]),
                    startPoint: CGPoint(x: cx, y: baseY - fillH),
                    endPoint: CGPoint(x: cx, y: baseY)
                )
            )

            // Glow for selected
            if isS {
                let hR: CGFloat = 18 + pulse * 8
                ctx.fill(
                    Path(ellipseIn: CGRect(x: cx - hR, y: baseY - fillH - hR/2, width: hR*2, height: hR*2)),
                    with: .radialGradient(
                        Gradient(colors: [Color(red: c.0, green: c.1, blue: c.2).opacity(0.32 + pulse * 0.16), .clear]),
                        center: CGPoint(x: cx, y: baseY - fillH), startRadius: 0, endRadius: hR
                    )
                )
                // Value above bar
                ctx.draw(
                    Text(String(format: "%.2f", a)).font(.custom("AvenirNext-DemiBold", size: 10))
                        .foregroundStyle(Color(red: c.0, green: c.1, blue: c.2).opacity(0.92)),
                    at: CGPoint(x: cx, y: baseY - fillH - 12)
                )
            }

            // Node ID label
            ctx.draw(
                Text(nodeIDs[i]).font(.system(size: 10, weight: .medium, design: .serif))
                    .foregroundStyle(Color(red: c.0, green: c.1, blue: c.2).opacity(isS ? 0.90 : 0.30)),
                at: CGPoint(x: cx, y: baseY + 13)
            )
        }
    }
}

// MARK: - Shared style modifier (kept for backwards-compatibility, unused by new template)

extension View {
    func beatCanvasStyle() -> some View {
        self
            .frame(width: 260, height: 160)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.03, green: 0.02, blue: 0.09), Color(red: 0.06, green: 0.03, blue: 0.16)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(red: 0.49, green: 0.38, blue: 1.0).opacity(0.22), lineWidth: 1)
            )
    }
}
