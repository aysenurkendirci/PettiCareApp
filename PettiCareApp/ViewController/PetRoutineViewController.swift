import UIKit
import SwiftData

final class PetRoutineViewController: UIViewController {
    var preselectedPetType: String?
    var modelContext: ModelContext?
    var savedPet: Pet?

    private let petTypeSelector = PetTypeSelectorView()
    private let routineListView = RoutineListView()
    private let viewModel = RoutineViewModel()
    private let gradientBackgroundView = GradientBackgroundView()

    private let petTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Evcil dostunuz için günlük bakım planı"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("📦 modelContext geldi mi? -> \(modelContext != nil)")

        viewModel.modelContext = modelContext
        view.backgroundColor = .clear

        setupGradientBackground()
        setupUI()
        setupBindings()
        setupInitialState()
        setupNavigationItem()

        viewModel.fetchPets()
    }

    // MARK: - UI
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
        let pawIcon = UIImage(systemName: "pawprint")
        let rightButton = UIBarButtonItem(image: pawIcon, style: .plain, target: self, action: #selector(didTapPetSelector))
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightButton

        let plusIcon = UIImage(systemName: "plus")
        let leftButton = UIBarButtonItem(image: plusIcon, style: .plain, target: self, action: #selector(didTapAddRoutine))
        leftButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftButton
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            petTypeTitleLabel,
            subtitleLabel,
            petTypeSelector,
            routineListView
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupBindings() {
        // 1) List item tap → sıklık sheet
        routineListView.onItemTapped = { [weak self] index, title in
            self?.presentFrequencyOptions(for: index, title: title)
        }

        // 2) Tür picker’ı → türe göre filtrele
        petTypeSelector.onSelectionChanged = { [weak self] newType in
            guard let self else { return }
            self.viewModel.selectPetType(newType)
            self.petTypeTitleLabel.text = "\(newType.fullDisplayName) Rutinleri"
        }

        // 3) Pet listesi geldi → bottom sheet
        viewModel.onPetsFetched = { [weak self] pets in
            print("🐾 fetchPets sonrası gelen pet sayısı: \(pets.count)")
            DispatchQueue.main.async {
                self?.showPetSelectionBottomSheet(pets: pets)
            }
        }

        // 4) Bir pet seçildi → picker & başlık senkron
        viewModel.onSelectedPetChanged = { [weak self] _ in
            guard let self else { return }
            let t = self.viewModel.selectedPetType ?? .cat
            DispatchQueue.main.async {
                self.petTypeSelector.setInitialType(from: t)
                self.petTypeTitleLabel.text = "\(t.fullDisplayName) Rutinleri"
                self.updateUI()
            }
        }

        // 5) Rutinler değişti → listeyi doldur
        viewModel.onRoutinesUpdated = { [weak self] routines in
            print("🔄 Rutinler güncellendi, toplam: \(routines.count)")
            DispatchQueue.main.async {
                let items = routines.map {
                    RoutineItemView.Model(
                        icon: UIImage(systemName: $0.iconName),
                        title: $0.title,
                        subtitle: $0.frequency,
                        accessoryIcon: UIImage(systemName: "chevron.right"),
                        isEnabled: true
                    )
                }
                self?.routineListView.setItems(items)
            }
        }
    }

    // MARK: - Initial state
    private func setupInitialState() {
        if let typeString = preselectedPetType,
           let petType = PetType.fromDisplayName(typeString) {
            print("✅ eşleşti: \(petType.fullDisplayName)")
            viewModel.selectPetType(petType)
            petTypeSelector.setInitialType(from: petType)
            petTypeTitleLabel.text = "\(petType.fullDisplayName) Rutinleri"
        } else if let fallback = fetchLatestPetTypeAsEnum() {
            viewModel.selectPetType(fallback)
            petTypeSelector.setInitialType(from: fallback)
            petTypeTitleLabel.text = "\(fallback.fullDisplayName) Rutinleri"
        } else {
            viewModel.selectPetType(.cat)
            petTypeSelector.setInitialType(from: .cat)
            petTypeTitleLabel.text = "\(PetType.cat.fullDisplayName) Rutinleri"
        }
    }

    private func fetchLatestPetTypeAsEnum() -> PetType? {
        do {
            let descriptor = FetchDescriptor<Pet>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let pets: [Pet] = try modelContext?.fetch(descriptor) ?? []
            return pets.first?.petTypeEnum
        } catch {
            print("❌ Fetch error: \(error)")
            return nil
        }
    }

    // MARK: - UI updates
    private func updateUI() {
        let routines = viewModel.getRoutines()
        print("📦 updateUI: \(routines.count) rutin geldi")
        let itemModels = routines.map { routine in
            RoutineItemView.Model(
                icon: UIImage(systemName: routine.iconName),
                title: routine.title,
                subtitle: routine.frequency,
                accessoryIcon: UIImage(systemName: "chevron.right"),
                isEnabled: true
            )
        }
        routineListView.setItems(itemModels)
    }

    // MARK: - Bottom sheet (Pet select)
    private func showPetSelectionBottomSheet(pets: [Pet]) {
        let sorted = pets.sorted { ($0.createdAt) > ($1.createdAt) }
        let sheet = UIAlertController(title: "Evcil Hayvan Seç", message: nil, preferredStyle: .actionSheet)

        for pet in sorted {
            let title = "\(pet.petTypeEnum.fullDisplayName) - \(pet.name)"
            sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                self.viewModel.selectPet(pet)
                self.petTypeSelector.setInitialType(from: pet.petTypeEnum)
                self.petTypeTitleLabel.text = "\(pet.petTypeEnum.fullDisplayName) Rutinleri"
                self.updateUI()
            })
        }

        sheet.addAction(UIAlertAction(title: "İptal", style: .cancel))

        if let pop = sheet.popoverPresentationController {
            pop.barButtonItem = navigationItem.rightBarButtonItem
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.safeAreaInsets.top + 44, width: 1, height: 1)
            pop.permittedArrowDirections = []
        }

        present(sheet, animated: true)
    }

    // MARK: - Actions
    private func presentFrequencyOptions(for index: Int, title: String) {
        let alert = UIAlertController(title: "\(title) sıklığını değiştir", message: nil, preferredStyle: .actionSheet)
        let options = ["Günde 1 kez", "Günde 2 kez", "Haftada 1 kez", "Ayda 1 kez"]
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default) { [weak self] _ in
                self?.viewModel.updateFrequency(at: index, to: option)
                self?.routineListView.updateSubtitle(at: index, to: option)
            })
        }
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func didTapPetSelector() {
        print("🟣 Pati butonuna basıldı!")
        viewModel.fetchPets()
    }

    @objc private func didTapAddRoutine() {
        let sheetVC = AddRoutineSheetViewController()
        sheetVC.onRoutineAdded = { [weak self] (newRoutine: Routine) in
            self?.viewModel.addRoutine(newRoutine)
            self?.updateUI()
        }
        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(sheetVC, animated: true)
    }
}
