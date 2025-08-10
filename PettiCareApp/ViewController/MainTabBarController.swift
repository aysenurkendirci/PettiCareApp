import UIKit
import SwiftData

final class MainTabBarController: UITabBarController {
    var pet: Pet?
    var selectedType: String?
    var modelContext: ModelContext?

    init(selectedType: String?, pet: Pet?, modelContext: ModelContext?) {
        self.selectedType = selectedType
        self.pet = pet
        self.modelContext = modelContext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
    }

    private func setupTabs() {
        let routineVC = PetRoutineViewController()
        routineVC.modelContext = modelContext
        routineVC.tabBarItem = UITabBarItem(
            title: "Rutinler",
            image: UIImage(systemName: "pawprint"),
            selectedImage: UIImage(systemName: "pawprint.fill")
        )

        let vetVC = VetMapViewController()
        vetVC.modelContext = modelContext
        vetVC.tabBarItem = UITabBarItem(
            title: "Veteriner",
            image: UIImage(systemName: "cross.case"),
            selectedImage: UIImage(systemName: "cross.case.fill")
        )

        let profileVC = PetProfileViewController()
        profileVC.modelContext = modelContext
        profileVC.tabBarItem = UITabBarItem(
            title: "Profil",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill")
        )

        viewControllers = [
            UINavigationController(rootViewController: routineVC),
            UINavigationController(rootViewController: vetVC),
            UINavigationController(rootViewController: profileVC)
        ]
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground // Daha modern, light/dark uyumlu

        let selectedColor = UIColor(named: "AccentColor") ?? UIColor.systemIndigo

        // Seçili sekme görünümü
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.boldSystemFont(ofSize: 12)
        ]

        // Normal sekme görünümü
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray3
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray3
        ]

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        // Üst kenar çizgisi (tema uyumlu)
        let topBorder = UIView()
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.backgroundColor = selectedColor.withAlphaComponent(0.2)
        tabBar.addSubview(topBorder)
        NSLayoutConstraint.activate([
            topBorder.topAnchor.constraint(equalTo: tabBar.topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 0.6)
        ])
    }
}
