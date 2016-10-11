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

class GameActiveState: GKState {

  unowned let gameScene: GameScene
  
  private var timeInSeconds = 0
  private var numberOfLaps = 0
  private var trackCenter = CGPoint.zero
  private var nextProgressAngle = M_PI
  
  private var previousTimeInterval: NSTimeInterval = 0
  
  init(gameScene: GameScene) {
    self.gameScene = gameScene
    super.init()
    
    initializeGame()
  }
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    switch stateClass {
      case is GamePauseState.Type, is GameFailureState.Type, is GameSuccessState.Type:
        return true
      default:
        return false
    }
  }
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(previousState)
    
    if previousState is GameSuccessState {
      restartLevel()
    }
  }
  
  override func updateWithDeltaTime(seconds: NSTimeInterval) {
    super.updateWithDeltaTime(seconds)
    
    if previousTimeInterval == 0 {
      previousTimeInterval = seconds
    }

    if gameScene.paused {
      previousTimeInterval = seconds
      return
    }

    if seconds - previousTimeInterval >= 1 {
      timeInSeconds -= 1
      previousTimeInterval = seconds

      if timeInSeconds >= 0 {
        updateLabels()
      }
    }

    let carPosition = gameScene.childNodeWithName("car")!.position
    let vector = carPosition - trackCenter
    let progressAngle = Double(vector.angle) + M_PI

    //1
    if progressAngle > nextProgressAngle
      && (progressAngle - nextProgressAngle) < M_PI_4 {

        //2
        nextProgressAngle += M_PI_2

        //3
        if nextProgressAngle >= (2 * M_PI) {
          nextProgressAngle = 0
        }

        //4
        if fabs(nextProgressAngle - M_PI) < Double(FLT_EPSILON) {
          //lap completed!
          numberOfLaps -= 1
          
          updateLabels()
          gameScene.runAction(gameScene.lapSoundAction)
        }
    }

    if timeInSeconds < 0 || numberOfLaps == 0 {
      if numberOfLaps == 0 {
        stateMachine?.enterState(GameSuccessState.self)
      } else {
        stateMachine?.enterState(GameFailureState.self)
      }
    }
  }
  
  private func initializeGame() {
    
    loadLevel()
    loadTrackTexture()
    loadCarTexture()
    updateLabels()
    
    gameScene.maxSpeed = 500 * (2 + gameScene.carType.rawValue)
    
    let track = gameScene.childNodeWithName("track") as! SKSpriteNode
    trackCenter = CGPoint(x: track.size.width/2, y: track.size.height/2)
  }
  
  private func restartLevel() {
    loadLevel()
    updateLabels()
    
    let car = gameScene.childNodeWithName("car") as! SKSpriteNode
    car.position = CGPoint(x: 884, y: 442)
    car.resetPhysicsForcesAndVelocity()
    
    gameScene.box1.resetPhysicsForcesAndVelocity()
    gameScene.box2.resetPhysicsForcesAndVelocity()
    
    gameScene.box1.position = CGPoint(x: 1722, y: 762)
    gameScene.box2.position = CGPoint(x: 314, y: 746)
  }
  
  private func loadLevel() {
    let filePath = NSBundle.mainBundle().pathForResource(
      "LevelDetails", ofType: "plist")!
    
    let levels = NSArray(contentsOfFile: filePath)!
    
    let levelData = levels[gameScene.levelType.rawValue] as! NSDictionary
    
    timeInSeconds = levelData["time"] as! Int
    numberOfLaps = levelData["laps"] as! Int
  }
  
  private func loadTrackTexture() {
    if let track  = gameScene.childNodeWithName("track") as? SKSpriteNode {
      track.texture = SKTexture(imageNamed:
        "track_\(gameScene.levelType.rawValue + 1)")
    }
  }
  
  private func loadCarTexture() {
    if let car = gameScene.childNodeWithName("car") as? SKSpriteNode {
      car.texture = SKTexture(imageNamed:
        "car_\(gameScene.carType.rawValue + 1)")
    }
  }
  
  private func updateLabels() {
    gameScene.laps.text = "Laps: \(numberOfLaps)"
    gameScene.time.text = "Time: \(timeInSeconds)"
  }
}
