import UIKit

/// Kullanıcının evcil hayvan için ağırlık ve boy bilgisini girdiği özel view
final class PetSizeInputView: UIView {
    
    // Başlık etiketi
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ağırlık ve Boy"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label // Koyu/açık temaya göre otomatik uyumlu
        return label
    }()
    
    // Ağırlık için TextField
    private let weightField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Ağırlık (kg)"
        tf.setLeftPadding(12) // soldan boşluk
        tf.layer.cornerRadius = 10
        tf.layer.borderColor = UIColor.systemGray5.cgColor
        tf.layer.borderWidth = 1
        tf.backgroundColor = .white
        tf.keyboardType = .decimalPad // Sayısal klavye
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    // Boy için TextField
    private let heightField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Boy (cm)"
        tf.setLeftPadding(12)
        tf.layer.cornerRadius = 10
        tf.layer.borderColor = UIColor.systemGray5.cgColor
        tf.layer.borderWidth = 1
        tf.backgroundColor = .white
        tf.keyboardType = .decimalPad
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    // Dışarıdan erişim için computed property
    var weight: String? { weightField.text }
    var height: String? { heightField.text }
    
    /// Kullanıcı giriş yaptıkça yeni değerleri dışarıya bildirmek için
    var onSizeEntered: ((String, String) -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Yapılandırması
    private func setupView() {
        backgroundColor = .clear
        
        // Ağırlık ve Boy alanlarını üst üste diz
        let inputStack = UIStackView(arrangedSubviews: [weightField, heightField])
        inputStack.axis = .vertical
        inputStack.spacing = 12
        
        // Başlık ve input alanlarını içeren ana stack
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, inputStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        // StackView'ı bu view’a sabitle
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - TextField’lar değiştiğinde tetiklenir
    private func setupObservers() {
        [weightField, heightField].forEach {
            $0.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        }
    }
    
    @objc private func textChanged() {
        // Her değişimde girilen değerleri dışarıya gönder
        onSizeEntered?(weight ?? "", height ?? "")
    }
}

// MARK: - UITextField için soldan padding eklentisi
extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 0))
        leftView = paddingView
        leftViewMode = .always
    }
}
