/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The input selection and waiting screen before the game starts.
*/

import SwiftUI

struct Lobby: View {
    @EnvironmentObject var gameModel: GameModel
    
    var progressValue: Float {
        min(1, max(0, Float(gameModel.countDown) / 3.0 + 0.01))
    }
    
    var body: some View {
        Gauge(value: progressValue) {
            EmptyView()
        }
        .labelsHidden()
        .animation(.default, value: progressValue)
        .gaugeStyle(.accessoryCircularCapacity)
        .scaleEffect(3)
        .frame(width: 150, height: 150)
        .padding(75)
        .overlay {
            Text(verbatim: "\(gameModel.countDown)")
                .animation(.none, value: progressValue)
                .font(.system(size: 64))
                .bold()
        }
        .frame(width: 634, height: 499)
        .accessibilityHidden(true)
        .onAppear() {
            gameModel.isCountDownReady = true
        }
    }
}

#Preview {
    Lobby()
        .environmentObject(GameModel())
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32,
                style: .continuous
            )
        )
}
