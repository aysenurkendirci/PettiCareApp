import UIKit

final class PetProfileCardView: UIView {

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let breedLabel = UILabel()
    private let detailsStack = UIStackView()

    init(pet: Pet) {
        super.init(frame: .zero)
        setupUI()
        configure(with: pet) // 📌 Pet bilgilerini doldur
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white // 📌 Rutin kartı gibi beyaz
        layer.cornerRadius = 20
        layer.masksToBounds = false

        // 📌 Gölge efekti (rutin karttaki gibi)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75 // 150/2 yuvarlak foto

        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .black

        breedLabel.font = .systemFont(ofSize: 18)
        breedLabel.textColor = .darkGray
        breedLabel.textAlignment = .center

        detailsStack.axis = .vertical
        detailsStack.spacing = 12

        [imageView, nameLabel, breedLabel, detailsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            breedLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            breedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            detailsStack.topAnchor.constraint(equalTo: breedLabel.bottomAnchor, constant: 20),
            detailsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            detailsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    // 📌 Pet bilgilerini dolduran fonksiyon
    private func configure(with pet: Pet) {
        nameLabel.text = pet.name
        breedLabel.text = pet.breed
        imageView.image = pet.imageData != nil
            ? UIImage(data: pet.imageData!)
            : UIImage(systemName: "photo")

        detailsStack.addArrangedSubview(makeRow(title: "Renk", value: pet.color))
        detailsStack.addArrangedSubview(makeRow(title: "Doğum Günü", value: formatDate(pet.birthDate)))
        detailsStack.addArrangedSubview(makeRow(title: "Boy", value: pet.height))
        detailsStack.addArrangedSubview(makeRow(title: "Ağırlık", value: pet.weight))
        detailsStack.addArrangedSubview(makeRow(title: "Özellikler", value: pet.details))
    }

    private func makeRow(title: String, value: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.text = title
        titleLabel.textColor = .darkGray

        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.text = value
        valueLabel.textColor = .black
        valueLabel.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
