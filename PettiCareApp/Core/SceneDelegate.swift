import UIKit
import SwiftData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }

        do {
            let container = try ModelContainer(for: Pet.self, Vet.self, FavoriteVet.self)
            
            let splashVC = SplashViewController()
            splashVC.modelContext = container.mainContext

            let navController = UINavigationController(rootViewController: splashVC)
            navController.setNavigationBarHidden(true, animated: false) // ✅ Splash’ta bar görünmesin

            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = navController
            self.window = window
            window.makeKeyAndVisible()
        } catch {
            print("❌ SwiftData konteyner oluşturulamadı: \(error)")
        }
    }
}
