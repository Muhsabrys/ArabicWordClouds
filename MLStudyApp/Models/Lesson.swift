import Foundation

struct Lesson: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let content: [ContentBlock]
    let quiz: [QuizQuestion]

    struct ContentBlock: Identifiable, Codable {
        let id: UUID
        let type: ContentType
        let text: String?
        let code: String?
        let imageName: String?

        enum ContentType: String, Codable {
            case text
            case bulletList
            case code
            case image
            case callout
        }
    }
}
