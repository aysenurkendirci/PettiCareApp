import UIKit

final class PetColorPickerView: UIView {

    private let label: UILabel = {
        let label = UILabel()
        label.text = "Evcil hayvanınızın rengi"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private let colorButtonsStack = UIStackView()
    private(set) var selectedColor: String?

    var onColorSelected: ((String) -> Void)?

    private let colors: [(name: String, color: UIColor)] = [
        ("Beyaz", .white),
        ("Siyah", .black),
        ("Kahverengi", .brown),
        ("Sarı", .yellow),
        ("Gri", .gray),
        ("Turuncu", .orange)
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .clear

        colorButtonsStack.axis = .horizontal
        colorButtonsStack.alignment = .fill
        colorButtonsStack.distribution = .fillEqually
        colorButtonsStack.spacing = 10
        colorButtonsStack.translatesAutoresizingMaskIntoConstraints = false

        colors.forEach { color in
            let button = UIButton(type: .system)
            button.backgroundColor = color.color
            button.setTitle("", for: .normal) // yazıyı kaldır
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray5.cgColor
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            button.accessibilityIdentifier = color.name // sadece kodda tanımak için
            colorButtonsStack.addArrangedSubview(button)
        }

        let stack = UIStackView(arrangedSubviews: [label, colorButtonsStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @objc private func colorButtonTapped(_ sender: UIButton) {
        guard
            let index = colorButtonsStack.arrangedSubviews.firstIndex(of: sender),
            index < colors.count
        else { return }

        let selected = colors[index]
        selectedColor = selected.name
        onColorSelected?(selected.name)

        // vurgulama
        colorButtonsStack.arrangedSubviews.forEach {
            ($0 as? UIButton)?.layer.borderWidth = 1
            ($0 as? UIButton)?.layer.borderColor = UIColor.systemGray5.cgColor
        }

        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.systemBlue.cgColor
    }
}
