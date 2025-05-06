//
//  GameModels.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-23.
//

import Foundation
import SwiftUI

enum Rotation: CaseIterable {
    case one
    case two
    case three
    case four
}

extension Rotation {
    func next() -> Rotation {
        let allCases = Rotation.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else {
            fatalError()
        }
        
        if currentIndex == allCases.endIndex {
            return allCases[allCases.startIndex]
        } else {
            return allCases[allCases.index(after: currentIndex)]
        }
    }
}

enum VirusColor: CaseIterable {
    case red
    case yellow
    case blue
    
    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .yellow: return .yellow
        }
    }
}

struct PillPiece: Hashable {
    let color: VirusColor
    
    init() {
        guard let addition = VirusColor.allCases.randomElement() else {
            fatalError()
        }
        color = addition
        
    }
}

struct Pill: Hashable {
    static func == (lhs: Pill, rhs: Pill) -> Bool {
        return lhs.piece1.color == rhs.piece1.color && lhs.piece2?.color == rhs.piece2?.color
    }
    
    let piece1: PillPiece
    let piece2: PillPiece?
    var rotation: Rotation
    
    var row: Int?
    var col: Int?
    
    var x: Int?
    var y: Int?
    
    init() {
        piece1 = PillPiece()
        piece2 = PillPiece()
        rotation = .one
        // these means it is falling
        row = nil
        col = nil
        // spawn point, would need to change this for multiple at a time
        // midpoint and top
        x = (xBaseline + (6 * xMultiplier))/2
        y = yBaseline
    }
}

struct Virus: Hashable {
    let color: VirusColor
    let row: Int
    let col: Int
}
