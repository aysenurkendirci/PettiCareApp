import UIKit
import SwiftData

final class PetRoutineViewController: UIViewController {
    var preselectedPetType: String?
    var modelContext: ModelContext?
    var savedPet: Pet?

    private let routineListView = RoutineListView()
    private let viewModel = RoutineViewModel()
    private let gradientBackgroundView = GradientBackgroundView()

    // Scroll alanı ve içerik
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Başlık
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Evcil dostunuz için günlük bakım planı"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.modelContext = modelContext
        view.backgroundColor = .clear

        setupGradientBackground()
        setupNavigationItem()
        setupUI()
        setupBindings()
        setupInitialState()

        viewModel.fetchPets()
    }

    // MARK: - Gradient
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

    // MARK: - Navigation Bar
    private func setupNavigationItem() {
        let pawIcon = UIImage(systemName: "pawprint")
        let rightButton = UIBarButtonItem(image: pawIcon, style: .plain, target: self, action: #selector(didTapPetSelector))
        rightButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = rightButton

        let plusIcon = UIImage(systemName: "plus")
        let leftButton = UIBarButtonItem(
            image: plusIcon,
            style: .plain,
            target: self,
            action: #selector(didTapAddRoutine)
        )
        leftButton.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = leftButton
    }

    // MARK: - UI Setup
    private func setupUI() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Content Stack
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // Başlıklar
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)

        // Rutin Listesi
        contentStack.addArrangedSubview(routineListView)
    }

    // MARK: - Bindings
    private func setupBindings() {
        routineListView.onItemTapped = { [weak self] index, title in
            self?.presentFrequencyOptions(for: index, title: title)
        }

        viewModel.onPetsFetched = { [weak self] pets in
            DispatchQueue.main.async {
                self?.showPetSelectionBottomSheet(pets: pets)
            }
        }

        viewModel.onSelectedPetChanged = { [weak self] pet in
            guard let self = self else { return }
            self.updateHeader(for: pet)
            self.updateUI()
        }

        viewModel.onRoutinesUpdated = { [weak self] routines in
            DispatchQueue.main.async {
                let items = routines.map { r -> RoutineItemView.Model in
                    RoutineItemView.Model(
                        icon: UIImage(systemName: r.iconName),
                        title: r.title,
                        frequencyText: r.frequency,
                        progressText: self?.viewModel.progressText(r) ?? "",
                        isCompleted: self?.viewModel.isCompletedThisPeriod(r) ?? false,
                        accessoryIcon: UIImage(systemName: "chevron.right"),
                        tapHandler: nil
                    )
                }
                self?.routineListView.setItems(items)
            }
        }
    }

    // MARK: - Initial State
    private func setupInitialState() {
        if let typeString = preselectedPetType,
           let petType = PetType.fromDisplayName(typeString) {
            viewModel.selectPetType(petType)
            updateHeaderWithType(petType, petName: nil)
        } else if let fallback = fetchLatestPetTypeAsEnum() {
            viewModel.selectPetType(fallback)
            updateHeaderWithType(fallback, petName: nil)
        } else {
            viewModel.selectPetType(.cat)
            updateHeaderWithType(.cat, petName: nil)
        }
    }

    // MARK: - Header Update
    private func updateHeader(for pet: Pet) {
        let type = pet.petTypeEnum
        updateHeaderWithType(type, petName: pet.name)
    }

    private func updateHeaderWithType(_ type: PetType, petName: String?) {
        let emoji: String
        switch type {
        case .cat: emoji = "🐱"
        case .dog: emoji = "🐶"
        case .bird: emoji = "🐦"
        case .fish: emoji = "🐠"
        default: emoji = "🐾"
        }
        let namePart = petName ?? type.fullDisplayName
        titleLabel.text = "\(emoji) Evcil Dostunuzun Rutinleri"
    }

    // MARK: - Fetch Latest Pet Type
    private func fetchLatestPetTypeAsEnum() -> PetType? {
        do {
            let descriptor = FetchDescriptor<Pet>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let pets: [Pet] = try modelContext?.fetch(descriptor) ?? []
            return pets.first?.petTypeEnum
        } catch { return nil }
    }

    // MARK: - Update UI
    private func updateUI() {
        let routines = viewModel.getRoutines()
        let itemModels = routines.map { r -> RoutineItemView.Model in
            RoutineItemView.Model(
                icon: UIImage(systemName: r.iconName),
                title: r.title,
                frequencyText: r.frequency,
                progressText: viewModel.progressText(r),
                isCompleted: viewModel.isCompletedThisPeriod(r),
                accessoryIcon: UIImage(systemName: "chevron.right"),
                tapHandler: nil
            )
        }
        routineListView.setItems(itemModels)
    }

    // MARK: - Pet Selector Sheet (only names)
    private func showPetSelectionBottomSheet(pets: [Pet]) {
        let sorted = pets.sorted { ($0.createdAt) > ($1.createdAt) }
        let sheet = UIAlertController(title: "Evcil Hayvan Seç", message: nil, preferredStyle: .actionSheet)

        for pet in sorted {
            let name = pet.name.trimmingCharacters(in: .whitespacesAndNewlines)
            let displayName = name.isEmpty ? pet.petTypeEnum.fullDisplayName : name

            let action = UIAlertAction(title: displayName, style: .default) { [weak self] _ in
                self?.viewModel.selectPet(pet)
                self?.updateHeader(for: pet)
                self?.updateUI()
            }
        
            sheet.addAction(action)
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

    // MARK: - Frequency / Done Sheet
    private func presentFrequencyOptions(for index: Int, title: String) {
        let alert = UIAlertController(title: "\(title) sıklığını değiştir", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Tamamlandı (1 adım)", style: .default) { [weak self] _ in
            self?.viewModel.markDone(at: index)
            self?.updateUI()
        })

        let options = ["Günde 1 kez", "Günde 2 kez", "Haftada 1 kez", "Ayda 1 kez"]
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default) { [weak self] _ in
                self?.viewModel.updateFrequency(at: index, to: option)
                self?.updateUI()
            })
        }

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @objc private func didTapPetSelector() {
        viewModel.fetchPets()
    }

    @objc private func didTapAddRoutine() {
        let sheetVC = AddRoutineSheetViewController()
        sheetVC.onRoutineAdded = { [weak self] newRoutine in
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

// Küçük ikon eşlemesi (opsiyonel)
private func symbolName(for type: PetType) -> String {
    switch type {
    case .cat:  return "pawprint"
    case .dog:  return "pawprint"
    case .bird: return "bird"
    case .fish: return "fish"
    default:    return "pawprint"
    }
}
