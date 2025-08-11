import UIKit
import SwiftData
import PhotosUI

final class PetProfileCardView: UIView, PHPickerViewControllerDelegate {

    // MARK: - UI
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let breedLabel = UILabel()
    private let detailsStack = UIStackView()
    private let editButton = UIButton(type: .system)

    // MARK: - Data
    private let vm: PetProfileViewModel
    private weak var modelContext: ModelContext?
    var onImageUpdated: (() -> Void)?

    // MARK: - Init
    init(pet: Pet, modelContext: ModelContext?) {
        self.vm = PetProfileViewModel(pet: pet)
        self.modelContext = modelContext
        super.init(frame: .zero)
        setupUI()
        configure() // viewmodel'den doldur
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhoto)))

        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .black

        breedLabel.font = .systemFont(ofSize: 18)
        breedLabel.textColor = .darkGray
        breedLabel.textAlignment = .center

        detailsStack.axis = .vertical
        detailsStack.spacing = 12

        // Kamera butonu (foto sağ alt)
        editButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        editButton.tintColor = .white
        editButton.backgroundColor = .systemBlue
        editButton.layer.cornerRadius = 18
        editButton.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
        editButton.translatesAutoresizingMaskIntoConstraints = false

        [imageView, nameLabel, breedLabel, detailsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        addSubview(editButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            // edit button
            editButton.widthAnchor.constraint(equalToConstant: 36),
            editButton.heightAnchor.constraint(equalToConstant: 36),
            editButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 6),
            editButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),

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

    private func configure() {
        // Başlıklar
        nameLabel.text = vm.name
        breedLabel.text = vm.breed

        // Görsel
        imageView.image = vm.image.withRenderingMode(.alwaysOriginal)

        // Detaylar
        detailsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        detailsStack.addArrangedSubview(makeRow(title: "Renk", value: vm.color))
        detailsStack.addArrangedSubview(makeRow(title: "Doğum Günü", value: vm.birthDateFormatted))
        detailsStack.addArrangedSubview(makeRow(title: "Boy", value: vm.height))
        detailsStack.addArrangedSubview(makeRow(title: "Ağırlık", value: vm.weight))
        detailsStack.addArrangedSubview(makeRow(title: "Özellikler", value: vm.details))
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
        valueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.distribution = .equalSpacing
        return stack
    }

    // MARK: - Photo picker
    @objc private func changePhoto() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        parentViewController?.present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self = self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                // 1) SwiftData'ya yaz
                self.vm.updateImage(image, in: self.modelContext)
                // 2) UI'ı anında güncelle
                self.imageView.image = image.withRenderingMode(.alwaysOriginal)
                // 3) Üste haber ver (listeyi tazelemek istersen)
                self.onImageUpdated?()
            }
        }
    }
}

// View içinden sunan VC’yi bulmak için küçük yardımcı
private extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self.next, next: { $0?.next })
            .first { $0 is UIViewController } as? UIViewController
    }
}
