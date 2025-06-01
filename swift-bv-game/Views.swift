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
        GeometryReader { geometry in
            VStack {
                HStack {
                    PillView(color1: game.nextPill.piece1.color.color, color2: game.nextPill.piece2?.color.color)
                        .scaleEffect(0.75)
                    Spacer()
                }
                ZStack {
                    ZStack {
                        DrawViruses(viruses: game.viruses)
                        DrawPills(pills: game.pills, onRotate: game.rotatePill, onMove: game.movePill, onRelease: game.snapPillToCol)
                    }
                    .frame(width: CGFloat(stageCols) * baseSize,
                           height: CGFloat(stageRows) * baseSize)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
                }
                .onAppear {
                    game.startGameLoop()
                }
                .onDisappear {
                    game.stopGameLoop()
                }
            }
        }
    }
}

struct DrawViruses: View {
    let viruses: [Virus]
    
    var body: some View {
        ForEach(viruses, id: \.self) { virus in
            VirusView(color: virus.color.color)
                .position(CGPoint(x: virus.location.col * Int(baseSize) + Int(xBaseline), y: virus.location.row * Int(baseSize) + Int(yBaseline)))
        }
    }
}

struct DrawPills: View {
    let pills: [Pill]
    let onRotate: (UUID) -> Void
    let onMove: (UUID, CGFloat, CGFloat) -> Void
    let onRelease: (UUID) -> Void
    
    var body: some View {
        ForEach(pills) { pill in
            var px: CGFloat {
                if let loc = pill.mainLocation {
                    CGFloat(loc.col + 1) * baseSize
                } else { pill.x }
            }
            var py: CGFloat {
                if let loc = pill.mainLocation {
                    CGFloat((loc.row + 1) * Int(baseSize) - Int(yBaseline))
                } else { pill.y }
            }
            var angle: (Angle, UnitPoint) {
                switch pill.rotation {
                case .one, .single:
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
                switch pill.rotation {
                case .single:
                    CGAffineTransform()
                case .one:
                    CGAffineTransform()
                case .two:
                    CGAffineTransform(rotationAngle: 0)
                        .rotated(by: 90 * (.pi / 180))
                        .translatedBy(x: -pillSize, y: -pillSize)
                case .three:
                    CGAffineTransform(rotationAngle: 0)
                        .rotated(by: 180 * (.pi / 180))
                        .translatedBy(x: -pillSize*2, y: -pillSize)
                case .four:
                    CGAffineTransform(rotationAngle: 0)
                        .rotated(by: 270 * (.pi / 180))
                        .translatedBy(x: -pillSize, y: 0)
                }
            }
            PillView(color1: pill.piece1.color.color, color2: pill.piece2?.color.color)
                .transformEffect(transform)
                .position(CGPoint(x: px, y: py))
                .gesture(
                    TapGesture().onEnded({
                        onRotate(pill.id)
                    })
                )
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            onMove(pill.id, value.location.x, value.location.y)
                        })
                        .onEnded({ value in
                            onRelease(pill.id)
                        })
                )
        }
    }
}

struct PillView: View {
    let color1: Color
    let color2: Color?
    let size: CGFloat = pillSize
    
    var body: some View {
        if color2 == nil {
            Capsule()
                .frame(width: size, height: size)
                .foregroundColor(color1)
                .offset(x: -CGFloat(size/2))
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
