import UIKit

final class RoutineItemView: UIView {

    // MARK: - Public
    struct Model {
        var icon: UIImage?
        var title: String
        var subtitle: String?
        var accessoryIcon: UIImage?
        var isEnabled: Bool
        var tapHandler: (() -> Void)?   // <- let -> var

        init(icon: UIImage?,
             title: String,
             subtitle: String? = nil,
             accessoryIcon: UIImage? = nil,
             isEnabled: Bool = true,
             tapHandler: (() -> Void)? = nil) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.accessoryIcon = accessoryIcon
            self.isEnabled = isEnabled
            self.tapHandler = tapHandler
        }
    }

    // Dilersen direkt model ile init edebil
    convenience init(model: Model) {
        self.init(frame: .zero)
        configure(with: model)
    }

    // MARK: - UI
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textStack = UIStackView()
    private let accessoryImageView = UIImageView()
    private let container = UIStackView()
    private var minHeightConstraint: NSLayoutConstraint?

    // MARK: - Public updaters (RoutineListView bu metodları kullanabilir)
    func configure(with model: Model) {
        updateIcon(model.icon)
        updateTitle(model.title)
        updateSubtitle(model.subtitle)
        updateAccessory(model.accessoryIcon)
        setEnabled(model.isEnabled)
        tapHandler = model.tapHandler
    }

    func updateSubtitle(_ text: String?) {
        subtitleLabel.text = text
        subtitleLabel.isHidden = (text == nil || text?.isEmpty == true)
        setNeedsLayout()
    }

    func updateTitle(_ text: String) {
        titleLabel.text = text
    }

    func updateIcon(_ image: UIImage?) {
        iconView.image = image
    }

    func updateAccessory(_ image: UIImage?) {
        accessoryImageView.image = image
        accessoryImageView.isHidden = (image == nil)
    }

    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }

    var tapHandler: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Private
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        clipsToBounds = true

        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 1

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.isHidden = true

        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .fill
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        accessoryImageView.contentMode = .scaleAspectFit
        accessoryImageView.setContentHuggingPriority(.required, for: .horizontal)
        accessoryImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        accessoryImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        accessoryImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        accessoryImageView.isHidden = true

        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 12
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        container.addArrangedSubview(iconView)
        container.addArrangedSubview(textStack)
        container.addArrangedSubview(accessoryImageView)

        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // height >= 80 (eşit değil) — kırılmaları önler
        minHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        minHeightConstraint?.priority = .defaultHigh
        minHeightConstraint?.isActive = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    @objc private func didTap() {
        tapHandler?()
    }
}
