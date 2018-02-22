//
//  GameViewController.swift
//  SKGame
//
//  Created by Willie Johnson on 2/21/18.
//  Copyright © 2018 Willie Johnson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.presentScene(scene)
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}
