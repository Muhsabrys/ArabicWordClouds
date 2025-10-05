import SwiftUI

struct LessonDetailView: View {
    @EnvironmentObject private var gamification: GamificationService
    @State private var showQuiz = false
    let lesson: Lesson

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(lesson.title)
                    .font(.largeTitle)
                    .bold()
                Text(lesson.subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                ForEach(lesson.content) { block in
                    switch block.type {
                    case .text:
                        Text(block.text ?? "")
                            .font(.body)
                    case .bulletList:
                        BulletListView(text: block.text ?? "")
                    case .code:
                        CodeBlockView(code: block.code ?? "")
                    case .image:
                        if let imageName = block.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    case .callout:
                        CalloutView(text: block.text ?? "")
                    }
                }

                Button {
                    showQuiz.toggle()
                } label: {
                    Label("Start Quiz", systemImage: "gamecontroller")
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .sheet(isPresented: $showQuiz) {
            QuizView(viewModel: QuizViewModel(lesson: lesson, gamification: gamification))
        }
    }
}

struct BulletListView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(text.split(separator: "\n"), id: \.self) { line in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                    Text(line.trimmingCharacters(in: .whitespaces))
                }
            }
        }
    }
}

struct CalloutView: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.title2)
                .foregroundColor(.yellow)
            Text(text)
                .font(.body)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow.opacity(0.2)))
    }
}

struct CodeBlockView: View {
    let code: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.85)))
                .foregroundColor(.green)
        }
    }
}

#Preview {
    LessonDetailView(lesson: .preview)
        .environmentObject(GamificationService())
}

private extension Lesson {
    static var preview: Lesson {
        Lesson(
            id: UUID(),
            title: "Introduction to Machine Learning",
            subtitle: "What is ML and why it matters",
            content: [
                Lesson.ContentBlock(
                    id: UUID(),
                    type: .text,
                    text: "Machine learning allows systems to learn from data without being explicitly programmed.",
                    code: nil,
                    imageName: nil
                )
            ],
            quiz: []
        )
    }
}
