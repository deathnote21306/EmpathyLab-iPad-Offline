import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    let progressText: String
    let isComplete: Bool

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(progressText)
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)

                Text(lesson.title)
                    .font(Typography.title)

                Text(lesson.goal)
                    .font(Typography.section)
                    .foregroundStyle(Theme.accent)

                Text(lesson.narrative)
                    .font(Typography.body)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(lesson.prompts, id: \.self) { prompt in
                        Label(prompt, systemImage: "circle.fill")
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Label(isComplete ? "Task complete" : "Try the task", systemImage: isComplete ? "checkmark.circle.fill" : "sparkles")
                        .foregroundStyle(isComplete ? Theme.success : .secondary)
                }
                .padding(.top, 4)
            }
        }
    }
}
