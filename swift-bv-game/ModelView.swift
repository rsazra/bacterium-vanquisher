//
//  ModelView.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-30.
//

class Game {
    var stage: [[StageSpace?]] = Array(repeating: Array(repeating: nil, count: stageCols), count: stageRows)
    let fallingPills: [Pill] = []
    var nextPill: Pill
    
    init() {
        nextPill = Pill()
        seed()
    }
    
    func seed() {
        for (col, column) in stage.enumerated() {
            for (row, _) in column.enumerated() {
                if col < 3 { continue }
                let options = [nil, VirusColor.red, VirusColor.yellow, VirusColor.blue]
                
                if let addition = options.randomElement() {
                    if addition != nil {
                        stage[col][row] = Virus(color: addition!)
                    }
                }
            }
        }
    }

}
