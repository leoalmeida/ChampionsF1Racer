/*
* Copyright (c) 2015-2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import SpriteKit
import GameplayKit

protocol GameSceneProtocol {
  func didSelectCancelButton(gameScene: GameScene)
  func didShowOverlay(gameScene: GameScene)
  func didDismissOverlay(gameScene: GameScene)
}

class GameScene: SKScene {

  var gameSceneDelegate: GameSceneProtocol?
  
  var carType: CarType!
  var levelType: LevelType!
  
  var lastUpdateTimeInterval: NSTimeInterval = 0
  
  var box1: SKSpriteNode!, box2: SKSpriteNode!
  var laps: SKLabelNode!, time: SKLabelNode!
  
  var maxSpeed = 0
  
  var boxSoundAction: SKAction!, hornSoundAction: SKAction!,
    lapSoundAction: SKAction!, nitroSoundAction: SKAction!
 
  var buttons = [ButtonNode]()
  
  var priorTouch: CGPoint = .zero
  var focusChangesEnabled = false
  
  var overlay: SceneOverlay? {
    didSet {
      
      buttons = []
      oldValue?.backgroundNode.removeFromParent()
      
      if let overlay = overlay, camera = camera {
        camera.addChild(overlay.backgroundNode)
        
        buttons = findAllButtonsInScene()

        #if os(tvOS)
        resetFocus()
        #endif
        
        focusChangesEnabled = true
        
        gameSceneDelegate?.didShowOverlay(self)
      } else {
        focusChangesEnabled = false
        gameSceneDelegate?.didDismissOverlay(self)
      }
    }
  }
  
  lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
      GameActiveState(gameScene: self),
      GamePauseState(gameScene: self),
      GameFailureState(gameScene: self),
      GameSuccessState(gameScene: self)
    ])
  
  override func didMoveToView(view: SKView) {
    
    setupPhysicsBodies()
    
    ButtonNode.parseButtonInNode(self)
    
    let pauseButton = childNodeWithName("pause") as! SKSpriteNode
    pauseButton.anchorPoint = .zero
    pauseButton.position = CGPoint(x: size.width - pauseButton.size.width, y: size.height - pauseButton.size.height - overlapAmount()/2)
    
    #if os(tvOS)
      pauseButton.removeFromParent()
    #endif
    
    boxSoundAction = SKAction.playSoundFileNamed("box.wav",
      waitForCompletion: false)
    hornSoundAction = SKAction.playSoundFileNamed("horn.wav",
      waitForCompletion: false)
    lapSoundAction = SKAction.playSoundFileNamed("lap.wav",
      waitForCompletion: false)
    nitroSoundAction = SKAction.playSoundFileNamed("nitro.wav",
      waitForCompletion: false)
    
    box1 = childNodeWithName("box_1") as! SKSpriteNode
    box2 = childNodeWithName("box_2") as! SKSpriteNode
    
    laps = self.childNodeWithName("laps_label") as! SKLabelNode
    time = self.childNodeWithName("time_left_label") as! SKLabelNode
    
    let camera = SKCameraNode()
    scene?.camera = camera
    scene?.addChild(camera)
    setCameraPosition(CGPoint(x: size.width/2, y: size.height/2))
    
    stateMachine.enterState(GameActiveState.self)
  }
 
  override func update(currentTime: CFTimeInterval) {
    
    let deltaTime = currentTime - lastUpdateTimeInterval
    stateMachine.updateWithDeltaTime(deltaTime)
  }
  
  func setupPhysicsBodies() {
    let innerBoundary = SKNode()
    
    let track = childNodeWithName("track")!
    innerBoundary.position = CGPoint(x: track.position.x + track.frame.size.width/2, y: track.position.y + track.frame.size.height/2)

    addChild(innerBoundary)

    innerBoundary.physicsBody = SKPhysicsBody(rectangleOfSize:
      CGSizeMake(720, 480))
    innerBoundary.physicsBody!.dynamic = false

    let trackFrame = CGRectInset(
      self.childNodeWithName("track")!.frame, 200, 0)

    let maxAspectRatio: CGFloat = 3.0/2.0 // iPhone 4
    let maxAspectRatioHeight = trackFrame.size.width / maxAspectRatio
    let playableMarginY: CGFloat = (trackFrame.size.height - maxAspectRatioHeight)/2
    let playableMarginX: CGFloat = (frame.size.width - trackFrame.size.width)/2

    let playableRect = CGRect(x: playableMarginX,
                              y: playableMarginY,
                              width: trackFrame.size.width,
                              height: trackFrame.size.height - playableMarginY*2)
    
    physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
  }
  
  func overlapAmount() -> CGFloat {
    guard let view = self.view else {
      return 0
    }
    let scale = view.bounds.size.width / self.size.width
    let scaledHeight = self.size.height * scale
    let scaledOverlap = scaledHeight - view.bounds.size.height
    return scaledOverlap / scale
  }
  
  func setCameraPosition(position: CGPoint) {
    scene?.camera?.position = CGPoint(x: position.x, y: position.y - overlapAmount()/2)
  }
}

extension GameScene: InputControlProtocol {
  func directionChangedWithMagnitude(position: CGPoint) {
    if paused {
      return
    }
    
    if let car = self.childNodeWithName("car") as? SKSpriteNode, carPhysicsBody = car.physicsBody {
      
      carPhysicsBody.velocity = CGVector(
        dx: position.x * CGFloat(maxSpeed),
        dy: position.y * CGFloat(maxSpeed))
      
      if position != CGPointZero {
        car.zRotation = CGPoint(x: position.x, y: position.y).angle
      }
    }
  }
}
  