//
//  GameModels.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-23.
//

import Foundation
import SwiftUI

enum Rotation: CaseIterable {
    case one, two, three, four
}

extension Rotation {
    func next() -> Rotation {
        switch self {
        case .one: return .two
        case .two: return .three
        case .three: return .four
        case .four: return .one
//        case .single: return .single
        }
        /// not sure why this doesn't work? is this way just better anyways?
        //        let allCases = Rotation.allCases
        //        guard let currentIndex = allCases.firstIndex(of: self) else {
        //            fatalError()
        //        }
        //
        //        if currentIndex == allCases.endIndex {
        //            return allCases[allCases.startIndex]
        //        } else {
        //            return allCases[allCases.index(after: currentIndex)]
        //        }
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

struct Location: Hashable {
    var row: Int
    var col: Int
    
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    init(tup: (Int, Int)) {
        self.row = tup.0
        self.col = tup.1
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

struct Pill: Identifiable {
    static func == (lhs: Pill, rhs: Pill) -> Bool {
        return lhs.piece1.color == rhs.piece1.color && lhs.piece2?.color == rhs.piece2?.color
    }
    
    let id: UUID
    
    let piece1: PillPiece
    var piece2: PillPiece?
    var rotation: Rotation
    var isHorizontal: Bool {
        return rotation == .one || rotation == .three
    }
    
    var location: Location?
    
    var x: CGFloat
    var y: CGFloat
    
    init() {
        id = UUID()
        piece1 = PillPiece()
        piece2 = PillPiece()
        rotation = .one
        // these being nil means it is falling
        location = nil
        // spawn point
        x = CGFloat(stageCols) * baseSize / 2
        y = CGFloat(yBaseline)
    }
}

struct Virus: Hashable {
    let color: VirusColor
    let location: Location
}
