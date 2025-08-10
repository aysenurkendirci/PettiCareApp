import Foundation
import SwiftData

class AddPetViewModel {
    var modelContext: ModelContext?

    
    var pet = Pet(
        name: "",
        type: "",
        breed: "",
        birthDate: Date(),
        weight: "",
        height: "",
        color: "",
        details: ""
        
    )

    func savePet(
        name: String,
        type: PetType,
        breed: String,
        birthDate: Date,
        weight: String,
        height: String,
        color: String,
        details: String,
        imageData: Data?
    ) -> Pet? {
        guard let context = modelContext else { return nil }

        let newPet = Pet(
            name: name,
            type: type.rawValue,
            breed: breed,
            birthDate: birthDate,
            weight: weight,
            height: height,
            color: color,
            details: details,
            imageData: imageData
        )

        context.insert(newPet)
        try? context.save()
        return newPet
    }


    var selectedType: PetType {
        return PetType(rawValue: pet.type) ?? .cat
    }

}
