import Foundation
import Combine

protocol ContentLoading {
    func loadLessons() -> AnyPublisher<[Lesson], Error>
}

final class ContentLoader: ContentLoading {
    private let fileName: String

    init(fileName: String = "content") {
        self.fileName = fileName
    }

    func loadLessons() -> AnyPublisher<[Lesson], Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    guard let url = Bundle.main.url(forResource: self.fileName, withExtension: "json") else {
                        throw ContentLoaderError.fileNotFound
                    }
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let lessons = try decoder.decode([Lesson].self, from: data)
                    promise(.success(lessons))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

enum ContentLoaderError: LocalizedError {
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Could not locate the content file in the app bundle."
        }
    }
}
