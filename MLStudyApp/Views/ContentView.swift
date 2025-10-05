import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LessonViewModel()
    @EnvironmentObject private var gamification: GamificationService

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Your Progress")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Streak: \(gamification.dailyStreak) 🔥")
                                .font(.headline)
                            Text("XP: \(gamification.xp)")
                                .font(.subheadline)
                        }
                        Spacer()
                        BadgeSummaryView(badges: gamification.badges)
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Lessons")) {
                    ForEach(viewModel.lessons) { lesson in
                        NavigationLink(lesson.title) {
                            LessonDetailView(lesson: lesson)
                        }
                        .badge(lesson.quiz.count)
                    }
                }
            }
            .navigationTitle("ML Study Quest")
            .overlay {
                if viewModel.lessons.isEmpty {
                    ProgressView("Loading content…")
                }
            }
            .alert("Unable to load content", isPresented: Binding(
                get: { viewModel.loadingError != nil },
                set: { _ in viewModel.loadingError = nil }
            )) {
                Button("Retry") {
                    viewModel.loadLessons()
                }
            } message: {
                if let error = viewModel.loadingError {
                    Text(error)
                }
            }
        }
    }
}

struct BadgeSummaryView: View {
    let badges: [Badge]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(badges.prefix(3)) { badge in
                Text(badge.type.rawValue)
                    .font(.caption2)
                    .padding(6)
                    .background(Capsule().fill(Color.blue.opacity(0.2)))
            }
            if badges.count > 3 {
                Text("+\(badges.count - 3)")
                    .font(.caption)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GamificationService())
}
