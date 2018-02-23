//
//  QuickMaths.swift
//  SuriKen
//
//  Created by Willie Johnson on 2/23/18.
//  Copyright © 2018 Vybe. All rights reserved.
//

import Foundation
import SpriteKit

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

