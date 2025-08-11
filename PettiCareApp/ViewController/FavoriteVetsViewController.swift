import UIKit
import SwiftData
import MapKit

final class FavoriteVetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var modelContext: ModelContext?
    private var favorites: [FavoriteVet] = []

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Henüz favori veteriner yok."
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favori Veterinerler"
        view.backgroundColor = .systemBackground
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func loadFavorites() {
        guard let context = modelContext else {
            print("❌ modelContext nil"); return
        }
        do {
            // İstersen isme göre sırala
            let descriptor = FetchDescriptor<FavoriteVet>(sortBy: [SortDescriptor(\.name, order: .forward)])
            favorites = try context.fetch(descriptor)
            emptyLabel.isHidden = !favorites.isEmpty
            tableView.reloadData()
            print("📌 \(favorites.count) favori yüklendi")
        } catch {
            print("❌ Favoriler yüklenemedi: \(error)")
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Subtitle stilini kullan: detailTextLabel nil olmaz
        let id = "FavoriteVetCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: id)

        let vet = favorites[indexPath.row]
        cell.textLabel?.text = vet.name
        cell.detailTextLabel?.text = String(format: "%.6f, %.6f", vet.latitude, vet.longitude)
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Haritalar’da aç
        let vet = favorites[indexPath.row]
        let coord = CLLocationCoordinate2D(latitude: vet.latitude, longitude: vet.longitude)
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coord))
        item.name = vet.name
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    // Kaydırarak silme
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
                   -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, done in
            guard let self = self, let context = self.modelContext else { done(false); return }
            let fav = self.favorites.remove(at: indexPath.row)
            context.delete(fav)
            do { try context.save() } catch { print("❌ Silme kaydetme hatası: \(error)") }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.emptyLabel.isHidden = !self.favorites.isEmpty
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
