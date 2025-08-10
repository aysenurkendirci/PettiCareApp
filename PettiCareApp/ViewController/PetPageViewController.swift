/*import UIKit
import SwiftData

final class PetPageViewController: UIViewController, UIPageViewControllerDataSource {

    var modelContext: ModelContext?

    private var pets: [Pet] = []
    private var pageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        fetchPets()
        setupPageViewController()
    }

    private func fetchPets() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Pet>(sortBy: [SortDescriptor(\.createdAt, order: .forward)])
        pets = (try? context.fetch(descriptor)) ?? []
    }

    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = self

        if let firstPet = pets.first {
            let firstVC = createPetProfileVC(for: firstPet)
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: false)
        }

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        pageViewController.didMove(toParent: self)
    }

    private func createPetProfileVC(for pet: Pet) -> PetProfileViewController {
        let vc = PetProfileViewController()
        vc.modelContext = modelContext
        vc.pet = pet
        return vc
    }

    // MARK: - PageViewController Data Source

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PetProfileViewController,
              let currentPet = currentVC.pet,
              let index = pets.firstIndex(where: { $0.id == currentPet.id }),
              index > 0 else {
            return nil
        }

        return createPetProfileVC(for: pets[index - 1])
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PetProfileViewController,
              let currentPet = currentVC.pet,
              let index = pets.firstIndex(where: { $0.id == currentPet.id }),
              index < pets.count - 1 else {
            return nil
        }

        return createPetProfileVC(for: pets[index + 1])
    }
 }*/
