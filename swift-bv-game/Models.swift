//
//  GameModels.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-23.
//

import Foundation
import SwiftUI

enum Rotation: CaseIterable {
    case one, two, three, four, single
}

extension Rotation {
    func next() -> Rotation {
        switch self {
        case .one: return .two
        case .two: return .three
        case .three: return .four
        case .four: return .one
        case .single: return .single
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

struct PillPiece: HasColor, Hashable {
    let color: VirusColor
    let id: UUID
    let parentPillID: UUID
    
    init(id: UUID) {
        self.id = UUID()
        guard let addition = VirusColor.allCases.randomElement() else {
            fatalError()
        }
        color = addition
        parentPillID = id
    }
}

struct Pill: Identifiable {
    static func == (lhs: Pill, rhs: Pill) -> Bool {
        return lhs.piece1.color == rhs.piece1.color && lhs.piece2?.color == rhs.piece2?.color
    }
    
    let id: UUID
    
    var piece1: PillPiece
    var piece2: PillPiece?
    var rotation: Rotation
    var isHorizontal: Bool? {
        if rotation == .single { return nil }
        return rotation == .one || rotation == .three
    }
    
    var mainLocation: Location? {
        guard let piece1Location = piece1Location else { return nil }
        guard let piece2Location = piece2Location else { return nil }
//        if rotation == .single { return nil }
        let row = max(piece1Location.row, piece2Location.row)
        let col = min(piece1Location.col, piece2Location.col)
        return Location(row, col)
    }
    var piece1Location: Location?
    // where piece2 is
    var piece2Location: Location?
    
    var x: CGFloat
    var y: CGFloat
    
    init() {
        id = UUID()
        piece1 = PillPiece(id: id)
        piece2 = PillPiece(id: id)
        rotation = .one
            // tmp
//        rotation = .single
        // these being nil means it is falling
        piece1Location = nil
        piece2Location = nil
        // spawn point
        x = CGFloat(stageCols) * baseSize / 2
        y = CGFloat(yBaseline)
    }
}

struct Virus: HasColor, Hashable {
    let color: VirusColor
    let location: Location
}

protocol HasColor {
    var color: VirusColor { get }
}
