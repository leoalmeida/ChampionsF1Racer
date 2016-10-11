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

import UIKit
import SpriteKit

class GameViewController: UIViewController {

  var carType: CarType!
  var levelType: LevelType!
  
  var gameScene: GameScene!
  var analogControl: AnalogControl?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if let scene = GameScene(fileNamed:"GameScene") {
      
      gameScene = scene
      gameScene.gameSceneDelegate = self
      
      let skView = self.view as! SKView
      skView.showsFPS = true
      skView.showsNodeCount = true
      
      /* Sprite Kit applies additional optimizations to improve rendering performance */
      skView.ignoresSiblingOrder = true
      
      /* Set the scale mode to scale to fit the window */
      scene.scaleMode = .AspectFill
      scene.levelType = levelType
      scene.carType = carType
      
      skView.presentScene(scene)
      
      #if os(iOS)
        let analogControlSize: CGFloat = view.frame.size.height / 2.5
        let analogControlPadding: CGFloat = view.frame.size.height / 32
        
        analogControl = AnalogControl(frame: CGRectMake(analogControlPadding,
          skView.frame.size.height - analogControlPadding - analogControlSize,
          analogControlSize,
          analogControlSize))
        analogControl?.delegate = scene
        view.addSubview(analogControl!)
      #endif
    }
  }
}

extension GameViewController: GameSceneProtocol {
  func didSelectCancelButton(gameScene: GameScene) {
    navigationController?.popToRootViewControllerAnimated(false)
  }
  
  func didShowOverlay(gameScene: GameScene) {
    analogControl?.hidden = true
  }
  
  func didDismissOverlay(gameScene: GameScene) {
    analogControl?.hidden = false
  }
  
  #if os (tvOS)
  override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    gameScene.pressesBegan(presses, withEvent: event)
  }
  #endif
}