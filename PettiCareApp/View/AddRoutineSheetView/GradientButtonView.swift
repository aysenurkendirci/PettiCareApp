import UIKit

final class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
        layer.cornerRadius = 14
        clipsToBounds = true

        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.45, blue: 0.30, alpha: 1).cgColor,
            UIColor(red: 0.45, green: 0.20, blue: 0.60, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 14

        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
