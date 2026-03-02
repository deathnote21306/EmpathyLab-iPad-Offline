import SwiftUI

struct IntroLossSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            chapterNumber: 2,
            chapterTitle: "Measuring\nthe Mistake",
            missionText: "See exactly how wrong the AI's first guess was — and watch that error become a single number.",
            whyText: "You can't fix what you can't measure. Without this number, learning is impossible.",
            buttonTitle: "PLAY CHAPTER II",
            onBegin: onBegin
        )
    }
}
