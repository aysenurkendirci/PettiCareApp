import Foundation
import UIKit
import SwiftData

final class PetProfileViewModel: ObservableObject {
    private(set) var pet: Pet

    init(pet: Pet) {
        self.pet = pet
    }

    var name: String {
        pet.name
    }

    var breed: String {
        pet.breed
    }

    var birthDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: pet.birthDate)
    }

    var color: String {
        pet.color
    }

    var height: String {
        pet.height
    }

    var weight: String {
        pet.weight
    }

    var details: String {
        pet.details
    }

    var image: UIImage {
        if let data = pet.imageData, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(systemName: "photo")!
        }
    }

    func updateImage(_ image: UIImage, in context: ModelContext?) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        pet.imageData = data
        try? context?.save()
        print(" Yeni fotoğraf kaydedildi.")
    }
}
