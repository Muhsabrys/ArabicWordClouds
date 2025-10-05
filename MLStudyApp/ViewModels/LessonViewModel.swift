import Foundation
import Combine

final class LessonViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []
    @Published var selectedLesson: Lesson?
    @Published var loadingError: String?

    private let loader: ContentLoading
    private var cancellables: Set<AnyCancellable> = []

    init(loader: ContentLoading = ContentLoader()) {
        self.loader = loader
        loadLessons()
    }

    func loadLessons() {
        loader.loadLessons()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.loadingError = error.localizedDescription
                }
            } receiveValue: { lessons in
                self.lessons = lessons
                self.selectedLesson = lessons.first
            }
            .store(in: &cancellables)
    }
}
