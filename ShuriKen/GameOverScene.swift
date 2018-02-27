//
//  GameOverScene.swift
//  SuriKen
//
//  Created by Willie Johnson on 2/22/18.
//  Copyright © 2018 Vybe. All rights reserved.
//

import UIKit
import SpriteKit

/// Shows the player the end result of the game.
class GameOverScene: SKScene {
  init(size: CGSize, won: Bool) {
    super.init(size: size)

    backgroundColor = .white
    // Determin which message to show to player.
    let message = won ? "You WON!" : "You LOSE! >:D"

    // Display message to player.
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = message
    label.fontSize = 40
    label.fontColor = .white
    backgroundColor = .black
    label.position = CGPoint(x: size.width  / 2, y: size.height / 2)
    addChild(label)

    // Transition scene with a horizontal flip.
    run(SKAction.sequence([
      SKAction.wait(forDuration: 3.0),
      SKAction.run() {
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition: reveal)
      }
    ]))
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
