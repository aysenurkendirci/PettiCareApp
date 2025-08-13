import UIKit

final class BarChartView: UIView {
    var values: [Double] = [] { didSet { setNeedsDisplay() } } // 0...1
    var captions: [String] = []                                // opsiyonel

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !values.isEmpty else { return }
        let w = rect.width, h = rect.height
        let n = values.count
        let spacing: CGFloat = 10
        let barW = (w - CGFloat(n + 1)*spacing) / CGFloat(n)

        // grid
        ctx.setLineWidth(0.5)
        ctx.setStrokeColor(UIColor.systemGray4.cgColor)
        for i in 1...3 {
            let y = h * CGFloat(i) / 4
            ctx.move(to: .init(x: 0, y: y)); ctx.addLine(to: .init(x: w, y: y))
        }
        ctx.strokePath()

        // bars
        for (i, v) in values.enumerated() {
            let vv = max(0, min(1, v))
            let x = spacing + CGFloat(i)*(barW + spacing)
            let bh = (h - 16) * CGFloat(vv)
            let y = h - 16 - bh
            let r = CGRect(x: x, y: y, width: barW, height: bh)
            UIBezierPath(roundedRect: r, cornerRadius: 6).fill()
            if i < captions.count {
                let s = captions[i] as NSString
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let size = s.size(withAttributes: attrs)
                s.draw(at: CGPoint(x: x + (barW-size.width)/2, y: h - size.height), withAttributes: attrs)
            }
        }
    }
}
