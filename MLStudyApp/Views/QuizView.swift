import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var fillInBlankAnswer: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ProgressBar(progress: viewModel.progress)
                    .frame(height: 12)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Question \(viewModel.currentIndex + 1) of \(viewModel.questions.count)")
                        .font(.headline)
                    Text(viewModel.currentQuestion.prompt)
                        .font(.title2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                questionBody
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("Lesson Quiz")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Great job!", isPresented: $viewModel.showResults) {
                Button("Done") {
                    dismiss()
                }
                Button("Restart") {
                    viewModel.restart()
                }
            } message: {
                Text("You scored \(viewModel.score) / \(viewModel.questions.count)")
            }
        }
    }

    @ViewBuilder
    private var questionBody: some View {
        switch viewModel.currentQuestion.type {
        case .multipleChoice:
            MultipleChoiceView(options: viewModel.currentQuestion.options ?? []) { option in
                viewModel.answerMultipleChoice(option: option)
            }
        case .fillInTheBlank:
            VStack(alignment: .leading, spacing: 12) {
                TextField("Type your answer", text: $fillInBlankAnswer)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .onSubmit {
                        viewModel.answerFillInBlank(fillInBlankAnswer)
                        fillInBlankAnswer = ""
                    }
                Button("Submit") {
                    viewModel.answerFillInBlank(fillInBlankAnswer)
                    fillInBlankAnswer = ""
                }
                .buttonStyle(.borderedProminent)
            }
        case .ordering:
            OrderingQuestionView(options: viewModel.currentQuestion.options ?? [], userOrdering: $viewModel.userOrdering)
            Button("Lock Order") {
                viewModel.commitOrdering()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.userOrdering.isEmpty)
        }
    }
}

private struct MultipleChoiceView: View {
    let options: [QuizQuestion.QuizOption]
    var onSelect: (QuizQuestion.QuizOption) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                Button {
                    onSelect(option)
                } label: {
                    HStack {
                        Text(option.text)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(ChoiceButtonStyle())
            }
        }
    }
}

private struct OrderingQuestionView: View {
    let options: [QuizQuestion.QuizOption]
    @Binding var userOrdering: [UUID]

    var body: some View {
        List {
            ForEach(userOrdering, id: \.self) { id in
                if let option = options.first(where: { $0.id == id }) {
                    Text(option.text)
                }
            }
            .onMove { indices, newOffset in
                userOrdering.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .listStyle(.inset)
        .environment(\.editMode, .constant(.active))
        .task {
            if userOrdering.isEmpty {
                userOrdering = options.map { $0.id }
            }
        }
    }
}

#Preview {
    let lesson = Lesson.preview
    let vm = QuizViewModel(lesson: lesson, gamification: GamificationService())
    return QuizView(viewModel: vm)
}
