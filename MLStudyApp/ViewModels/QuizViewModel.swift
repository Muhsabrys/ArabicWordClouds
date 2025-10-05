import Foundation
import Combine

final class QuizViewModel: ObservableObject {
    @Published private(set) var questions: [QuizQuestion]
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var answeredQuestions: Set<UUID> = []
    @Published var showResults: Bool = false
    @Published var userOrdering: [UUID] = []

    let lesson: Lesson
    private let gamification: GamificationService

    init(lesson: Lesson, gamification: GamificationService) {
        self.lesson = lesson
        self.gamification = gamification
        self.questions = lesson.quiz
    }

    var currentQuestion: QuizQuestion {
        questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    func answerMultipleChoice(option: QuizQuestion.QuizOption) {
        guard !answeredQuestions.contains(currentQuestion.id) else { return }

        answeredQuestions.insert(currentQuestion.id)
        if option.isCorrect {
            score += 1
            gamification.addXP(lessonID: lesson.id, amount: 10)
        }
        nextQuestion()
    }

    func answerFillInBlank(_ answer: String) {
        guard !answeredQuestions.contains(currentQuestion.id) else { return }
        answeredQuestions.insert(currentQuestion.id)
        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed == currentQuestion.correctAnswer?.lowercased() {
            score += 1
            gamification.addXP(lessonID: lesson.id, amount: 10)
        }
        nextQuestion()
    }

    func commitOrdering() {
        guard !answeredQuestions.contains(currentQuestion.id),
              currentQuestion.type == .ordering,
              currentQuestion.correctOrder != nil else { return }

        answeredQuestions.insert(currentQuestion.id)
        if userOrdering == currentQuestion.correctOrder {
            score += 1
            gamification.addXP(lessonID: lesson.id, amount: 12)
        }
        nextQuestion()
    }

    private func nextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            userOrdering = currentQuestion.options?.map { $0.id } ?? []
        } else {
            showResults = true
            gamification.completeLesson(lessonID: lesson.id, score: score, total: questions.count)
        }
    }

    func restart() {
        score = 0
        currentIndex = 0
        answeredQuestions.removeAll()
        showResults = false
        userOrdering = currentQuestion.options?.map { $0.id } ?? []
    }
}
