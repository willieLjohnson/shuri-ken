//
//  GameScene.swift
//  SKGame
//
//  Created by Willie Johnson on 2/21/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene {
  let player = SKSpriteNode(imageNamed: "player")

  override func didMove(to view: SKView) {
    backgroundColor = .white
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    addChild(player)
  }
}
