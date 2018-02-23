//
//  Monster.swift
//  SuriKen
//
//  Created by Willie Johnson on 2/23/18.
//  Copyright © 2018 Vybe. All rights reserved.
//

import Foundation
import SpriteKit

/// A SKSpriteNode that represents the monsters that the player have to
class Monster: SKSpriteNode {
  /// Health of the monster.
  var health = 100
  /// The speed at which the monster moves around the game world.
  var moveSpeed: CGFloat = 1.0

  /// Create a SKSpriteNode with the "monster" image and place it at given CGPoint.
  /// - Parameter spawn: The position of where the monster will be added to the game world.
  init(spawn: CGPoint) {
    let texture = SKTexture(imageNamed: "monster")
    super.init(texture: texture, color: .white, size: texture.size())
    self.name = "monster"
    // Setup monster physicsBody.
    physicsBody = SKPhysicsBody(rectangleOf: size)
    guard let monsterPhysicsBody = physicsBody else { return }
    monsterPhysicsBody.isDynamic = true
    monsterPhysicsBody.categoryBitMask = PhysicsCategory.Monster
    monsterPhysicsBody.collisionBitMask = PhysicsCategory.None
    monsterPhysicsBody.contactTestBitMask = PhysicsCategory.Projectile

    self.position = spawn
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(_ scene: GameScene) {
    let player = scene.player
    // Calculate angle between monster and player.
    let dx = player.position.x - position.x
    let dy = player.position.y - position.y
    let angle = atan2(dy, dx)

    // Calculate velocity.
    let vx = cos(angle) * moveSpeed
    let vy = sin(angle) * moveSpeed

    position.x += vx
    position.y += vy
  }

  func damage(_ damage: Int, response: (Bool) -> Void) {
    health -= 1
    if health <= 0 {
      removeFromParent()
      response(true)
    }

    response(false)
  }
}
