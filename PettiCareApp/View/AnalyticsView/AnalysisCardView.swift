import UIKit

final class AnalysisCardView: UIView {
    let titleLabel = UILabel()
    let contentContainer = UIView()
    let badge = MetricBadgeView()

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 12
        layer.shadowOffset = .init(width: 0, height: 6)

        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label

        let stack = UIStackView(arrangedSubviews: [titleLabel, contentContainer])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack); addSubview(badge)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            badge.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            badge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
}
