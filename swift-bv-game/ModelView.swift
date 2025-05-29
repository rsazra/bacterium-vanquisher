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
    private var currentWave: [UUID] = []
    @Published var nextPill: Pill
    @Published var pills: [Pill] = []
    @Published var viruses: [Virus] = []
    
    
    init() {
        let mainPill = Pill()
        
        nextPill = Pill()
        pills.append(mainPill)
        currentWave.append(mainPill.id)
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
    
    func startGameLoop() {
        // TODO: try other values for tick time
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
    
    func rotatePill(id: UUID) {
        if let index = pills.firstIndex(where: { $0.id == id }) {
            // do not rotate placed pills!
            if pills[index].row != nil { return }
            
            // TODO: generalize this
            /// if there is no space to rotate, check if we can rotate + move one space to the side.
            pills[index].rotation = pills[index].rotation.next()
            pills[index].x > 250 ? pills[index].x = 250 : nil
        }
    }
    
    func movePill(id: UUID, newX: CGFloat, newY: CGFloat) {
        if let index = pills.firstIndex(where: { $0.id == id }) {
            var pill = pills[index]
            // x
            let rotationOffset = pills[index].isHorizontal ? 0 : baseSize
            var setX = newX + rotationOffset/2
            
            /// keep within grid bounds
            if (setX < baseSize) {
                setX = baseSize
            }
            else if (setX > CGFloat(stageCols - 1) * baseSize + rotationOffset) {
                setX = CGFloat(stageCols - 1) * baseSize + rotationOffset
            }
            
            // y
            // TODO: dont go past the bottom of the stage
            var setY = newY
            if setY < pill.y {
                setY = pill.y
            }
            
            // collision
            let newCol = colPillOccupying(x: setX)
            let newRow = rowPillOccupying(y: setY)
            if pillHasSpace(row: newRow, col: newCol, isHorizontal: pill.isHorizontal) {
                pill.x = setX
                pill.y = setY
                pills[index] = pill
            }
            
        }
    }
    
    func snapPillToCol(id: UUID) {
        if let index = pills.firstIndex(where: { $0.id == id }) {
            let setX = baseSize * CGFloat(colPillOccupying(x: pills[index].x) + 1)
            pills[index].x = setX
        }
    }
    
    private func pillHasSpace(row: Int, col: Int, isHorizontal: Bool) -> Bool {
        if !isHorizontal && row-1 < 0 {
            return false
        }
        if stage[row][col] != nil
            || isHorizontal && stage[row][col+1] != nil
            || !isHorizontal && stage[row-1][col] != nil {
            return false
        }
        return true
    }
    
    private func rowPillOccupying(y: CGFloat) -> Int {
        let yOffset = y - yBaseline // adjust overlap allowance with this?
        for i in 0...9 {
            if yOffset < (baseSize * CGFloat(i)) {
                return i
            }
        }
        return 10
    }
    
    private func colPillOccupying(x: CGFloat) -> Int {
        /// different strategy from above. which is better?
        switch x {
        case ..<(baseSize + xBaseline):
            return 0
        case ..<(2 * baseSize + xBaseline):
            return 1
        case ..<(3 * baseSize + xBaseline):
            return 2
        case ..<(4 * baseSize + xBaseline):
            return 3
        case ..<(5 * baseSize + xBaseline):
            return 4
        default:
            return 5
        }
    }

    private func placePillAbove(id: UUID, row: Int, col: Int) {
        if let index = pills.firstIndex(where: { $0.id == id }) {
            let pill = pills[index]
            // TODO: in theory, having a pill sticking up past the "first" row should be possible?
            /// also, can maybe make this part of pillHasSpace? make it optional return,
            /// and return nil if the issue is the top of the stage.
            if row == 0  || !pill.isHorizontal && row == 1 {
                print("Game Over")
                self.stopGameLoop()
                return
            }
            if pillHasSpace(row: row-1, col: col, isHorizontal: pill.isHorizontal) {
                pills[index].row = row
                pills[index].col = col
                switch pill.rotation {
                case .one:
                    stage[row-1][col] = pill.piece1.color
                    stage[row-1][col+1] = pill.piece2?.color
                case .two:
                    stage[row-2][col] = pill.piece1.color
                    stage[row-1][col] = pill.piece2?.color
                case .three:
                    stage[row-1][col+1] = pill.piece1.color
                    stage[row-1][col] = pill.piece2?.color
                case .four:
                    stage[row-1][col] = pill.piece1.color
                    stage[row-2][col] = pill.piece2?.color
                }
                if let i = currentWave.firstIndex(of: id) {
                    currentWave.remove(at: i)
                }
            }
            else {
                placePillAbove(id: id, row: row-1 , col: col)
            }
        }
    }
    
    private func gameTick() {
        if currentWave.isEmpty {
            let newPill = Pill()
            currentWave.append(newPill.id)
            pills.append(newPill)
        }
        for i in pills.indices {
            let pill = pills[i]
            if pill.row == nil {
                // TODO: try other values for falling speed
                pills[i].y += 0.5
                var colsOccupied: [Int] = []
                var rowsOccupied: [Int] = []
                let mainCol = colPillOccupying(x: pill.x)
                let mainRow = rowPillOccupying(y: pill.y)
                colsOccupied.append(mainCol)
                rowsOccupied.append(mainRow)
                pill.isHorizontal ? colsOccupied.append(mainCol + 1) : rowsOccupied.append(mainRow - 1)
                
                rowLoop: for row in rowsOccupied {
                    for col in colsOccupied {
                        /// index out of range error here when passing row 6 i think
                        if stage[row][col] != nil {
                            placePillAbove(id: pill.id, row: mainRow, col: mainCol)
                            break rowLoop
                        }
                    }
                }
            }
            
            // tmp
            if pill.y > 525 { stopGameLoop() }
        }
    }
}
