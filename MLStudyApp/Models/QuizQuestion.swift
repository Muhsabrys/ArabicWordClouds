import Foundation

enum QuizQuestionType: String, Codable {
    case multipleChoice
    case fillInTheBlank
    case ordering
}

struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let type: QuizQuestionType
    let prompt: String
    let explanation: String?
    let options: [QuizOption]?
    let correctAnswer: String?
    let correctOrder: [UUID]?

    struct QuizOption: Identifiable, Codable {
        let id: UUID
        let text: String
        let isCorrect: Bool
        let feedback: String?
    }
}
