import SwiftData

@Model
final class RoutineCompletion {
    var dateKey: String          // "yyyy-MM-dd"
    var createdAt: Date
    @Relationship(inverse: \Routine.completions) var routine: Routine?

    init(dateKey: String, createdAt: Date = Date()) {
        self.dateKey = dateKey
        self.createdAt = createdAt
    }
}

extension Date {
    var dayKey: String {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale = .init(identifier: "tr_TR")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
}
