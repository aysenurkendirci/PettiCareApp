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

    // MARK: - Pets
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
        selectedPet = nil
        selectedPetType = type
        reloadRoutines()
    }

    // MARK: - Routines (read/update)
    func getRoutines() -> [Routine] {
        currentRoutines
    }

    /// Kullanıcı seçenekten sıklığı değiştirirse
    func updateFrequency(at index: Int, to newValue: String) {
        guard currentRoutines.indices.contains(index) else { return }
        let r = currentRoutines[index]
        r.frequency = newValue
        // ✅ Periyot değiştiğinde sayacı sıfırla
        r.lastCompletedDate = nil
        r.doneCountInPeriod = 0
        try? modelContext?.save()
        onRoutinesUpdated?(currentRoutines)
    }

    /// Yeni rutin ekle
    func addRoutine(_ routine: Routine) {
        if let ctx = modelContext {
            if let pet = selectedPet, routine.pet == nil {
                routine.pet = pet
            }
            ctx.insert(routine)
            do { try ctx.save() } catch { print("❌ save routine:", error) }
        }
        currentRoutines.append(routine)
        onRoutinesUpdated?(currentRoutines)
    }

    // MARK: - DONE / PROGRESS Mantığı
    private enum Period { case day, week, month, year }

    /// "Günde 2 kez", "Haftada 1 kez", "Ayda 1 kez", "Yılda 1 kez", "Haftada 2 kez" vb. hepsini çözer.
    private func parseFrequency(_ text: String) -> (period: Period, required: Int) {
        let lower = text.lowercased()
        // metinden sayı çek (yoksa 1)
        let digits = lower.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let count = Int(digits).map { max(1, $0) } ?? 1

        if lower.contains("gün")   { return (.day,   count) }
        if lower.contains("hafta") { return (.week,  count) }
        if lower.contains("ay")    { return (.month, count) }
        if lower.contains("yıl") || lower.contains("yilda") { return (.year,  count) }
        return (.day, count)
    }

    private func inSamePeriod(_ d1: Date, _ d2: Date, _ p: Period) -> Bool {
        let cal = Calendar.current
        switch p {
        case .day:
            return cal.isDate(d1, inSameDayAs: d2)
        case .week:
            return cal.component(.weekOfYear, from: d1) == cal.component(.weekOfYear, from: d2)
            && cal.component(.yearForWeekOfYear, from: d1) == cal.component(.yearForWeekOfYear, from: d2)
        case .month:
            return cal.component(.month, from: d1) == cal.component(.month, from: d2)
            && cal.component(.year, from: d1) == cal.component(.year, from: d2)
        case .year:
            return cal.component(.year, from: d1) == cal.component(.year, from: d2)
        }
    }

    /// Kart/aksiyon ile bir adım tamamlandı
    func markDone(at index: Int) {
        guard currentRoutines.indices.contains(index) else { return }
        let r = currentRoutines[index]
        let now = Date()
        let (period, required) = parseFrequency(r.frequency)

        // periyot değiştiyse sayaç sıfırla
        if let last = r.lastCompletedDate, !inSamePeriod(last, now, period) {
            r.doneCountInPeriod = 0
        }

        r.doneCountInPeriod = min(r.doneCountInPeriod + 1, required)
        r.lastCompletedDate = now

        try? modelContext?.save()
        onRoutinesUpdated?(currentRoutines)
    }

    func isCompletedThisPeriod(_ r: Routine) -> Bool {
        let (period, required) = parseFrequency(r.frequency)
        if let last = r.lastCompletedDate, inSamePeriod(last, Date(), period) {
            return r.doneCountInPeriod >= required
        }
        return false
    }

    func progressText(_ r: Routine) -> String {
        let (_, required) = parseFrequency(r.frequency)
        return "\(min(r.doneCountInPeriod, required))/\(required)"
    }

    // MARK: - Helpers
    private func reloadRoutines() {
        if let pet = selectedPet {
            let saved: [Routine] = Array(pet.routines).sorted { (a: Routine, b: Routine) in
                a.createdAt > b.createdAt
            }
            currentRoutines = saved.isEmpty ? templateRoutines(for: pet.petTypeEnum) : saved
            onRoutinesUpdated?(currentRoutines)
            return
        }

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
                Routine(title: "Mama",               iconName: "pawprint",       frequency: "Günde 2 kez"),
                Routine(title: "Su Kabı Temizliği",  iconName: "drop",           frequency: "Günde 1 kez"),
                Routine(title: "Tuvalet",            iconName: "trash",          frequency: "Günde 1 kez"),
                Routine(title: "Oyun",               iconName: "gamecontroller", frequency: "Günde 1 kez"),
                Routine(title: "Tüy Bakımı",         iconName: "scissors",       frequency: "Haftada 2 kez"),
                Routine(title: "Tırnak Kesimi",      iconName: "scissors",       frequency: "Ayda 1 kez"),
                Routine(title: "Veteriner Kontrolü", iconName: "stethoscope",    frequency: "Yılda 1 kez")
            ]
        case .dog:
            return [
                Routine(title: "Mama",               iconName: "pawprint",       frequency: "Günde 2 kez"),
                Routine(title: "Su Kabı Temizliği",  iconName: "drop",           frequency: "Günde 1 kez"),
                Routine(title: "Yürüyüş",            iconName: "figure.walk",    frequency: "Günde 2 kez"),
                Routine(title: "Oyun",               iconName: "gamecontroller", frequency: "Günde 1 kez"),
                Routine(title: "Tüy Bakımı",         iconName: "scissors",       frequency: "Haftada 1 kez"),
                Routine(title: "Tırnak Kesimi",      iconName: "scissors",       frequency: "Ayda 1 kez"),
                Routine(title: "Aşı Kontrolü",       iconName: "bandage",        frequency: "Yılda 1 kez")
            ]
        case .bird:
            return [
                Routine(title: "Mama",               iconName: "pawprint",       frequency: "Günde 1 kez"),
                Routine(title: "Su Değişimi",        iconName: "drop",           frequency: "Günde 1 kez"),
                Routine(title: "Kafes Temizliği",    iconName: "sparkles",       frequency: "Günde 1 kez"),
                Routine(title: "Güneş Işığı",        iconName: "sun.max",        frequency: "Günde 1 kez"),
                Routine(title: "Kanat Kontrolü",     iconName: "scissors",       frequency: "Ayda 1 kez"),
                Routine(title: "Veteriner Kontrolü", iconName: "stethoscope",    frequency: "Yılda 1 kez")
            ]
        case .fish:
            return [
                Routine(title: "Yem",                iconName: "drop.fill",      frequency: "Günde 1 kez"),
                Routine(title: "Filtre Kontrol",     iconName: "aqi.medium",     frequency: "Haftada 1 kez"),
                Routine(title: "Su Değişimi",        iconName: "drop.triangle",  frequency: "Haftada 1 kez"),
                Routine(title: "Cam Temizliği",      iconName: "sparkles",       frequency: "Ayda 1 kez"),
                Routine(title: "Dekor Düzenleme",    iconName: "leaf",           frequency: "3 Ayda 1 kez")
            ]
        case .unknown:
            return []
        }
    }
}
