import Foundation
import Combine

final class GamificationService: ObservableObject {
    @Published private(set) var dailyStreak: Int
    @Published private(set) var lastActiveDate: Date?
    @Published private(set) var xp: Int
    @Published private(set) var completedLessons: Set<UUID>
    @Published private(set) var badges: [Badge]

    private let calendar: Calendar
    init(calendar: Calendar = .current) {
        self.calendar = calendar
        let state = GamificationStateStore.load()
        self.dailyStreak = state.dailyStreak
        self.lastActiveDate = state.lastActiveDate
        self.xp = state.xp
        self.completedLessons = state.completedLessons
        self.badges = state.badges
    }

    func addXP(lessonID: UUID, amount: Int) {
        xp += amount
        updateStreak()
        checkBadges(afterCompleting: lessonID)
        persistState()
    }

    func completeLesson(lessonID: UUID, score: Int, total: Int) {
        completedLessons.insert(lessonID)
        if Double(score) / Double(total) >= 0.8 {
            addBadgeIfNeeded(.highScore)
        }
        updateStreak()
        persistState()
    }

    private func updateStreak() {
        let today = calendar.startOfDay(for: Date())
        defer { lastActiveDate = today }

        guard let lastActive = lastActiveDate else {
            dailyStreak = 1
            return
        }

        let previous = calendar.startOfDay(for: lastActive)
        if calendar.isDate(today, inSameDayAs: previous) {
            return
        }

        if let days = calendar.dateComponents([.day], from: previous, to: today).day, days == 1 {
            dailyStreak += 1
            addBadgeIfNeeded(.streakStarter)
        } else {
            dailyStreak = 1
        }
    }

    private func checkBadges(afterCompleting lessonID: UUID) {
        if completedLessons.count == 1 {
            addBadgeIfNeeded(.firstLesson)
        }
        if xp >= 100 {
            addBadgeIfNeeded(.centuryClub)
        }
    }

    private func addBadgeIfNeeded(_ badgeType: Badge.BadgeType) {
        guard !badges.contains(where: { $0.type == badgeType }) else { return }
        badges.append(Badge(type: badgeType, earnedAt: Date()))
        persistState()
    }

    private func persistState() {
        let state = GamificationState(
            dailyStreak: dailyStreak,
            lastActiveDate: lastActiveDate,
            xp: xp,
            completedLessons: completedLessons,
            badges: badges
        )
        GamificationStateStore.save(state)
    }
}

struct Badge: Identifiable, Codable, Hashable {
    enum BadgeType: String, Codable, CaseIterable {
        case firstLesson = "First Lesson"
        case streakStarter = "Streak Starter"
        case centuryClub = "Century Club"
        case highScore = "High Score"
    }

    let id: UUID
    let type: BadgeType
    let earnedAt: Date

    init(id: UUID = UUID(), type: BadgeType, earnedAt: Date) {
        self.id = id
        self.type = type
        self.earnedAt = earnedAt
    }
}

private struct GamificationState: Codable {
    let dailyStreak: Int
    let lastActiveDate: Date?
    let xp: Int
    let completedLessons: Set<UUID>
    let badges: [Badge]
}

private enum GamificationStateStore {
    private static let key = "com.mlstudyapp.gamification"

    static func load() -> GamificationState {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let state = try? JSONDecoder().decode(GamificationState.self, from: data)
        else {
            return GamificationState(
                dailyStreak: 0,
                lastActiveDate: nil,
                xp: 0,
                completedLessons: [],
                badges: []
            )
        }
        return state
    }

    static func save(_ state: GamificationState) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
