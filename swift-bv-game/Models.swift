//
//  GameModels.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-23.
//

import Foundation
import SwiftUI

enum Position: CaseIterable {
    case one
    case two
    case three
    case four
}

extension Position {
    func next() -> Position {
        let allCases = Position.allCases
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

struct PillPiece: StageSpace {
    let color: VirusColor
    
    init() {
        guard let addition = VirusColor.allCases.randomElement() else {
            fatalError()
        }
        color = addition
        
    }
}

struct Pill {
    let piece1: PillPiece
    let piece2: PillPiece?
    @State var position: Position
    
    init() {
        piece1 = PillPiece()
        piece2 = PillPiece()
        position = .one
    }
    
    func rotate() {
        if position == .four {
           position = .one
        }
        else {
            position = position.next()
        }
    }
}

struct Virus: StageSpace {
    let color: VirusColor
}

protocol StageSpace {
    var color: VirusColor { get }
}
