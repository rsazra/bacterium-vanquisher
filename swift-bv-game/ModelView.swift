//
//  ModelView.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-30.
//

import Combine
import Foundation

class Game: ObservableObject {
    private var timer: AnyCancellable?
    
    private var stage: [[VirusColor?]] = Array(repeating: Array(repeating: nil, count: stageCols), count: stageRows)
    @Published var viruses: [Virus] = []
    @Published var nextPill: Pill
    @Published var pills: [Pill] = []
    
    init() {
        nextPill = Pill()
        pills.append(Pill())
        seed()
    }
    
    // TODO: need to ensure we don't get 3 in a row of the same color
    // would be nice to do so by randomly choosing which cell to
    //  generate next, and having the result show up incrementally
    //  like in the real game.
    private func seed() {
        for (rowIndex, rowContents) in stage.enumerated() {
            for (colIndex, _) in rowContents.enumerated() {
                if rowIndex < 3 { continue }
                let options = [nil, VirusColor.red, VirusColor.yellow, VirusColor.blue]
                
                if let addition = options.randomElement() {
                    if addition != nil {
                        let v = Virus(color: addition!, row: rowIndex, col: colIndex)
                        viruses.append(v)
                        stage[rowIndex][colIndex] = v.color
                    }
                }
            }
        }
    }
    
    func rotatePill(id: UUID) {
        if let index = pills.firstIndex(where: { $0.id == id }) {
            pills[index].rotation = pills[index].rotation.next()
            pills[index].x > 250 ? pills[index].x = 250 : nil
            /// the above line should be even more general -- if there is no space to rotate,
            /// should check if we can rotate + move one space to the side. TODO
        }
    }
    
    func movePill(id: UUID, newX: CGFloat, newY: CGFloat) {
        // this if let is not dry...
        if let index = pills.firstIndex(where: { $0.id == id }) {
            let rotationOffset = (pills[index].rotation == .one) || (pills[index].rotation == .three) ? 0 : baseSize
            var setX = newX + rotationOffset/2
            if (setX < baseSize) {
                setX = baseSize
            }
            else if (setX > CGFloat(stageCols - 1) * baseSize + rotationOffset) {
                setX = CGFloat(stageCols - 1) * baseSize + rotationOffset
            }
            pills[index].x = setX
            if pills[index].y <= newY {
                pills[index].y = newY
            }
            print(setX)
        }
    }
    
    func snapPillToGrid(id: UUID) {
        if let index = pills.firstIndex(where: { $0.id == id }) {
            var setX = pills[index].x
            switch setX {
            case ..<(baseSize + baseSize/2):
                setX = baseSize
            case (baseSize + baseSize/2)..<(2 * baseSize + baseSize/2):
                setX = baseSize * 2
            case (2 * baseSize + baseSize/2)..<(3 * baseSize + baseSize/2):
                setX = baseSize * 3
            case (3 * baseSize + baseSize/2)..<(4 * baseSize + baseSize/2):
                setX = baseSize * 4
            case (4 * baseSize + baseSize/2)..<(5 * baseSize + baseSize/2):
                setX = baseSize * 5
            case (5 * baseSize + baseSize/2)..<(6 * baseSize + baseSize/2):
                setX = baseSize * 6
            default:
                break
            }
            pills[index].x = setX
        }
    }
    
    func startGameLoop() {
        // try other values for tick time
        // how does this actually work though?
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.gameTick()
            }
    }
    
    func stopGameLoop() {
        timer?.cancel()
        timer = nil
    }
    
    private func gameTick() {
        for i in pills.indices {
            if pills[i].row == nil {
                pills[i].y += 1 // try other values
            }
        }
        
        // Add collision/landing logic here
    }
}
