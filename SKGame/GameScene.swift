//
//  GameScene.swift
//  SKGame
//
//  Created by Willie Johnson on 2/21/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import UIKit
import SpriteKit

/// Physics categories.
struct PhysicsCategory {
  static let None: UInt32 = 0
  static let All: UInt32 = UInt32.max
  static let Monster: UInt32 = 0b1 // 1
  static let Projectile: UInt32 = 0b10 // 2
}

/// Main scene of the game.
class GameScene: SKScene {
  /// The player node that will respond to user input.
  let player = SKSpriteNode(imageNamed: "player")

  override func didMove(to view: SKView) {
    // Setup game scene.
    backgroundColor = .white

    // Setup player.
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    addChild(player)

    // Setup physics world.
    physicsWorld.gravity = CGVector.zero
    physicsWorld.contactDelegate = self

    // Start spawning monsters.
    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addMonster),
        SKAction.wait(forDuration: 1.0)
        ])
    ))
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Grab a touch to handle.
    guard let touch = touches.first else { return }
    let touchLocation = touch.location(in: self)

    // Create projectile.
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position

    // Setup projectile physics body.
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
    guard let projectilePhysicsBody = projectile.physicsBody else { return }
    projectilePhysicsBody.isDynamic = true
    projectilePhysicsBody.categoryBitMask = PhysicsCategory.Projectile
    projectilePhysicsBody.collisionBitMask = PhysicsCategory.None
    projectilePhysicsBody.contactTestBitMask = PhysicsCategory.Monster
    projectilePhysicsBody.usesPreciseCollisionDetection = true

    // Get the offset betweent the tap location and the projectile's location.
    let offset = touchLocation - projectile.position

    // Prevent player from shooting backwards.
    if offset.x < 0 { return }

    addChild(projectile)

    // Get shooting direction.
    let direction = offset.normalized()

    // The end point for the projectile.
    let destination = direction * 1000 + projectile.position

    // Shoot out projectile.
    let actionMove = SKAction.move(to: destination, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
}

// MARK: SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {

}

// MARK: Helper functions.
private extension GameScene {
  /// Returns a randomly generate float that ranges from 0 to 1.
  /// - Returns: A random CGFloat.
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }

  /// Returns a randomly generate float that ranges from a min to max value.
  /// - Parameters:
  ///   - min: The lowest number that will be randomly generated.
  ///   - max: The highest number that will be randomly generated.
  /// - Returns: A random CGFloat between min and max.
  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }

  /// Spawn a monster at a random location along the y axis.
  func addMonster() {
    // Create monster node.
    let monster = SKSpriteNode(imageNamed: "monster")

    // Setup monster physicsBody.
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
    guard let monsterPhysicsBody = monster.physicsBody else { return }
    monsterPhysicsBody.isDynamic = true
    monsterPhysicsBody.categoryBitMask = PhysicsCategory.Monster
    monsterPhysicsBody.collisionBitMask = PhysicsCategory.None
    monsterPhysicsBody.contactTestBitMask = PhysicsCategory.Projectile

    // Set starting position
    let spawnY = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2)
    let spawnX = size.width + monster.size.width / 2
    monster.position = CGPoint(x: spawnX, y: spawnY)

    // Add monster to the scene.
    addChild(monster)

    // Generate a random move speed.
    let moveSpeed = random(min: CGFloat(2.0), max: CGFloat(4.0))

    // Move the monster towards the other end of the screen and despawn.
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width / 2, y: spawnY), duration: TimeInterval(moveSpeed))
    let actionMoveDone = SKAction.removeFromParent()
    monster.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
}
