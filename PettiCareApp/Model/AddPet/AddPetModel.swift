import Foundation
import SwiftData

@Model
class Pet {
    var name: String
    var type: String          // "Cat" / "Kedi" vb. saklanır
    var breed: String
    var birthDate: Date
    var weight: String
    var height: String
    var color: String
    var details: String
    var imageData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var routines: [Routine] = []

    init(
        name: String,
        type: String,
        breed: String,
        birthDate: Date,
        weight: String,
        height: String,
        color: String,
        details: String,
        imageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.type = type
        self.breed = breed
        self.birthDate = birthDate
        self.weight = weight
        self.height = height
        self.color = color
        self.details = details
        self.imageData = imageData
        self.createdAt = createdAt
    }
}

// MARK: - PetType (TR/EN + Emoji)
enum PetType: String, Codable, CaseIterable {
    case cat = "Cat"
    case dog = "Dog"
    case bird = "Bird"
    case fish = "Fish"
    case unknown = "Unknown"

    /// TR görünen ad
    var displayName: String {
        switch self {
        case .cat:     return "Kedi"
        case .dog:     return "Köpek"
        case .bird:    return "Kuş"
        case .fish:    return "Balık"
        case .unknown: return "Bilinmeyen"
        }
    }

    /// Tam başlıkta kullanılacak ad (şu an displayName ile aynı)
    var fullDisplayName: String {
        return displayName
    }

    /// Emoji desteği
    var emoji: String {
        switch self {
        case .cat: return "🐱"
        case .dog: return "🐶"
        case .bird: return "🐦"
        case .fish: return "🐠"
        case .unknown: return "🐾"
        }
    }

    /// DisplayName’den PetType üretir
    static func fromDisplayName(_ name: String) -> PetType? {
        let s = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch s {
        case "kedi", "cat": return .cat
        case "köpek", "kopek", "dog": return .dog
        case "kuş", "kus", "bird": return .bird
        case "balık", "balik", "fish": return .fish
        case "bilinmeyen", "unknown": return .unknown
        default:
            if let t = PetType(rawValue: name) { return t }
            if let t = PetType(rawValue: name.capitalized) { return t }
            return nil
        }
    }
}

// MARK: - Pet yardımcılar
extension Pet {
    /// Enum olarak petType
    var petTypeEnum: PetType {
        return PetType.fromDisplayName(type) ?? .unknown
    }

    /// Enum ile type güncelleme
    func setType(_ newType: PetType) {
        self.type = newType.rawValue
    }

    /// Rutin başlığı: "🐱 Misket Rutinleri"
    var routineTitle: String {
        let t = petTypeEnum
        let base = name.isEmpty ? t.displayName : name
        return "\(t.emoji) \(base) Rutinleri"
    }
}
