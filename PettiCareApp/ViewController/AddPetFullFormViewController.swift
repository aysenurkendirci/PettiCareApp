import UIKit
import SwiftData

final class AddPetFullFormViewController: UIViewController {
    var onRoutineCompleted: ((Pet) -> Void)?
    var modelContext: ModelContext?
    var isFromSplash: Bool = false

    private let nameInput = PetNameInputView()
    private let typePicker = PetTypePickerView()
    private let breedPicker = PetBreedPickerView()
    private let birthDatePicker = PetBirthDatePickerView()
    private let sizeInput = PetSizeInputView()
    private let colorPicker = PetColorPickerView()
    private let featuresInput = PetFeaturesView()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kaydet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 60/255, blue: 130/255, alpha: 1)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 20
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let gradientBackgroundView = GradientBackgroundView()
    private let viewModel = AddPetViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Evcil Hayvan Bilgileri"
        view.backgroundColor = .clear
        setupGradientBackground()
        setupLayout()
        setupCallbacks()
        setupNavigationItem()

        viewModel.modelContext = modelContext
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
    }

    private func setupGradientBackground() {
        view.addSubview(gradientBackgroundView)
        gradientBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        view.sendSubviewToBack(gradientBackgroundView)
    }

    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let stack = UIStackView(arrangedSubviews: [
            wrapInCard(nameInput),
            wrapInCard(typePicker),
            wrapInCard(breedPicker),
            wrapInCard(birthDatePicker),
            wrapInCard(sizeInput),
            wrapInCard(colorPicker),
            wrapInCard(featuresInput),
            saveButton
        ])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    private func wrapInCard(_ view: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.05
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4

        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])

        return container
    }

    private func setupCallbacks() {
        nameInput.onNameEntered = { [weak self] name in
            self?.viewModel.pet.name = name
        }

        // Tür seçimi normalize
        typePicker.onTypeSelected = { [weak self] typeText in
            guard let self else { return }
            if let t = PetType(rawValue: typeText) ?? PetType.fromDisplayName(typeText) {
                self.viewModel.pet.type = t.rawValue
                self.breedPicker.updateBreedList(for: t.displayName) // "Kedi", "Köpek", ...

            } else {
                self.viewModel.pet.type = ""
            }
        }

        breedPicker.onBreedSelected = { [weak self] breed in
            self?.viewModel.pet.breed = breed
        }
        birthDatePicker.onDateSelected = { [weak self] date in
            self?.viewModel.pet.birthDate = date
        }
        sizeInput.onSizeEntered = { [weak self] weight, height in
            self?.viewModel.pet.weight = weight
            self?.viewModel.pet.height = height
        }
        colorPicker.onColorSelected = { [weak self] color in
            self?.viewModel.pet.color = color
        }
    }

    @objc private func handleSave() {
        let pet = viewModel.pet

        guard
            !pet.name.isEmpty,
            !pet.type.isEmpty,
            !pet.breed.isEmpty,
            !pet.color.isEmpty,
            pet.birthDate != Date.distantPast,
            !pet.weight.isEmpty,
            !pet.height.isEmpty,
            let features = featuresInput.selectedFeatures
        else {
            showAlert(title: "Eksik Bilgi", message: "Lütfen tüm alanları doldurun.")
            return
        }

        guard let t = PetType(rawValue: pet.type) ?? PetType.fromDisplayName(pet.type) else {
            showAlert(title: "Tür Seçilmedi", message: "Lütfen evcil hayvan türünü seçiniz.")
            return
        }

        viewModel.pet.details = features

        if let savedPet = viewModel.savePet(
            name: pet.name,
            type: t,
            breed: pet.breed,
            birthDate: pet.birthDate,
            weight: pet.weight,
            height: pet.height,
            color: pet.color,
            details: pet.details,
            imageData: pet.imageData
        ) {
            if isFromSplash {
                let routineVC = PetRoutineViewController()
                routineVC.preselectedPetType = t.displayName   // "Kedi", "Köpek", "Kuş", "Balık"
                routineVC.savedPet = savedPet

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = UINavigationController(rootViewController: routineVC)
                    window.makeKeyAndVisible()
                }
            } else {
                onRoutineCompleted?(savedPet)
                navigationController?.popViewController(animated: true)
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
