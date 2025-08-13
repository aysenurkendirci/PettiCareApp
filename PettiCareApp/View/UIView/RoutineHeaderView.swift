import UIKit

final class PetRoutineHeaderView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        // Başlık
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 1
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy).withRoundedDesign()

        // Subtitle
        subtitleLabel.text = "Evcil dostunuz için günlük bakım planı"
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Hafif gölge (gradient üstünde okunurluk)
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.18
        titleLabel.layer.shadowRadius = 6
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    /// Örn: 🐱 Misket Rutinleri  ya da sadece 🐱 Kedi Rutinleri
    func configure(name: String?, type: PetType) {
        let display = (name?.isEmpty == false) ? name! : type.fullDisplayName
        titleLabel.text = "\(type.emoji) \(display) Rutinleri"
    }

    func setSubtitle(_ text: String) { subtitleLabel.text = text }
}

private extension UIFont {
    func withRoundedDesign() -> UIFont {
        guard let desc = fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: desc, size: pointSize)
    }
}
