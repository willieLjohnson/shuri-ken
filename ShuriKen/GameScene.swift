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
  /// On screen control to move player.
  let movePlayerStick = AnalogJoystick(diameters: (100, 50))
  /// On screen control to control throwing weapons.
  let weaponStick = AnalogJoystick(diameters: (100, 50))
  /// Current monsters that are alive in the game world.
  var monsters = [Monster]()

  override func didMove(to view: SKView) {
    setupScene()
    setupOnScreenControls()
    setupPlayer()
    startScene()
  }

  override func update(_ currentTime: TimeInterval) {
    // Make sure that the scene has already loaded.
    guard scene != nil else { return }
    updateMonsters()
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
      guard let monster = firstBody.node as? Monster, let projectile = secondBody.node as? SKSpriteNode else { return }
      projectileDidCollideWithMonster(projectile: projectile, monster: monster)
    }
  }
}

// MARK: Helper functions.
private extension GameScene {
  // MARK: Setup

  /// Setup the game world.
  func setupScene() {
    // Setup game scene.
    backgroundColor = .white
    // Setup physics world.
    physicsWorld.gravity = CGVector.zero
    physicsWorld.contactDelegate = self
  }

  /// Create and place the on screen controls.
  func setupOnScreenControls() {
    // Setup joystick to control player movement.
    movePlayerStick.position = CGPoint(x: movePlayerStick.radius + 50, y: movePlayerStick.radius + 50)
    movePlayerStick.stick.color = .red
    movePlayerStick.trackingHandler = { [unowned self] data in
      let player = self.player
      player.position = CGPoint(x: player.position.x + (data.velocity.x * 0.12),
                                y: player.position.y + (data.velocity.y * 0.12))
    }
    addChild(movePlayerStick)

    // Setup joystick to control player weapon use.
    weaponStick.position = CGPoint(x: size.width - weaponStick.radius - 25, y: weaponStick.radius + 25)
    weaponStick.stick.color = .red
    weaponStick.trackingHandler = { [unowned self] data in
      // Play projectile sound.
      self.run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: true))

      // Get shooting direction.
      var direction = data.velocity.normalized()
      // Change direction to point straight up if the analog stick is in the center.
      if direction.x.isNaN || direction.y.isNaN {
        direction.x = 1.0
        direction.y = 0.0
      }

      // Create projectile.
      let projectile = SKSpriteNode(imageNamed: "projectile")
      projectile.position = self.player.position

      // Setup projectile physics body.
      projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
      guard let projectilePhysicsBody = projectile.physicsBody else { return }
      projectilePhysicsBody.isDynamic = true
      projectilePhysicsBody.categoryBitMask = PhysicsCategory.Projectile
      projectilePhysicsBody.collisionBitMask = PhysicsCategory.None
      projectilePhysicsBody.contactTestBitMask = PhysicsCategory.Monster
      projectilePhysicsBody.usesPreciseCollisionDetection = true

      self.addChild(projectile)

      // The end point for the projectile.
      let destination = direction * 1000 + projectile.position

      // Shoot out projectile.
      let actionMove = SKAction.move(to: destination, duration: 2.0)
      let actionMoveDone = SKAction.removeFromParent()

      projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    addChild(weaponStick)
  }

  /// Create and place the player in the game world.
  func setupPlayer() {
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    addChild(player)
  }

  /// Kick of the gameplay.
  func startScene() {
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

  // MARK: Gameplay logic

  /// Update every monster in the scene every frame.
  func updateMonsters() {
    // Make monsters chase
    for monster in monsters {
      monster.update(self)
    }
  }

  /// Spawn a monster at a random location along the y axis.
  func addMonster() {
    let monster: Monster = Monster(spawn: CGPoint(x: random(min: 0, max: size.width), y: random(min: 0, max: size.height)))
    // Add monster to the scene.
    addChild(monster)
    monsters.append(monster)
  }

  // MARK: Physics

  /// Handle collision between monsters and projectiles.
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: Monster) {
    projectile.removeFromParent()
    monster.damage(10) { isDead in
      if isDead {
        monstersDestroyed += 1
        if monstersDestroyed > 30 {
          let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
          let gameOverScene = GameOverScene(size: self.size, won: true)
          self.view?.presentScene(gameOverScene, transition: reveal)
        }
      }
    }
  }
}
