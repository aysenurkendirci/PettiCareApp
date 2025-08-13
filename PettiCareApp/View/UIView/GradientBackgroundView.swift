import UIKit

final class GradientBackgroundView: UIView {
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        gradient.type = .axial
        gradient.colors = [
            UIColor(red: 255/255, green: 140/255, blue: 90/255, alpha: 1).cgColor,   // Daha yumuşak turuncu
            UIColor(red: 245/255, green: 90/255,  blue: 150/255, alpha: 1).cgColor,  // Arada pembe ton
            UIColor(red: 150/255, green: 80/255,  blue: 220/255, alpha: 1).cgColor   // Daha yumuşak mor
        ]
        
        // Hafif çapraz geçiş
        gradient.startPoint = CGPoint(x: 0, y: 0.2)
        gradient.endPoint   = CGPoint(x: 1, y: 0.8)
        
        // Ton geçişlerini yumuşatma
        gradient.locations  = [0.0, 0.5, 1.0]
        
        layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.contentsScale = UIScreen.main.scale
    }
}
