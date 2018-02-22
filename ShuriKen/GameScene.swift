//
//  GameScene.swift
//  ShuriKen
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
  /// Keeps track of the number of monsters the player has destroyed.
  var monstersDestroyed = 0

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

    // Start background music.
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Play projectile sound.
    run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
      
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
  func didBegin(_ contact: SKPhysicsContact) {
    // Arrange bodies in category order.
    var firstBody = contact.bodyA
    var secondBody = contact.bodyB
    if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }

    // Check to see if the bodies belong to monsters and projectiles
    let firstBodyIsMonster = firstBody.categoryBitMask & PhysicsCategory.Monster != 0
    let secondBodyIsProjectile = secondBody.categoryBitMask & PhysicsCategory.Projectile != 0

    // Handle collision if bodies are monsters and projectiles.
    if firstBodyIsMonster && secondBodyIsProjectile {
      guard let monster = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? SKSpriteNode else { return }
      projectileDidCollideWithMonster(projectile: projectile, monster: monster)
    }
  }
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
    let loseAction = SKAction.run() {
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
    monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
  }

  /// Handle collision between monsters and projectiles.
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    projectile.removeFromParent()
    monster.removeFromParent()
    monstersDestroyed += 1
    if monstersDestroyed > 30 {
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: true)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }
  }
}
