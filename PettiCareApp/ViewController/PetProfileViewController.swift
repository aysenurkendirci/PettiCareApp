import UIKit
import SwiftData

final class PetProfileViewController: UIViewController {

    var modelContext: ModelContext?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let addPetButton: GradientButton = {
        let button = GradientButton(type: .system)
        button.setTitle("Evcil Hayvan Ekle", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let bg = GradientBackgroundView()
        bg.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(bg, at: 0)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: view.topAnchor),
            bg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        setupLayout()
        loadAllPets()

        view.addSubview(addPetButton)
        NSLayoutConstraint.activate([
            addPetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addPetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addPetButton.widthAnchor.constraint(equalToConstant: 220),
            addPetButton.heightAnchor.constraint(equalToConstant: 52)
        ])
        addPetButton.addTarget(self, action: #selector(addPetButtonTapped), for: .touchUpInside)
    }

    private func setupLayout() {
        title = "Profil"

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func loadAllPets() {
        guard let context = modelContext else { return }
        do {
            let descriptor = FetchDescriptor<Pet>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let pets = try context.fetch(descriptor)

            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            for pet in pets {
                let card = PetProfileCardView(pet: pet, modelContext: context)
                card.translatesAutoresizingMaskIntoConstraints = false
                card.onImageUpdated = { [weak self] in
                    // İstersen yalnızca o kartı güncelle; en kolayı tüm listeyi tazelemek:
                    self?.loadAllPets()
                }
                stackView.addArrangedSubview(card)
            }
        } catch {
            print("❌ Pet verileri alınamadı: \(error.localizedDescription)")
        }

    }

    @objc private func addPetButtonTapped() {
        let addVC = AddPetFullFormViewController()
        addVC.modelContext = self.modelContext
        addVC.isFromSplash = false
        addVC.onRoutineCompleted = { [weak self] _ in
            self?.loadAllPets()
        }
        navigationController?.pushViewController(addVC, animated: true)
    }
    
}
