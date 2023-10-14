/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The main view.
*/

import Combine
import SwiftUI
import RealityKit

struct HappyBeam: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @EnvironmentObject var gameModel: GameModel
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var subscriptions = Set<AnyCancellable>()
    
    var body: some View {
        let gameState = GameScreen.from(state: gameModel)
        VStack {
            Spacer()
            Group {
                switch gameState {
                case .start:
                    Start()
                case .soloPlay:
                    SoloPlay()
                case .lobby:
                    Lobby()
                case .soloScore:
                    SoloScore()
                }
            }
            .glassBackgroundEffect(
                in: RoundedRectangle(
                    cornerRadius: 32,
                    style: .continuous
                )
            )
        }
        
        .onReceive(timer) { _ in
            if gameModel.isPlaying && gameModel.isSoloReady {
                if gameModel.timeLeft > 0 && !gameModel.isPaused {
                    gameModel.timeLeft -= 1
                    if (gameModel.timeLeft % 5 == 0 || gameModel.timeLeft == GameModel.gameTime - 1) && gameModel.timeLeft > 4 {
                        Task { @MainActor () -> Void in
                            do {
                                let spawnAmount = 3
                                for _ in (0..<spawnAmount) {
                                    _ = try await spawnCloud()
                                    try await Task.sleep(for: .milliseconds(300))
                                }
                                
                                postCloudOverviewAnnouncement(gameModel: gameModel)
                            } catch {
                                print("Error spawning a cloud:", error)
                            }
                            
                        }
                    }
                } else if gameModel.timeLeft == 0 {
                    print("Game finished.")
                    gameModel.isFinished = true
                    gameModel.timeLeft = -1
                }
            }
            
            if gameModel.isCountDownReady && gameModel.countDown > 0 {
                var attrStr = AttributedString("\(gameModel.countDown)")
                attrStr.accessibilitySpeechAnnouncementPriority = .high
                AccessibilityNotification.Announcement("\(gameModel.countDown)").post()
                gameModel.countDown -= 1
            } else if gameModel.countDown == 0 {
                gameModel.isSoloReady = true
                Task {
                    await openImmersiveSpace(id: "happyBeam")
                }
                gameModel.countDown = -1
            }
        }
    }
}

#Preview {
    HappyBeam()
        .environmentObject(GameModel())
}

extension UUID {
    var asPlayerName: String {
        String(uuidString.split(separator: "-").last!)
    }
}

enum GameScreen {
    static func from(state: GameModel) -> Self {
        if !state.isPlaying {
            return .start
        } else if state.isPlaying {
            if !state.isFinished {
                if !state.isSoloReady {
                    return .lobby
                } else {
                    return .soloPlay
                }
            } else {
                return .soloScore
            }
        }
        
        return .start
    }
    
    case start
    case soloPlay
    case soloScore
    case lobby
}

