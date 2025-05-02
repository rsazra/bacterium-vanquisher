//
//  ContentView.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-23.
//

import SwiftUI

struct GameView: View {
    let game: Game = .init()
    
    var body: some View {
        Spacer()
        PillView(color1: .red, color2: .yellow, position: .one)
        PillView(color1: .blue, position: .one)
        StageView(stage: game.stage)
            .padding(20)
            .border(.black)
//        ZStack {
//            GridView().frame(width: 300, height: 300)
//            VStack {
//                PillView(color1: .red, color2: .yellow, position: .one)
//                PillView(color1: .red, color2: .yellow, position: .two)
//                PillView(color1: .red, color2: .yellow, position: .three)
//                PillView(color1: .red, color2: .yellow, position: .four)
//                    .border(.black)
//                PillView(color1: .red, position: .four)
//                VirusView(color: .blue)
//            }
//            .padding()
//        }
    }
}

struct StageView: View {
    let stage: [[StageSpace?]]
    
    var body: some View {
        VStack(spacing: gridSpacing) {
            ForEach(stage.indices, id: \.self) { column in
                HStack(spacing: gridSpacing) {
                    ForEach(stage[column].indices, id: \.self) { row in
                        let co = stage[column][row]
                        let color: Color = (co != nil) ? co!.color.color : .clear
                        VirusView(color: color)
                    }
                }
            }
        }
    }
}

struct GridView: View {
    var body: some View {
        Rectangle()
            .stroke(.black)
    }
}

struct PillView: View {
    let color1: Color
    var color2: Color?
    let position: Position
    let size: CGFloat = pillSize
    var rotation: (Angle, UnitPoint) {
        switch position {
        case .one:
            (.degrees(0), .center)
        case .two:
            (.degrees(90), .top)
        case .three:
            (.degrees(180), .center)
        case .four:
            (.degrees(270), .top)
        }
    }
    var transform: CGAffineTransform {
        switch position {
        case .one:
            CGAffineTransform()
        case .two:
            CGAffineTransform(rotationAngle: 0)
                .rotated(by: 90 * (.pi / 180))
                .translatedBy(x: -45, y: -45)
        case .three:
            CGAffineTransform(rotationAngle: 0)
                .rotated(by: 180 * (.pi / 180))
                .translatedBy(x: -90, y: -45)
        case .four:
            CGAffineTransform(rotationAngle: 0)
                .rotated(by: 270 * (.pi / 180))
                .translatedBy(x: -45, y: 0)
        }
    }
    
    var body: some View {
        if color2 == nil {
            Capsule()
                .frame(width: size, height: size)
                .foregroundColor(color1)
        }
        else {
            ZStack {
                Capsule()
                    .frame(width: size*2, height: size)
                    .foregroundColor(color1)
                    .offset(x: CGFloat(size))
                    .clipped()
                    .offset(x: CGFloat(-size))
                Capsule()
                    .frame(width: size*2, height: size)
                    .foregroundColor(color2)
                    .offset(x: CGFloat(-size))
                    .clipped()
                    .offset(x: CGFloat(size))
            }
            //        .rotationEffect(rotation.0, anchor: rotation.1)
//            .border(Color.green)
            .transformEffect(transform)
        }
    }
}

struct VirusView: View {
    let color: Color
    let virusSize: CGFloat = baseSize
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .frame(width: virusSize, height: virusSize)
            .foregroundColor(color)
    }
}

#Preview {
    GameView()
}
