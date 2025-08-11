import Foundation
import MapKit
import SwiftData
import CoreLocation

final class VetMapViewModel: NSObject, CLLocationManagerDelegate {

    // OUTPUT
    var onVetsUpdated: (([Vet]) -> Void)?
    var onUserLocationUpdated: ((CLLocationCoordinate2D) -> Void)?
    var onShowAlert: ((UIAlertController) -> Void)?

    // STATE
    private let locationManager = CLLocationManager()
    private var searchWork: DispatchWorkItem?
    private var isSearching = false
    var userLocation: CLLocationCoordinate2D?
    var modelContext: ModelContext?

    // MARK: - Start
    func start() {
        print("🚀 start()")
        debugDumpSwiftData()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone

        guard CLLocationManager.locationServicesEnabled() else {
            fallbackToTurkey()
            return
        }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
        case .denied, .restricted:
            showLocationSettingsAlert()
            fallbackToTurkey()
        @unknown default:
            fallbackToTurkey()
        }
    }

    // MARK: - Public search API
    func throttledSearch(around center: CLLocationCoordinate2D) {
        searchWork?.cancel()
        let w = DispatchWorkItem { [weak self] in
            self?.fetchNearbyVets(around: center)
        }
        searchWork = w
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: w)
    }

    // MARK: - Fetch vets (metin tabanlı; tüm SDK’larda çalışır)
    private func fetchNearbyVets(around center: CLLocationCoordinate2D) {
        if isSearching { return }
        isSearching = true

        let radius: CLLocationDistance = 6000 // 6 km
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: radius * 2,
                                        longitudinalMeters: radius * 2)

        // Birkaç farklı sorgu dene; ilk sonuçta dur
        searchTextQueries(
            ["veterinary clinic", "animal hospital", "vet", "pet clinic", "veteriner"],
            region: region
        )
    }

    private func searchTextQueries(_ queries: [String], region: MKCoordinateRegion, idx: Int = 0) {
        if idx >= queries.count {
            self.finish(with: [])
            return
        }
        var req = MKLocalSearch.Request()
        req.naturalLanguageQuery = queries[idx]
        req.region = region

        MKLocalSearch(request: req).start { [weak self] resp, _ in
            guard let self else { return }
            if let items = resp?.mapItems, !items.isEmpty {
                self.finish(with: items)
            } else {
                self.searchTextQueries(queries, region: region, idx: idx + 1)
            }
        }
    }

    private func finish(with items: [MKMapItem]) {
        self.isSearching = false

        // Eşsizleştir & modele çevir
        var seen = Set<String>()
        var vets: [Vet] = []
        for it in items.prefix(20) {
            guard let name = it.name else { continue }
            let c = it.placemark.coordinate
            let key = "\(name)-\(c.latitude.rounded(to: 5))-\(c.longitude.rounded(to: 5))"
            if seen.insert(key).inserted {
                vets.append(Vet(name: name, coordinate: c))
            }
        }
        print("📌 \(vets.count) vet bulundu")
        onVetsUpdated?(vets)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            manager.requestLocation()
        case .denied, .restricted:
            showLocationSettingsAlert()
            fallbackToTurkey()
        default: break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        userLocation = loc.coordinate
        onUserLocationUpdated?(loc.coordinate)
        throttledSearch(around: loc.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let e = error as? CLError, e.code == .locationUnknown {
            // Simülatörde sık olur; kısa süre sonra tekrar dene
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { manager.requestLocation() }
            return
        }
        print("❌ Location error:", error.localizedDescription)
    }

    // MARK: - Helpers
    private func fallbackToTurkey() {
        let ist = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        onUserLocationUpdated?(ist)
        throttledSearch(around: ist)
    }

    private func showLocationSettingsAlert() {
        let alert = UIAlertController(
            title: "Konum Servisleri Kapalı",
            message: "Yakındaki veterinerleri bulmak için konum iznine ihtiyacımız var.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ayarlar", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        });
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        onShowAlert?(alert)
    }

    func saveToFavorites(vet: Vet) {
        guard let ctx = modelContext else { return }
        let fav = FavoriteVet(name: vet.name, latitude: vet.latitude, longitude: vet.longitude)
        ctx.insert(fav)
        try? ctx.save()
    }

    private func debugDumpSwiftData() {
        guard let ctx = modelContext else { return }
        do {
            let vets = try ctx.fetch(FetchDescriptor<Vet>())
            let favs = try ctx.fetch(FetchDescriptor<FavoriteVet>())
            print("📦 Vets: \(vets.count) Favorites: \(favs.count)")
        } catch { }
    }
}

private extension Double {
    func rounded(to places: Int) -> Double {
        let p = pow(10.0, Double(places))
        return (self * p).rounded() / p
    }
}
