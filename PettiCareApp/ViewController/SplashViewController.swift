import UIKit
import SwiftData

final class SplashViewController: UIViewController {

    var modelContext: ModelContext?

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sembol4") // 🖼 Tüm tasarım bu görselde zaten var
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Başlayalım!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        getStartedButton.addTarget(self, action: #selector(handleGetStarted), for: .touchUpInside)
    }

    private func setupLayout() {
        view.addSubview(backgroundImageView)
        view.addSubview(getStartedButton)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.widthAnchor.constraint(equalToConstant: 200),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func handleGetStarted() {
        Task {
            guard let context = modelContext else { return }

            let descriptor = FetchDescriptor<Pet>()
            let pets = try? context.fetch(descriptor)

            if let lastPet = pets?.last {
                let tabBar = MainTabBarController(
                    selectedType: lastPet.type,
                    pet: lastPet,
                    modelContext: context
                )

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = UINavigationController(rootViewController: tabBar)
                    window.makeKeyAndVisible()
                }
            } else {
                let addPetVC = AddPetFullFormViewController()
                addPetVC.modelContext = context
                self.navigationController?.pushViewController(addPetVC, animated: true)
            }
        }
    }
}
