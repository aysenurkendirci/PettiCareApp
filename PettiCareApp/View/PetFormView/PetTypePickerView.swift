import UIKit

/// Kullanıcının evcil hayvan türünü seçmesi için özel bir UIView bileşeni
class PetTypePickerView: UIView {
    
    /// Üstte görünen başlık etiketi
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Evcil hayvanınızın türü"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    /// Seçilebilecek hayvan türleri
    private let options = ["Kedi", "Köpek", "Kuş", "Balık"]
    
    /// Oluşturulan butonları saklayan dizi (her tür için bir buton)
    private var buttons: [UIButton] = []
    
    /// Seçilen tür (dışarıdan erişilebilir)
    var selectedType: String?
    
    /// Seçim yapıldığında ViewController'a bilgi ileten closure
    var onTypeSelected: ((String) -> Void)?
    
    /// Butonları yatayda tutan StackView
    private let stackView = UIStackView()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Görünüm Yapılandırması
    private func setupView() {
        // StackView ayarları
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        // Her tür için bir buton oluştur ve stack'e ekle
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray3.cgColor
            button.backgroundColor = .white
            button.addTarget(self, action: #selector(typeSelected(_:)), for: .touchUpInside)
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        // Label ve StackView dikey bir yapı içinde
        let verticalStack = UIStackView(arrangedSubviews: [label, stackView])
        verticalStack.axis = .vertical
        verticalStack.spacing = 10
        
        // Ana görünüme ekle
        addSubview(verticalStack)
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    // MARK: - Buton Seçildiğinde Çalışır
    @objc private func typeSelected(_ sender: UIButton) {
        // Önce tüm butonların seçimini sıfırla
        buttons.forEach {
            $0.backgroundColor = .white
            $0.setTitleColor(.black, for: .normal)
        }
        
        // Seçilen butonu vurgula
        sender.backgroundColor = UIColor.systemIndigo
        sender.setTitleColor(.white, for: .normal)
        
        // Seçimi güncelle ve dışarıya bildir
        selectedType = sender.title(for: .normal)
        onTypeSelected?(selectedType!)
    }
}
