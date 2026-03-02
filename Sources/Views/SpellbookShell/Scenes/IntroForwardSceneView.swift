import SwiftUI

struct IntroForwardSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            chapterNumber: 1,
            chapterTitle: "How AI\nMakes Decisions",
            missionText: "Watch signals travel through the network — left to right, layer by layer — until a prediction appears.",
            whyText: "Every AI on the planet works this way. ChatGPT, image recognition, self-driving cars — it all starts here.",
            buttonTitle: "PLAY CHAPTER I",
            onBegin: onBegin
        )
    }
}
