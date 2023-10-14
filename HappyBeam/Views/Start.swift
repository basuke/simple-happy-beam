/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The start screen for the game.
*/

import SwiftUI
import GroupActivities

struct Start: View {
    @EnvironmentObject var gameModel: GameModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    @StateObject private var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Image("splashScreen")
                .resizable()
                .frame(width: 337, height: 211)
                .accessibilityHidden(true)
            Text("Happy Beam")
                .font(.system(size: 30, weight: .bold))
            Text("Cheer up grumpy clouds by shining a happy beam with your heart.")
                .multilineTextAlignment(.center)
                .font(.headline)
                .frame(width: 340)
                .padding(.bottom, 10)
            if gameModel.readyToStart {
                Group {
                    Button {
                        gameModel.isPlaying = true
                        gameModel.timeLeft = GameModel.gameTime
                    } label: {
                        Text("Play")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!gameModel.readyToStart)
                }
                .font(.system(size: 16, weight: .bold))
                .frame(width: 180)
            } else {
                ProgressView("Loading assets...")
            }
            
            Spacer()
        }
        .padding(.horizontal, 150)
        .frame(width: 634, height: 499)
    }
}

#Preview {
    Start()
        .environmentObject(GameModel())
        .glassBackgroundEffect(
            in: RoundedRectangle(
                cornerRadius: 32,
                style: .continuous
            )
        )
}
