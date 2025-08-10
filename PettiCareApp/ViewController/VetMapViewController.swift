import UIKit
import MapKit // MapKit framework’ünü ekle
import SwiftData

final class VetMapViewController: UIViewController, MKMapViewDelegate {
    private let mapView = MKMapView()
    private let viewModel = VetMapViewModel()
    var modelContext: ModelContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupMapView()

        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart.fill"), style: .plain, target: self, action: #selector(openFavorites))
        navigationItem.rightBarButtonItem = favoriteButton

        viewModel.modelContext = modelContext
        bindViewModel()
        viewModel.start()
    }

    private func setupMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onVetsUpdated = { [weak self] vets in
            print("📌 \(vets.count) pin haritaya ekleniyor")
            DispatchQueue.main.async {
                self?.mapView.removeAnnotations(self?.mapView.annotations ?? [])
                for vet in vets {
                    print("📍 Pin: \(vet.name) @ \(vet.coordinate.latitude), \(vet.coordinate.longitude)")
                    let annotation = MKPointAnnotation()
                    annotation.title = vet.name
                    annotation.coordinate = vet.coordinate
                    self?.mapView.addAnnotation(annotation)
                }
            }
        }

        viewModel.onUserLocationUpdated = { [weak self] location in
            DispatchQueue.main.async {
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000, longitudinalMeters: 5000)
                self?.mapView.setRegion(region, animated: true)
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let identifier = "VetPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = .red
            annotationView?.titleVisibility = .adaptive
        } else {
            annotationView?.annotation = annotation
        }
        print("📍 Pin görünümü oluşturuldu: \(annotation.title ?? "Bilinmeyen")")
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let title = view.annotation?.title ?? "",
              let coordinate = view.annotation?.coordinate else { return }

        let vet = Vet(name: title, coordinate: coordinate)
        let alert = UIAlertController(title: title, message: "Favorilere eklemek ister misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ekle", style: .default, handler: { _ in
            self.viewModel.saveToFavorites(vet: vet)
        }))
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func openFavorites() {
        let favoritesVC = FavoriteVetsViewController()
        favoritesVC.modelContext = modelContext
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
}
