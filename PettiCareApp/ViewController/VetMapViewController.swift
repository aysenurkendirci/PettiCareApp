import UIKit
import MapKit
import SwiftData

final class VetMapViewController: UIViewController, MKMapViewDelegate {

    private var searchDebounce: DispatchWorkItem?
    private var isProgrammaticRegionChange = false

    private let mapView = MKMapView()
    private let viewModel = VetMapViewModel()
    var modelContext: ModelContext?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupMapView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart.fill"),
            style: .plain,
            target: self,
            action: #selector(openFavorites)
        )

        viewModel.modelContext = modelContext
        bindViewModel()
        viewModel.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Konum gelmese bile, ekrandaki merkezle bir defa aramayı tetikle (ViewModel throttle ediyor)
        let center = mapView.userLocation.location?.coordinate ?? mapView.centerCoordinate
        viewModel.throttledSearch(around: center)
    }

    // MARK: - Setup
    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

        let tracking = MKUserTrackingButton(mapView: mapView)
        tracking.translatesAutoresizingMaskIntoConstraints = false
        tracking.backgroundColor = .secondarySystemBackground
        tracking.layer.cornerRadius = 8
        view.addSubview(tracking)
        NSLayoutConstraint.activate([
            tracking.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            tracking.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tracking.widthAnchor.constraint(equalToConstant: 40),
            tracking.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onVetsUpdated = { [weak self] vets in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let map = self.mapView

                // Öncekileri temizle (kullanıcı konumu kalsın)
                let toRemove = map.annotations.filter { !($0 is MKUserLocation) }
                map.removeAnnotations(toRemove)

                // Yeni pinleri ekle
                var added: [MKAnnotation] = []
                for v in vets {
                    let ann = MKPointAnnotation()
                    ann.title = v.name
                    ann.coordinate = v.coordinate
                    map.addAnnotation(ann)
                    added.append(ann)
                }

                // 👇 En kritik kısım: Pinleri kesin olarak görünür yap
                if !added.isEmpty {
                    self.isProgrammaticRegionChange = true
                    var toShow = added
                    // Kullanıcı konumu da varsa kadraja kat
                    if let userLoc = map.userLocation.location {
                        let uAnn = MKPointAnnotation()
                        uAnn.coordinate = userLoc.coordinate
                        toShow.append(uAnn)
                    }
                    map.showAnnotations(toShow, animated: true)
                }
            }
        }

        viewModel.onUserLocationUpdated = { [weak self] loc in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isProgrammaticRegionChange = true
                let region = MKCoordinateRegion(center: loc,
                                                latitudinalMeters: 5000,
                                                longitudinalMeters: 5000)
                self.mapView.setRegion(region, animated: true)
            }
        }

        viewModel.onShowAlert = { [weak self] alert in
            DispatchQueue.main.async { self?.present(alert, animated: true) }
        }
    }

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let id = "VetPin"
        var v = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
        if v == nil {
            v = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            v?.canShowCallout = true
            v?.markerTintColor = .red
        } else {
            v?.annotation = annotation
        }
        return v
    }

    // Programatik zoom sonrası tetiklenen regionDidChange'de arama yapma
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isProgrammaticRegionChange {
            isProgrammaticRegionChange = false
            return
        }
        // Kullanıcı kaydırdı/zoomladı → yeni merkeze göre aramayı throttle ile tetikle
        searchDebounce?.cancel()
        let center = mapView.centerCoordinate
        let work = DispatchWorkItem { [weak self] in
            self?.viewModel.throttledSearch(around: center)
        }
        searchDebounce = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: work)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let ann = view.annotation else { return }
        let name = ann.title ?? "Veteriner"
        let vet = Vet(name: name ?? "Veteriner", coordinate: ann.coordinate)

        let alert = UIAlertController(title: name, message: "Favorilere eklemek ister misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ekle", style: .default) { [weak self] _ in
            self?.viewModel.saveToFavorites(vet: vet)
        })
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @objc private func openFavorites() {
        let vc = FavoriteVetsViewController()
        vc.modelContext = modelContext
        navigationController?.pushViewController(vc, animated: true)
    }
}
