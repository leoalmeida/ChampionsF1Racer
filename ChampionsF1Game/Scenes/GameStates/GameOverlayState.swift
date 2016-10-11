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

class GameOverlayState: GKState {
  
  unowned let gameScene: GameScene
  
  var overlay: SceneOverlay!
  var overlaySceneFileName: String { fatalError("Unimplemented overlaySceneName") }
  
  init(gameScene: GameScene) {
    self.gameScene = gameScene
    super.init()
    
    overlay = SceneOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 2)
    
    ButtonNode.parseButtonInNode(overlay.contentNode)
  }
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(previousState)
    gameScene.paused = true
    gameScene.overlay = overlay
  }
  
  override func willExitWithNextState(nextState: GKState) {
    super.willExitWithNextState(nextState)
    gameScene.paused = false
    gameScene.overlay = nil
  }
}
