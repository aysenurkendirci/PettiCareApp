import UIKit
import SwiftData

final class FavoriteVetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var modelContext: ModelContext?
    var favorites: [FavoriteVet] = []

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favori Veterinerler"
        view.backgroundColor = .white
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites() // Her göründüğünde favorileri yeniden yükle
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FavoriteVetCell")
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }

    func loadFavorites() {
        guard let context = modelContext else {
            print("❌ modelContext nil")
            return
        }
        do {
            let descriptor = FetchDescriptor<FavoriteVet>()
            favorites = try context.fetch(descriptor)
            print("📌 \(favorites.count) favori veteriner yüklendi: \(favorites.map { "\($0.name) @ \($0.latitude), \($0.longitude)" })")
            tableView.reloadData()
        } catch {
            print("❌ Favoriler yüklenemedi: \(error)")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vet = favorites[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteVetCell", for: indexPath)
        cell.textLabel?.text = vet.name
        cell.detailTextLabel?.text = String(format: "%.6f, %.6f", vet.latitude, vet.longitude)
        return cell
    }
}
