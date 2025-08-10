import UIKit

// Her bir rutin (örneğin yürüyüş, yemek) için kart görünümü
final class RoutineCardView: UIView {

    // Kart üzerindeki başlık (örnek: "Beslenme")
    private let titleLabel = UILabel()

    // Kart üzerindeki simge
    private let iconImageView = UIImageView()

    // Bu closure, kullanıcı karta tıkladığında tetiklenir
    var onRoutineTapped: (() -> Void)?

    // View oluşturulurken başlık ve ikon alır
    init(title: String, icon: UIImage) {
        super.init(frame: .zero)
        setupView(title: title, icon: icon)
        
        // Kart tıklanabilir yapılır
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    // Storyboard desteklenmediği için zorunlu fakat kullanılmıyor
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // View'in tasarımı burada yapılır
    private func setupView(title: String, icon: UIImage) {
        layer.cornerRadius = 12                                // Kenarları yuvarla
        backgroundColor = UIColor.white                        // Arka plan beyaz
        layer.borderColor = UIColor.systemGray4.cgColor        // İnce gri kenarlık
        layer.borderWidth = 1
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60).isActive = true // Sabit yükseklik

        // İkon ayarları
        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .systemBlue // Renk (SF Symbol için geçerli)

        // Başlık ayarları
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // İkon ve başlık yan yana yatay stack'e alınır
        let stack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        // Stack için AutoLayout
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // Kart tıklanırsa dışarıya haber ver
    @objc private func handleTap() {
        onRoutineTapped?()
    }
}
