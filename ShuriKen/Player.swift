//
//  Player.swift
//  SuriKen
//
//  Created by Willie Johnson on 2/25/18.
//  Copyright © 2018 Vybe. All rights reserved.
//

import UIKit
import SpriteKit

class Player: SKSpriteNode {
  /// Health of the player.
  var health = 30
  /// The speed at which the player moves around the game world.
  var moveSpeed: CGFloat = 1.0

  /// Create a SKSpriteNode with the "player" image and place it at given CGPoint.
  /// - Parameter imageNamed: The name of the image in the bundle.
  init(_ imageNamed: String) {
    let texture = SKTexture(imageNamed: imageNamed)
    super.init(texture: texture, color: .white, size: texture.size())
    self.name = "player"
    // Setup player physicsBody.
    physicsBody = SKPhysicsBody(rectangleOf: size)
    guard let playerPhysicsBody = physicsBody else { return }
    playerPhysicsBody.isDynamic = true
    playerPhysicsBody.categoryBitMask = PhysicsCategory.Player
    playerPhysicsBody.collisionBitMask = PhysicsCategory.Monster
    playerPhysicsBody.contactTestBitMask = PhysicsCategory.Monster
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func damage(_ damage: Int, response: (Bool) -> Void) {
    health -= damage
    if health <= 0 {
      removeFromParent()
      response(true)
    }

    response(false)
  }
}
