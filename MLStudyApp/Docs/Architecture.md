# Architecture & Workflow Guide

This guide explains how to extend the ML Study Quest app with new chapters from *Hands-On Machine Learning* while keeping the code modular and easy to maintain.

## 1. Content format

Lessons are defined in `Resources/content.json` using a JSON schema optimised for multiple question types and rich lesson blocks.

```jsonc
{
  "id": "UUID",
  "title": "Lesson title",
  "subtitle": "Lesson subtitle",
  "content": [
    {
      "id": "UUID",
      "type": "text | bulletList | callout | code | image",
      "text": "Optional paragraph or bullet list (newline separated)",
      "code": "Optional code snippet",
      "imageName": "Optional asset name"
    }
  ],
  "quiz": [
    {
      "id": "UUID",
      "type": "multipleChoice | fillInTheBlank | ordering",
      "prompt": "Question prompt",
      "options": [
        {
          "id": "UUID",
          "text": "Choice text",
          "isCorrect": true,
          "feedback": "Optional feedback shown after answering"
        }
      ],
      "correctAnswer": "Required for fillInTheBlank",
      "correctOrder": ["UUID", "UUID"],
      "explanation": "Shown after completing the quiz"
    }
  ]
}
```

- **Multiple choice** uses the `options` array with `isCorrect` flags.
- **Fill-in-the-blank** reads the `correctAnswer` string.
- **Ordering** questions provide the `correctOrder` array containing the option IDs in the desired sequence.

### Recommended authoring workflow

1. Export the chapter text from your eBook or PDF.
2. Split it into digestible lesson segments (5–10 minutes each).
3. For every section, capture key ideas, equations and code as `content` blocks.
4. Draft quizzes manually or use AI assistance, then review for accuracy before committing.
5. Run the app to verify that each lesson renders correctly and all question types behave as expected.

## 2. Modular app architecture

The app follows **MVVM** with services to separate concerns:

```
SwiftUI View ──> ViewModel ──> Services ──> Models / Persistence
          ^          |             |
          |          └── Publishes state via Combine
          └── Receives updates with @State / @ObservedObject
```

### Key modules

- **Models** (`Lesson`, `QuizQuestion`): Codable structures that mirror the JSON content.
- **ViewModels** (`LessonViewModel`, `QuizViewModel`): Fetch content, drive navigation, evaluate answers, update progress.
- **Services** (`ContentLoader`, `GamificationService`): Load JSON asynchronously and persist gamified state (XP, streaks, badges).
- **Views**: SwiftUI screens composed of small reusable components (`ProgressBar`, `ChoiceButtonStyle`).

This separation keeps UI code declarative while business logic and persistence stay testable and independent.

## 3. Beginner-friendly tooling

- **SwiftUI + Combine**: Minimal boilerplate for layout and state management. Works with the latest Xcode previews and supports accessibility out of the box.
- **GameKit (optional)**: Add real leaderboards and achievements when you are ready to ship.
- **Firebase / Firestore (optional)**: Cloud sync, remote config and analytics with simple SDKs.
- **Swift Playgrounds**: Useful if you prefer building the UI interactively on iPad/Mac without a full Xcode setup.

If you need a visual builder or cross-platform deployment, consider FlutterFlow or React Native, but the included codebase is fully native iOS.

## 4. Converting book chapters into modules

1. **Ingest**: Use scripts (Python or Swift command-line) to extract raw chapter text.
2. **Chunk**: Identify high-yield concepts, definitions and diagrams. Store them as `content` blocks. Code snippets can be fenced with triple backticks to retain formatting before inserting into JSON.
3. **Question generation**: Use AI to propose multiple-choice, cloze and ordering questions. Keep explanations brief and actionable. Validate each question manually.
4. **Gamify**: Tag milestone lessons with custom XP rewards or achievements by extending `GamificationService`. Example: award extra XP for completing a long chapter.
5. **Iterate**: Observe learner behaviour (e.g., where they fail) and refine content or add callouts. You can extend the JSON schema with difficulty ratings or tags without breaking existing code thanks to Codable defaults.

## 5. Next steps

- Add **spaced repetition** by saving question outcomes and resurfacing incorrect answers.
- Implement **daily quests** and notifications to keep streaks alive.
- Expand question types (drag-and-drop matching, code tracing) by creating new SwiftUI views that conform to the same `QuizQuestionType` pattern.

With this guide and the included SwiftUI source files, you have a production-ready foundation for a fully gamified iOS learning companion.
