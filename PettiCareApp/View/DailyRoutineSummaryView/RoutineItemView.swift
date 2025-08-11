import UIKit

final class RoutineItemView: UIControl {

    struct Model {
        let icon: UIImage?
        let title: String
        let frequencyText: String     // "Günde 2 kez"
        let progressText: String      // "2/2"
        let isCompleted: Bool
        let accessoryIcon: UIImage?
        var tapHandler: (() -> Void)?
    }

    private var model: Model

    // UI
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let frequencyLabel = UILabel()
    private let progressPill = UILabel()
    private let accessoryView = UIImageView()

    // MARK: - Init
    init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        setupUI()
        apply(model)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Public
    func updateSubtitle(_ text: String?) {
        frequencyLabel.text = text
    }

    // MARK: - UI
    private func setupUI() {
        layer.cornerRadius = 16
        clipsToBounds = true
        backgroundColor = .secondarySystemBackground

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemBlue

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        frequencyLabel.translatesAutoresizingMaskIntoConstraints = false
        frequencyLabel.font = .systemFont(ofSize: 15, weight: .regular)
        frequencyLabel.textColor = .secondaryLabel
        frequencyLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        progressPill.translatesAutoresizingMaskIntoConstraints = false
        progressPill.font = .systemFont(ofSize: 13, weight: .semibold)
        progressPill.textColor = .white
        progressPill.textAlignment = .center
        progressPill.layer.cornerRadius = 12
        progressPill.layer.masksToBounds = true
        progressPill.backgroundColor = .systemGray2
        progressPill.setContentHuggingPriority(.required, for: .horizontal)
        progressPill.setContentCompressionResistancePriority(.required, for: .horizontal)
        progressPill.heightAnchor.constraint(equalToConstant: 24).isActive = true
        progressPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        progressPill.insetsLayoutMarginsFromSafeArea = false

        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.contentMode = .scaleAspectFit
        accessoryView.tintColor = .tertiaryLabel

        let vStack = UIStackView(arrangedSubviews: [titleLabel, makeBottomRow()])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(vStack)
        addSubview(accessoryView)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            accessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            accessoryView.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessoryView.widthAnchor.constraint(equalToConstant: 18),
            accessoryView.heightAnchor.constraint(equalToConstant: 18),

            vStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            vStack.trailingAnchor.constraint(equalTo: accessoryView.leadingAnchor, constant: -12),
        ])
    }

    private func makeBottomRow() -> UIView {
        let row = UIStackView(arrangedSubviews: [frequencyLabel, UIView(), progressPill])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
        return row
    }

    private func apply(_ m: Model) {
        iconView.image = m.icon
        titleLabel.text = m.title
        frequencyLabel.text = m.frequencyText
        progressPill.text = " \(m.progressText) " // pill daha hoş dursun diye padding

        accessoryView.image = m.accessoryIcon

        // Tamamlandı ise tüm kart yeşil + metinler beyaz
        if m.isCompleted {
            backgroundColor = .systemFill
            titleLabel.textColor = .white
            frequencyLabel.textColor = UIColor.white.withAlphaComponent(0.85)
            iconView.tintColor = .white
            accessoryView.tintColor = UIColor.white.withAlphaComponent(0.9)
            progressPill.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            progressPill.textColor = .white
        } else {
            backgroundColor = .secondarySystemBackground
            titleLabel.textColor = .label
            frequencyLabel.textColor = .secondaryLabel
            iconView.tintColor = .systemBlue
            accessoryView.tintColor = .tertiaryLabel
            progressPill.backgroundColor = .systemGray2
            progressPill.textColor = .white
        }
    }

    // MARK: - Actions
    @objc private func didTap() {
        model.tapHandler?()
    }
}
