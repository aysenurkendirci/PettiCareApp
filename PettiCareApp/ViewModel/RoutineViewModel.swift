import SwiftData
import UIKit

final class RoutineViewModel {
    var modelContext: ModelContext?

    // State
    private(set) var selectedPet: Pet? {
        didSet { selectedPetType = selectedPet?.petTypeEnum }
    }
    private(set) var selectedPetType: PetType? {
        didSet { reloadRoutines() }
    }
    private var currentRoutines: [Routine] = []

    // Callbacks
    var onPetsFetched: (([Pet]) -> Void)?
    var onSelectedPetChanged: ((Pet) -> Void)?
    var onRoutinesUpdated: (([Routine]) -> Void)?

    // MARK: Pets
    func fetchPets() {
        guard let ctx = modelContext else { return }
        do {
            let pets = try ctx.fetch(
                FetchDescriptor<Pet>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            )
            onPetsFetched?(pets)
        } catch {
            print("❌ fetchPets:", error)
        }
    }

    func selectPet(_ pet: Pet) {
        selectedPet = pet
        onSelectedPetChanged?(pet)
        reloadRoutines()
    }

    func selectPetType(_ type: PetType) {
        selectedPet = nil          // sadece türe göre göster
        selectedPetType = type
        reloadRoutines()
    }

    // MARK: Routines (read/update)
    func getRoutines() -> [Routine] {
        return currentRoutines
    }

    func updateFrequency(at index: Int, to newValue: String) {
        guard currentRoutines.indices.contains(index) else { return }
        currentRoutines[index].frequency = newValue
        onRoutinesUpdated?(currentRoutines)
    }

    func addRoutine(_ routine: Routine) {
        // Eğer bir pet seçiliyse, yeni rutini o pete bağla ve kaydet
        if let ctx = modelContext {
            if let pet = selectedPet {
                routine.pet = pet
            }
            ctx.insert(routine)
            do { try ctx.save() } catch { print("❌ save routine:", error) }
        }
        currentRoutines.append(routine)
        onRoutinesUpdated?(currentRoutines)
    }

    // MARK: Helpers
    private func reloadRoutines() {
        // 1) Bir pet seçiliyse: önce o pet’in kayıtlı rutinleri
        if let pet = selectedPet {
            let saved = pet.routines.sorted { $0.createdAt > $1.createdAt }
            if saved.isEmpty {
                // kayıt yoksa tür şablonlarını göster
                currentRoutines = templateRoutines(for: pet.petTypeEnum)
            } else {
                currentRoutines = saved
            }
            onRoutinesUpdated?(currentRoutines)
            return
        }

        // 2) Sadece tür seçiliyse: şablonları göster
        if let t = selectedPetType {
            currentRoutines = templateRoutines(for: t)
        } else {
            currentRoutines = []
        }
        onRoutinesUpdated?(currentRoutines)
    }

    private func templateRoutines(for type: PetType) -> [Routine] {
        switch type {
        case .cat:
            return [
                Routine(title: "Mama",          frequency: "Günde 2 kez", iconName: "pawprint"),
                Routine(title: "Tuvalet",       frequency: "Günde 1 kez", iconName: "trash"),
                Routine(title: "Oyun",          frequency: "Günde 1 kez", iconName: "gamecontroller")
            ]
        case .dog:
            return [
                Routine(title: "Mama",          frequency: "Günde 2 kez", iconName: "pawprint"),
                Routine(title: "Yürüyüş",       frequency: "Günde 2 kez", iconName: "figure.walk"),
                Routine(title: "Oyun",          frequency: "Günde 1 kez", iconName: "gamecontroller")
            ]
        case .bird:
            return [
                Routine(title: "Mama",          frequency: "Günde 1 kez", iconName: "pawprint"),
                Routine(title: "Kafes Temizliği", frequency: "Günde 1 kez", iconName: "sparkles")
            ]
        case .fish:
            return [
                Routine(title: "Yem",           frequency: "Günde 1 kez", iconName: "drop.fill"),
                Routine(title: "Filtre Kontrol", frequency: "Haftada 1 kez", iconName: "aqi.medium")
            ]
        }
    }
}
