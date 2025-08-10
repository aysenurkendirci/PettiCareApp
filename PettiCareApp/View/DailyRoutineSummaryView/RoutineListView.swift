import UIKit

final class RoutineListView: UIView {
    // Dışarıya bildirim
    var onItemTapped: ((Int, String) -> Void)?

    // İç düzen
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private(set) var itemViews: [RoutineItemView] = []
    private var heightConstraint: NSLayoutConstraint?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Public API
    func setItems(_ models: [RoutineItemView.Model]) {
        // Temizle
        itemViews.forEach { $0.removeFromSuperview() }
        itemViews.removeAll()

        // Kartları ekle
        for (idx, model) in models.enumerated() {
            var m = model
            m.tapHandler = { [weak self] in
                self?.onItemTapped?(idx, model.title)
            }
            let item = RoutineItemView(model: m)
            item.layer.cornerRadius = 12
            item.clipsToBounds = true
            stackView.addArrangedSubview(item)
            itemViews.append(item)
        }

        // İçeriğe göre kendi yüksekliğini ayarla (stack içinde 0'a düşmesin)
        layoutIfNeeded()
        let target = CGSize(width: bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width - 32,
                            height: UIView.layoutFittingCompressedSize.height)
        let contentHeight = stackView.systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        heightConstraint?.isActive = false
        heightConstraint = heightAnchor.constraint(equalToConstant: contentHeight)
        heightConstraint?.isActive = true

        invalidateIntrinsicContentSize()
        setNeedsLayout()
        layoutIfNeeded()
    }

    func updateSubtitle(at index: Int, to text: String?) {
        guard itemViews.indices.contains(index) else { return }
        itemViews[index].updateSubtitle(text)
    }

    // MARK: - Private
    private func setupUI() {
        backgroundColor = .clear

        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        scrollView.isScrollEnabled = false

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero

        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Başlangıçta min yükseklik (stack içinde 0 olmasın)
        heightConstraint = heightAnchor.constraint(equalToConstant: 1)
        heightConstraint?.priority = .defaultLow
        heightConstraint?.isActive = true
    }
}
