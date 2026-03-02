import SwiftUI

struct IntroBackpropSceneView: View {
    let onBegin: () -> Void

    var body: some View {
        IntroBeatSceneTemplate(
            chapterNumber: 3,
            chapterTitle: "How AI\nActually Learns",
            missionText: "Watch the error trace backward through every layer and nudge each connection closer to the right answer.",
            whyText: "This is literally how every AI on the planet learns from its mistakes — including GPT and everything after it.",
            buttonTitle: "PLAY CHAPTER III",
            onBegin: onBegin
        )
    }
}
