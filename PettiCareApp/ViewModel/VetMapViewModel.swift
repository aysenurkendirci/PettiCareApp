import Foundation
import MapKit
import SwiftData

final class VetMapViewModel: NSObject, CLLocationManagerDelegate {
    var vets: [Vet] = [] {
        didSet {
            onVetsUpdated?(vets)
        }
    }

    var onVetsUpdated: (([Vet]) -> Void)?
    var onUserLocationUpdated: ((CLLocationCoordinate2D) -> Void)?
    var onShowAlert: ((UIAlertController) -> Void)?
    private var locationManager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D?
    var modelContext: ModelContext?

    func simulateLocation(city: String = "Istanbul") {
        var testCoordinate: CLLocationCoordinate2D
        switch city.lowercased() {
        case "istanbul":
            testCoordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        case "london":
            testCoordinate = CLLocationCoordinate2D(latitude: 51.50998, longitude: -0.1337)
        case "sanfrancisco":
            testCoordinate = CLLocationCoordinate2D(latitude: 37.7873589, longitude: -122.408227)
        default:
            testCoordinate = CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784)
        }
        print("📍 Simülatörde \(city) konumu simüle ediliyor: \(testCoordinate.latitude), \(testCoordinate.longitude)")
        userLocation = testCoordinate
        onUserLocationUpdated?(testCoordinate)
        fetchNearbyVets()
    }

    func start() {
        print("🚀 start() çağrıldı")
        checkSwiftData() // SwiftData verilerini kontrol et
        #if targetEnvironment(simulator)
            simulateLocation(city: "London") // Test için Londra
        #else
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            switch locationManager.authorizationStatus {
            case .notDetermined:
                print("📍 Konum izni isteniyor")
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                print("📍 Konum izni var, güncellemeler başlatılıyor")
                locationManager.startUpdatingLocation()
            case .denied, .restricted:
                print("❌ Konum izni reddedildi veya kısıtlandı")
                let alert = UIAlertController(
                    title: "Konum Servisleri Kapalı",
                    message: "Yakındaki veterinerleri bulmak için konum servislerini açmanız gerekiyor. Ayarlar’a giderek bunu yapabilirsiniz.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ayarlar", style: .default) { _ in
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                })
                alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
                onShowAlert?(alert)
            default:
                print("❌ Bilinmeyen konum izni durumu")
            }
        #endif
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
        print("📍 Konum alındı: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        onUserLocationUpdated?(location.coordinate)
        fetchNearbyVets()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Konum hatası: \(error.localizedDescription)")
        if let clError = error as? CLError, clError.code == .denied {
            let alert = UIAlertController(
                title: "Konum Servisleri Kapalı",
                message: "Yakındaki veterinerleri bulmak için konum servislerini açmanız gerekiyor. Ayarlar’a giderek bunu yapabilirsiniz.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ayarlar", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
            onShowAlert?(alert)
        }
    }

    func fetchNearbyVets() {
        guard let location = userLocation else {
            print("❌ userLocation nil, konum alınamamış")
            return
        }
        guard let context = modelContext else {
            print("❌ modelContext nil, SwiftData konteyneri yok")
            return
        }

        print("📍 fetchNearbyVets() çalıştı → \(location.latitude), \(location.longitude)")

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "veterinary clinic" // Simülatörde daha iyi sonuç için
        request.region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )

        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else {
                print("❌ self nil olmuş")
                return
            }

            if let error = error {
                print("❌ MKLocalSearch hata: \(error.localizedDescription)")
                return
            }

            guard let items = response?.mapItems, !items.isEmpty else {
                print("❌ MKLocalSearch: mapItems boş veya bulunamadı")
                return
            }

            DispatchQueue.main.async {
                // SwiftData’daki eski Vet verilerini temizle
                do {
                    let fetchDescriptor = FetchDescriptor<Vet>()
                    let existingVets = try context.fetch(fetchDescriptor)
                    for vet in existingVets {
                        context.delete(vet)
                    }
                    try context.save()
                    print("📌 Eski Vet verileri SwiftData’dan temizlendi")
                } catch {
                    print("❌ SwiftData Vet temizleme hatası: \(error.localizedDescription)")
                }

                self.vets.removeAll()

                for item in items {
                    guard let name = item.name else {
                        print("❌ İsim eksik, atlanıyor")
                        continue
                    }

                    let vet = Vet(name: name, coordinate: item.placemark.coordinate)
                    context.insert(vet)
                    self.vets.append(vet)
                    print("✅ Vet eklendi: \(name) @ \(vet.coordinate.latitude), \(vet.coordinate.longitude)")
                }

                print("📌 Toplam \(self.vets.count) veteriner kaydedildi ve haritaya gönderildi")
                self.onVetsUpdated?(self.vets)
            }
        }
    }

    func saveToFavorites(vet: Vet) {
        guard let context = modelContext else {
            print("❌ modelContext nil, favorilere eklenemedi")
            return
        }

        let favorite = FavoriteVet(name: vet.name, latitude: vet.latitude, longitude: vet.longitude)
        context.insert(favorite)
        do {
            try context.save()
            print("❤️ Favorilere eklendi: \(vet.name) @ \(vet.latitude), \(vet.longitude)")
        } catch {
            print("❌ Favori kaydetme hatası: \(error)")
        }
    }

    func checkSwiftData() {
        guard let context = modelContext else {
            print("❌ modelContext nil")
            return
        }
        do {
            let vetDescriptor = FetchDescriptor<Vet>()
            let allVets = try context.fetch(vetDescriptor)
            print("📌 SwiftData’daki tüm Vet’ler: \(allVets.map { "\($0.name) @ \($0.latitude), \($0.longitude)" })")

            let favoriteDescriptor = FetchDescriptor<FavoriteVet>()
            let allFavorites = try context.fetch(favoriteDescriptor)
            print("📌 SwiftData’daki tüm FavoriteVet’ler: \(allFavorites.map { "\($0.name) @ \($0.latitude), \($0.longitude)" })")
        } catch {
            print("❌ SwiftData fetch hatası: \(error)")
        }
    }
}
