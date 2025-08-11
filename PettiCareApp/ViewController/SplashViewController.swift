import UIKit
import SwiftData

final class SplashViewController: UIViewController {

    var modelContext: ModelContext?

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "sembol3")   // arka plan görselin
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 2 sn bekle ve geç
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.proceed()
        }
    }

    private func proceed() {
        guard let context = modelContext else { return }

        // Son eklenen pet'e göre tab bar'a geç; yoksa AddPet'e git
        let pets = try? context.fetch(FetchDescriptor<Pet>())
        if let lastPet = pets?.last {
            let tabBar = MainTabBarController(
                selectedType: lastPet.type,
                pet: lastPet,
                modelContext: context
            )
            crossfade(to: UINavigationController(rootViewController: tabBar))
        } else {
            let addPetVC = AddPetFullFormViewController()
            addPetVC.modelContext = context
            navigationController?.pushViewController(addPetVC, animated: true)
        }
    }

    private func crossfade(to root: UIViewController) {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first
        else { return }

        // yumuşak geçiş
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve) {
            window.rootViewController = root
            window.makeKeyAndVisible()
        }
    }
}
