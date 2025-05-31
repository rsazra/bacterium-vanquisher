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
    
    private var stage: [[HasColor?]] = Array(repeating: Array(repeating: nil, count: stageCols), count: stageRows)
    private var currentWave: [UUID] = []
    private var toPop: Set<Location> = []
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
                if rowIndex < 5 { continue }
                let options = [nil, VirusColor.red, VirusColor.yellow, VirusColor.blue]
                
                if let addition = options.randomElement() {
                    if addition != nil {
                        let v = Virus(color: addition!, location: Location(rowIndex, colIndex))
                        viruses.append(v)
                        stage[rowIndex][colIndex] = v
                    }
                }
            }
        }
    }
    
    private func checkAround(loc: Location) {
        let row = loc.row
        let col = loc.col
        let color = stage[row][col]?.color
        if color == nil { return }
        
//        var toPop: Set<Location> = []
        
        // vertical
        for i in 0..<4 {
            if (row + i - 3) >= 0, (row + i) < stageRows {
                if stage[row + i][col]?.color == color,
                   stage[row + i - 1][col]?.color == color,
                   stage[row + i - 2][col]?.color == color,
                   stage[row + i - 3][col]?.color == color
                {
                    for j in 0..<4 {
                        toPop.insert(Location(row + i - j, col))
                    }
                }
            }
        }
        
        // horizontal
        for i in 0..<4 {
            if (col + i - 3) >= 0, (col + i) < stageCols {
                if stage[row][col + i]?.color == color,
                   stage[row][col + i - 1]?.color == color,
                   stage[row][col + i - 2]?.color == color,
                   stage[row][col + i - 3]?.color == color
                {
                    for j in 0..<4 {
                        toPop.insert(Location(row, col + i - j))
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
            var pill = pills[index]
            if pill.location != nil { return }
            
            pill.rotation = pill.rotation.next()
            let curRow = rowPillOccupying(y: pill.y)
            let curCol = colPillOccupying(x: pill.x)
            if pillHasSpace(loc: Location(curRow, curCol), isHorizontal: pill.isHorizontal) {
                pills[index] = pill
            }
            else if pillHasSpace(loc: Location(curRow, curCol - 1), isHorizontal: pill.isHorizontal) {
                pill.x -= baseSize
                pills[index] = pill
            }
            snapPillToCol(id: id)
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
            if pillHasSpace(loc: Location(newRow, newCol), isHorizontal: pill.isHorizontal) {
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
    
    private func pillHasSpace(loc: Location, isHorizontal: Bool) -> Bool {
        let row = loc.row
        let col = loc.col
        
        if (!isHorizontal && row-1 < 0)
            || col < 0
            || isHorizontal && col+1 > 5 {
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
        // TODO: need to double check functionality of this
        let yOffset = y - yBaseline // adjust overlap allowance with this?
        for i in 0..<(stageRows-1) {
            if yOffset < (baseSize * CGFloat(i)) {
                return i
            }
        }
        return (stageRows-1)
    }
    
    private func colPillOccupying(x: CGFloat) -> Int {
        let xOffset = x - xBaseline // adjust overlap allowance with this?
        for i in 0..<(stageCols-1) {
            if xOffset < (baseSize * CGFloat(i + 1)) {
                return i
            }
        }
        return (stageCols-1)
    }

    private func placePillAbove(id: UUID, loc: Location) {
        let row = loc.row
        let col = loc.col
        print("placing", row, col)
        
        if let index = pills.firstIndex(where: { $0.id == id }) {
            var pill = pills[index]
            // TODO: in theory, having a pill sticking up past the "first" row should be possible?
            /// also, can maybe make this part of pillHasSpace? make it optional return,
            /// and return nil if the issue is the top of the stage.
            if row == 0  || !pill.isHorizontal && row == 1 {
                print("Game Over")
                self.stopGameLoop()
                return
            }
            if pillHasSpace(loc: Location(row-1, col), isHorizontal: pill.isHorizontal) {
                var loc1: Location
                var loc2: Location?
                
                switch pill.rotation {
                case .one:
                    loc1 = Location(row-1, col)
                    loc2 = Location(row-1, col+1)
                case .two:
                    loc1 = Location(row-2, col)
                    loc2 = Location(row-1, col)
                case .three:
                    loc1 = Location(row-1, col+1)
                    loc2 = Location(row-1, col)
                case .four:
                    loc1 = Location(row-1, col)
                    loc2 = Location(row-2, col)
                }
                pill.location = loc1
                stage[loc1.row][loc1.col] = pill.piece1
                if let loc = loc2 {
                    pill.secondaryLocation = loc2
                    stage[loc.row][loc.col] = pill.piece2
                    checkAround(loc: loc)
                }
                checkAround(loc: loc1)
                
                pills[index] = pill
                if let i = currentWave.firstIndex(of: id) {
                    currentWave.remove(at: i)
                }
            } else {
                placePillAbove(id: id, loc: Location(row-1, col))
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
            if pill.location == nil {
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
                        if stage[row][col] != nil {
                            placePillAbove(id: pill.id, loc: Location(mainRow, mainCol))
                            break rowLoop
                        }
                    }
                }
            } else {
                // implies pill.location != nil
                // check if space below is empty. if so, start falling again.
            }
            
            /// make unsupported pills start falling again or should this just be
            /// part of gameTick? might be easier, but cause superfluous checks?
            // TODO: try both
            
            // tmp
            if pill.y > 525 { stopGameLoop() }
        }
        
//        print(toPop)
        for loc in toPop {
            let popped = stage[loc.row][loc.col]
            // remove viruses from virus list
            if popped is Virus {
                if let index = viruses.firstIndex(of: popped as! Virus) {
                    viruses.remove(at: index)
                }
            }
            // pop individual pill pieces (!)
            // if pill empty, remove from pill list
            if popped is PillPiece {
                if let index = pills.firstIndex(where: { $0.id == (popped as! PillPiece).parentPillID }) {
                    var pill = pills[index]
                    if pill.piece2 == nil {
                        // just remove from pill list
                        pills.remove(at: index)
                        continue
                    } else if loc == pill.location {
                        // that means this is piece1
                        pill.piece1 = pill.piece2!
                        pill.piece2 = nil
                        pill.location = pill.secondaryLocation!
                        pill.secondaryLocation = nil
                    } else {
                        // this means it is piece2
                        pill.piece2 = nil
                        pill.secondaryLocation = nil
                    }
                    pills[index] = pill
                }
            }
            stage[loc.row][loc.col] = nil
        }
        
    }
}
