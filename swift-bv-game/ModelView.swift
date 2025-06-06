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
    
    // TODO: ensure we don't get 3 in a row of the same color
    // would be nice to do so by randomly choosing which cell to
    //  generate next, and having the result show up incrementally
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
            var pill = pills[index]
            if pill.mainLocation != nil { return }
            
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
            
            let rotationOffset = pill.isHorizontal != nil ? ( pill.isHorizontal! ? 0 : baseSize ) : baseSize
            var setX = newX + rotationOffset/2
            
            if (setX < baseSize) {
                setX = baseSize
            }
            else if (setX > CGFloat(stageCols - 1) * baseSize + rotationOffset) {
                setX = CGFloat(stageCols - 1) * baseSize + rotationOffset
            }
            
            var setY = newY
            if setY < pill.y {
                setY = pill.y
            }
            
            // collision check
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
    
    private func pillHasSpace(loc: Location, isHorizontal: Bool?) -> Bool {
        let row = loc.row
        let col = loc.col
        
        if let horizontal = isHorizontal {
            if (!horizontal && row-1 < 0)
                || col < 0
                || horizontal && col+1 > 5 {
                return false
            }
            if stage[row][col] != nil
                || horizontal && stage[row][col+1] != nil
                || !horizontal && stage[row-1][col] != nil {
                return false
            }
            return true
        }
        
        return stage[row][col] == nil
    }
    
    private func rowPillOccupying(y: CGFloat) -> Int {
        // TODO: try adjusting overlap allowance with this?
        let yOffset = y - yBaseline
        for i in 0..<(stageRows-1) {
            if yOffset < (baseSize * CGFloat(i)) {
                return i
            }
        }
        return (stageRows-1)
    }
    
    private func colPillOccupying(x: CGFloat) -> Int {
        let xOffset = x - xBaseline
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
        let spaceAbove = Location(row-1, col)
        
        if let index = pills.firstIndex(where: { $0.id == id }) {
            var pill = pills[index]
            // TODO: actual game over condition is a pill in the way of the new pill
            // otherwise, getting into this state shouldn't be possible i think?
            if row == 0  || pill.isHorizontal != true && row == 1 {
                print("Game Over")
                self.stopGameLoop()
                return
            }
            if pillHasSpace(loc: spaceAbove, isHorizontal: pill.isHorizontal) {
                var loc1: Location
                var loc2: Location?
                
                switch pill.rotation {
                case .one:
                    loc1 = spaceAbove
                    loc2 = Location(row-1, col+1)
                case .two:
                    loc1 = Location(row-2, col)
                    loc2 = spaceAbove
                case .three:
                    loc1 = Location(row-1, col+1)
                    loc2 = spaceAbove
                case .four:
                    loc1 = spaceAbove
                    loc2 = Location(row-2, col)
                case .single:
                    loc1 = spaceAbove
                    loc2 = nil
                }
                stage[loc1.row][loc1.col] = pill.piece1
                pill.piece1Location = loc1
                if let loc = loc2 {
                    pill.piece2Location = loc
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
            currentWave.append(nextPill.id)
            pills.append(nextPill)
            let newPill = Pill()
            nextPill = newPill
            // TODO: check for game end here (if pill has space in starting spot)
        }
        pillLoop: for i in pills.indices {
            var pill = pills[i]
            if pill.mainLocation == nil {
                // TODO: try other values for falling speed
                pills[i].y += 1
                
                if pill.y >= (CGFloat(stageRows - 1) * baseSize + yBaseline) {
                    placePillAbove(id: pill.id, loc: Location(stageRows, colPillOccupying(x: pill.x)))
                    continue pillLoop
                }
                var colsOccupied: [Int] = []
                var rowsOccupied: [Int] = []
                let mainCol = colPillOccupying(x: pill.x)
                let mainRow = rowPillOccupying(y: pill.y)
                colsOccupied.append(mainCol)
                rowsOccupied.append(mainRow)
                if let horizontal = pill.isHorizontal {
                    horizontal ? colsOccupied.append(mainCol + 1) : rowsOccupied.append(mainRow - 1)
                }
                
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
                let rowBelow = pill.mainLocation!.row + 1
                // skip if at bottom row
                if rowBelow == stageRows {continue pillLoop}
                var willFall = false
                
                
                let locs: [Location?] = [pill.piece1Location, pill.piece2Location]
                
                // if the pill is horizontal, need to check if space below both is nil
                // otherwise, just check below mainLocation
                if (pill.isHorizontal ?? false) {
                    if stage[rowBelow][locs[0]!.col] == nil && stage[rowBelow][locs[1]!.col] == nil {
                        willFall = true
                    }
                } else if stage[rowBelow][pill.mainLocation!.col] == nil {
                    willFall = true
                }
                
                if willFall {
                    for l in locs {
                        if let l = l {
                            stage[l.row][l.col] = nil
                        }
                    }
                    
                    pill.piece1Location = nil
                    pill.piece2Location = nil
                    pills[i] = pill
                }
            }
        }
        
        for loc in toPop {
            let popped = stage[loc.row][loc.col]
            
            stage[loc.row][loc.col] = nil
            
            if popped is Virus {
                if let index = viruses.firstIndex(of: popped as! Virus) {
                    viruses.remove(at: index)
                }
            }
            if popped is PillPiece {
                if let index = pills.firstIndex(where: { $0.id == (popped as! PillPiece).parentPillID }) {
                    var pill = pills[index]
                    if pill.piece2 == nil {
                        pills.remove(at: index)
                        continue
                    } else if (popped as! PillPiece).id == pill.piece1.id {
                        pill.piece1 = pill.piece2!
                        pill.piece1Location = pill.piece2Location
                    }
                    pill.piece2 = nil
                    pill.piece2Location = nil
                    pill.rotation = .single
                    pill.x = baseSize * CGFloat(pill.mainLocation!.col + 1)
                    pill.y = baseSize * CGFloat(pill.mainLocation!.row) + yBaseline
                    pills[index] = pill
                }
            }
        }
        toPop.removeAll()
    }
}
