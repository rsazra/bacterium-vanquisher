//
//  ContentView.swift
//  swift-bv-game
//
//  Created by Rajbir Singh Azra on 2025-04-23.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var game: Game = .init()
    
    var body: some View {
        ZStack {
            DrawViruses(viruses: game.viruses)
            DrawPills(pills: game.pills)
        }
    }
}

struct DrawViruses: View {
    let viruses: [Virus]
    
    var body: some View {
        ForEach(viruses, id: \.self) { virus in
            VirusView(color: virus.color.color)
                .position(CGPoint(x: virus.row * xMultiplier + xBaseline, y: virus.col * yMultiplier + yBaseline))
        }
    }
}

struct DrawPills: View {
    let pills: [Pill]
    
    var body: some View {
        ForEach(pills, id: \.self) { pill in
            let px: CGFloat? = (pill.row == nil ? pill.x : CGFloat(pill.row! * xMultiplier + xBaseline))
            let py: CGFloat? = (pill.col == nil ? pill.y : CGFloat(pill.col! * yMultiplier + yBaseline))
            PillView(color1: pill.piece1.color.color, color2: pill.piece2?.color.color, rotation: pill.rotation)
                .position(CGPoint(x: px ?? 0, y: py ?? 0))
        }
    }
}

struct PillView: View {
    let color1: Color
    var color2: Color?
    let rotation: Rotation
    let size: CGFloat = pillSize
    var angle: (Angle, UnitPoint) {
        switch rotation {
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
        switch rotation {
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
