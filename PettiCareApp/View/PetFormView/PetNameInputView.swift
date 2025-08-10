import UIKit

final class PetNameInputView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Evcil hayvanınızın adı"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Evcil Hayvanınızın adını giriniz"
        tf.borderStyle = .roundedRect
        tf.setLeftPadding(12)
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    var onNameEntered: ((String) -> Void)?
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
            setupObserver()
        }
    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

       private func setupView() {
           let stack = UIStackView(arrangedSubviews: [titleLabel, nameField])
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

       private func setupObserver() {
           nameField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
       }

       @objc private func textChanged() {
           onNameEntered?(nameField.text ?? "")
       }
   }


