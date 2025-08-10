import UIKit

final class RoutineNameInputView: UIView {

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Rutinin Adı"
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.clearButtonMode = .whileEditing
        tf.textColor = .black
        tf.tintColor = .systemPurple
        tf.translatesAutoresizingMaskIntoConstraints = false

        // Daha içeri gömülmüş his için iç padding
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        tf.leftViewMode = .always

        return tf
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        // Kart görünüm
        view.layer.cornerRadius = 14
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.07
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(textField)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    var routineName: String {
        return textField.text ?? ""
    }
}
