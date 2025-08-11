import UIKit
import SwiftData
import CoreLocation

/// Kalıcı olarak saklanabilir (Persistent Store) ve aynı zamanda harita için koordinat döner.

@Model
final class Vet {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double

    /// Harita bileşenleri CLLocationCoordinate2D bekler.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Convenience init: doğrudan isim + koordinat ile oluşturabilmek için.
    init(id: UUID = UUID(), name: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
