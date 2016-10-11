//
//  Button.swift
//  ChampionsF1Game
//
//  Created by Leonardo Almeida silva ferreira on 16/09/16.
//  Copyright © 2016 kkwFwk. All rights reserved.
//

import UIKit

class Button: UIButton {

  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    super.didUpdateFocusInContext(context, withAnimationCoordinator: coordinator)
    
    if self == context.nextFocusedView {
      coordinator.addCoordinatedAnimations({self.transform = CGAffineTransformMakeScale(1.1, 1.1)}, completion: nil)
    } else if self == context.previouslyFocusedView {
      coordinator.addCoordinatedAnimations({self.transform = CGAffineTransformMakeScale(1, 1)}, completion: nil)
    }
  }
}
