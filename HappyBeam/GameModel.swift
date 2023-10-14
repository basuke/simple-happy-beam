/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's model type for game state and gameplay information.
*/

import AVKit
import RealityKit
import SwiftUI

/// State that drives the different screens of the game and options that players select.
class GameModel: ObservableObject {
    @Published var isPlaying = false
    @Published var isPaused = false {
        didSet {
            if isPaused == true {
                for child in spaceOrigin.children {
                    if child.name.contains("CCloud") {
                        child.stopAllAnimations(recursive: false)
                    }
                }
            } else {
                for child in spaceOrigin.children {
                    if child.name.contains("CCloud") {
                        let start = Point3D(child.position)
                        let end = Point3D(
                            start.vector + .init(
                                x: CloudSpawnParameters.deltaX,
                                y: CloudSpawnParameters.deltaY,
                                z: CloudSpawnParameters.deltaZ
                            )
                        )
                        
                        let line = FromToByAnimation<Transform>(
                            name: "line",
                            from: .init(scale: .init(repeating: 1), translation: simd_float(start.vector)),
                            to: .init(scale: .init(repeating: 1), translation: simd_float(end.vector)),
                            duration: CloudSpawnParameters.speed,
                            bindTarget: .transform
                        )
                        
                        let animation = try! AnimationResource
                            .generate(with: line)
                        
                        child.playAnimation(animation, transitionDuration: 0.0, startsPaused: false)
                        child.playAnimation(child.availableAnimations[0])
                    }
                }
            }
        }
    }
    
    /// A Boolean value that indicates that game assets have loaded.
    @Published var readyToStart = false
    
    @Published var isSpatial = false
    
    @Published var isFinished = false {
        didSet {
            if isFinished == true {
                clear()
            }
        }
    }
    
    @Published var isSoloReady = false
    
    static let gameTime = 35
    @Published var timeLeft = gameTime
    @Published var isCountDownReady = false
    
    @Published var countDown = 3
    @Published var score = 0
    @Published var isMuted = false

    @Published var clouds: [Cloud] = (0..<30).map { Cloud(id: $0, isHappy: false) }
    @Published var cloudSounds = [AudioFileResource]()

    /// Removes 3D content when then game is over.
    func clear() {
        spaceOrigin.children.removeAll()
    }
    
    /// Resets game state information.
    func reset() {
        isPlaying = false
        isPaused = false
        isFinished = false
        isSoloReady = false
        timeLeft = GameModel.gameTime
        isCountDownReady = false
        countDown = 3
        score = 0

        clouds = (0..<30).map { Cloud(id: $0, isHappy: false) }
        cloudNumber = 0
        hitCounts = [:]
        cloudIsHit = [:]
        cloudEntities = []

        clear()
    }
    
    /// Preload assets when the app launches to avoid pop-in during the game.
    init() {
        Task { @MainActor in
            
            guard let beamAsset = await loadFromRealityComposerPro(
                named: BundleAssets.heartBlasterEntity,
                fromSceneNamed: BundleAssets.heartBlasterScene
            ) else {
                fatalError("Unable to load beam from Reality Composer Pro project.")
            }
            beam = beamAsset
            beam.name = BundleAssets.beamName
            
            // Position the beam relative to the user's hand.
            beam.position = .init(x: 0, y: 0, z: -0.3)
            beam.orientation = simd_quatf(
                Rotation3D(angle: .degrees(90), axis: .y)
                    .rotated(by: Rotation3D(angle: .degrees(-90), axis: .z))
            )
            
            floorBeam = beam.clone(recursive: true)
            floorBeam.name = "floorBeam"
            floorBeam.position.z += 0.3
            
            let fireworks = try await Entity(named: "fireworks")
            globalFireworks = fireworks.children.first!.children.first!
            
            turret = await loadFromRealityComposerPro(named: BundleAssets.heartTurretEntity, fromSceneNamed: BundleAssets.heartTurretScene)
            turret?.name = "Holder"
            turret?.position = .init(x: 0, y: 0.25, z: -1.7)
            turret?.scale *= 0.3
            
            heart = await loadFromRealityComposerPro(named: BundleAssets.heartLightEntity, fromSceneNamed: BundleAssets.heartLightScene)
            heart?.name = "Heart Projector"
            heart?.generateCollisionShapes(recursive: true)
            heart?.position = .init(x: 0, y: 0.25, z: -1.7)
            heart?.position.y += 0.68
            heart?.scale *= 0.22
            heart?.components[InputTargetComponent.self] = InputTargetComponent(allowedInputTypes: .all)
            
            cloudTemplate = try? await Entity(named: BundleAssets.cloud)
            
            guard turret != nil, heart != nil, cloudTemplate != nil else {
                fatalError("Error loading assets.")
            }
            
            do {
                for number in 1...4 {
                    let resource = try await AudioFileResource(named: "cloudHit\(number).m4a")
                    cloudSounds.append(resource)
                }
            } catch {
                fatalError("Error loading cloud sound resources.")
            }
            
            // Generate animations inside the cloud models.
            let def = cloudTemplate!.availableAnimations[0].definition
            cloudAnimations[.sadBlink] = try .generate(with: AnimationView(source: def, trimStart: 1.0, trimEnd: 7.0))
            cloudAnimations[.smile] = try .generate(with: AnimationView(source: def, trimStart: 7.5, trimEnd: 10.0))
            cloudAnimations[.happyBlink] = try .generate(with: AnimationView(source: def, trimStart: 10.0, trimEnd: 15.0))
            
            generateCloudMovementAnimations()
            
            self.readyToStart = true
        }
    }
    
    /// Preload animation assets.
    func generateCloudMovementAnimations() {
        for index in (0..<cloudPaths.count) {
            let start = Point3D(
                x: cloudPaths[index].0,
                y: cloudPaths[index].1,
                z: cloudPaths[index].2
            )
            let end = Point3D(
                x: start.x + CloudSpawnParameters.deltaX,
                y: start.y + CloudSpawnParameters.deltaY,
                z: start.z + CloudSpawnParameters.deltaZ
            )
            let speed = CloudSpawnParameters.speed
            
            let line = FromToByAnimation<Transform>(
                name: "line",
                from: .init(scale: .init(repeating: 1), translation: simd_float(start.vector)),
                to: .init(scale: .init(repeating: 1), translation: simd_float(end.vector)),
                duration: speed,
                bindTarget: .transform
            )
            
            let animation = try! AnimationResource
                .generate(with: line)
            
            cloudMovementAnimations.append(animation)
        }
    }
}
