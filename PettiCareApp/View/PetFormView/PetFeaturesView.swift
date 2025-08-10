import UIKit

class PetFeaturesView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Evcil Hayvan Özellikleri"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private let featuresTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.text = "Açıklama girin..."
        textView.textColor = .lightGray
        return textView
    }()

    var selectedFeatures: String? {
        let text = featuresTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty || text == "Açıklama girin..." ? nil : text
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupTextViewPlaceholderBehavior()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, featuresTextView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            featuresTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func setupTextViewPlaceholderBehavior() {
        featuresTextView.delegate = self
    }
}

extension PetFeaturesView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Açıklama girin..." {
            textView.text = ""
            textView.textColor = .label
        }
    }
}
