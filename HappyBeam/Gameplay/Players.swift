/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Data structures for multiplayer.
*/

import SwiftUI

/// Data about a player in a multiplayer session.
class Player {
    let name: String
    var score: Int
    let color: Color
    
    init(name: String, score: Int, color: Color) {
        self.name = name
        self.score = score
        self.color = color
    }
    
    /// The local player, "me".
    static var local: Player? = .init(name: "Altus", score: 7, color: .green)
}

// A utility to randomly assign players a theme color for some UI presentations.
extension Color {
    static func random() -> Self {
        [.red, .blue, .green, .pink, .purple].randomElement()!
    }
}
