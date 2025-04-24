//
//  GameModels.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-23.
//

import Foundation

enum PillColor {
    case red
    case yellow
    case blue
}

enum PillStatus {
    case falling
    case settled
}

struct Pill {
    let piece1: PillColor
    let piece2: PillColor
    let status: PillStatus
}
