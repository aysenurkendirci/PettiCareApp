//
//  Routine.swift
//  PetCareAppTask3
//
//  Created by Ayşe Nur Kendirci on 29.07.2025.
//

import Foundation
import SwiftData

/// Tek bir rutini (ör: "Mama Ver", "Gezdir") temsil eder.
@Model
final class Routine {
    var title: String
    var iconName: String
    var frequency: String
    var createdAt: Date
    @Relationship(inverse: \Pet.routines) var pet: Pet?

    // ✅ Tamamlama takibi için eklendi
    var lastCompletedDate: Date? = nil       // en son ne zaman yapıldı
    var doneCountInPeriod: Int = 0           // içinde bulunulan periyotta kaç kez yapıldı

    init(
        title: String,
        iconName: String,
        frequency: String,
        createdAt: Date = Date(),
        pet: Pet? = nil
    ) {
        self.title = title
        self.iconName = iconName
        self.frequency = frequency
        self.createdAt = createdAt
        self.pet = pet
    }
}

/// Belirli bir tarih ve pet türü için tanımlanmış günlük rutinleri içerir.
struct DailyRoutine {
    let date: Date
    let petType: PetType
    var routines: [Routine]
}
