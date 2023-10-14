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
        if !gameModel.isInputSelected {
            inputSelection
                .frame(width: 634, height: 499)
        } else {
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
        }
    }
    
    var inputSelection: some View {
        VStack {
            Text("Choose how you’ll cheer up grumpy clouds.")
                .font(.title)
                .padding(.top, 40)
                .padding(.bottom, 30)
            HStack(alignment: .top, spacing: 30) {
                VStack {
                    Button {
                        chooseInputAndReady(.hands)
                    } label: {
                        Label {
                            Text("Make a heart with two hands.")
                        } icon: {
                            Image("gesture_hand")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 216, height: 216)
                                .scaleEffect(x: 1.18, anchor: .center)
                                .offset(y: 30)
                        }
                        .labelStyle(.iconOnly)
                    }
                    .buttonBorderShape(.roundedRectangle(radius: 28))
                    .padding(.bottom, 10)
                    
                    Text("Make a heart with two hands.")
                        .font(.headline)
                        .frame(width: 216)
                        .accessibilityHidden(true)
                }

                VStack {
                    Button {
                        chooseInputAndReady(.alternative)
                    } label: {
                        Label {
                            Text("Use a pinch gesture or a compatible device.")
                        } icon: {
                            Image("keyboardGameController")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 216, height: 216)
                        }
                        .labelStyle(.iconOnly)
                    }
                    .buttonBorderShape(.roundedRectangle(radius: 28))
                    .padding(.bottom, 10)
                    
                    Text("Use a pinch gesture or a compatible device.")
                        .font(.headline)
                        .frame(width: 216)
                        .accessibilityHidden(true)
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        }
    }
    
    func chooseInputAndReady(_ kind: InputKind) {
        gameModel.isInputSelected = true
        gameModel.inputKind = kind
        
        // Delay three seconds, then...
        gameModel.isCountDownReady = true
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
