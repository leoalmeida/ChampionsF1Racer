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

class SceneOverlay {
  
  let backgroundNode: SKSpriteNode
  let contentNode: SKSpriteNode
  let nativeContentSize: CGSize
  
  init(overlaySceneFileName fileName: String, zPosition: CGFloat) {
    
    let overlayScene = SKScene(fileNamed: fileName)
    let contentTemplateNode = overlayScene?.childNodeWithName("Overlay") as! SKSpriteNode
    
    backgroundNode = SKSpriteNode(color: contentTemplateNode.color, size: contentTemplateNode.size)
    backgroundNode.zPosition = zPosition
    
    contentNode = contentTemplateNode.copy() as! SKSpriteNode
    contentNode.position = .zero
    backgroundNode.addChild(contentNode)
    
    contentNode.color = .clearColor()
    
    nativeContentSize = contentNode.size
  }
  
  func updateScale() {
    guard let viewSize = backgroundNode.scene?.view?.frame.size else {
      return
    }
    
    backgroundNode.size = viewSize
    
    let scale = viewSize.height/nativeContentSize.height
    contentNode.setScale(scale)
  }
}
