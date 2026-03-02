import SwiftUI

struct IntroInspectSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            chapterNumber: 5,
            chapterTitle: "Look Inside\nthe AI",
            missionText: "Tap each neuron to reveal what it learned — its activation value, its role, and how much blame it carried.",
            whyText: "AI isn't a black box. Every neuron has a story. This is the chapter where the math becomes meaning.",
            buttonTitle: "PLAY CHAPTER V",
            onBegin: onBegin
        )
    }
}
