//
//  CompletionPopupView.swift
//  isoWalk
//
//  Created by AnnElaine on 4/2/26.
//
//  COMPONENT — standalone popup overlay.
//  Displays when a walk session naturally completes.
//

import SwiftUI
import UIKit

struct CompletionPopupView: View {
    var onGoToProgress: () -> Void
    
    var body: some View {
        ZStack {
            // Dark overlay blocks interactions with the view beneath
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🎉 Congratulations!")
                    .font(.custom("Inter-Bold", size: 28))
                    .foregroundColor(isoWalkColors.jetBlack)
                
                Text("Your isoWalk session is complete. Great job!")
                    .font(.custom("Inter-Regular", size: 16))
                    .foregroundColor(isoWalkColors.slateGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    onGoToProgress()
                }) {
                    Text("View My Progress")
                        .font(.custom("Inter-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isoWalkColors.balticBlue)
                        .cornerRadius(12)
                }
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .padding(.horizontal, 24)
            .zIndex(1)
            
            // 🎊 Clean, Multi-Shape Confetti Burst!
            GeometryReader { geometry in
                ProConfettiView(size: geometry.size)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()
            .zIndex(2)
        }
    }
}

// MARK: - Pro Hardware-Accelerated Confetti (Apple-Style)

// 1. Define our custom shapes
enum ConfettiShape: CaseIterable {
    case rectangle
    case circle
    case triangle
    case pill // A rounded rectangle
}

struct ProConfettiView: UIViewRepresentable {
    let size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: size.width / 2, y: -50)
        emitterLayer.emitterSize = CGSize(width: size.width, height: 1)
        emitterLayer.emitterShape = .line
        
        // 2. Expanded color palette!
        // Note: You can replace these with UIColor(isoWalkColors.balticBlue) if you want brand colors!
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen,
            .systemYellow, .systemPink, .systemTeal,
            .systemOrange, .systemPurple, .cyan
        ]
        
        var cells: [CAEmitterCell] = []
        
        // 3. Loop through every color AND every shape
        for color in colors {
            for shape in ConfettiShape.allCases {
                let cell = CAEmitterCell()
                
                // Since we have many more combinations now (9 colors * 4 shapes = 36 cells),
                // we lower the birthRate per cell so the screen isn't overwhelmed.
                cell.birthRate = 4
                cell.lifetime = 5.0
                cell.velocity = 200
                cell.velocityRange = 80
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4
                cell.yAcceleration = 250
                cell.spin = 3.0
                cell.spinRange = 2.0
                
                cell.scale = 0.4
                cell.scaleRange = 0.2
                
                // Pass the shape into our drawing function
                cell.contents = createConfettiImage(color: color, shape: shape)?.cgImage
                
                cells.append(cell)
            }
        }
        
        emitterLayer.emitterCells = cells
        view.layer.addSublayer(emitterLayer)
        
        // Stop generating new confetti after 0.4 seconds for that clean burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            emitterLayer.birthRate = 0
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    /// 4. Draws specific vector shapes dynamically
    private func createConfettiImage(color: UIColor, shape: ConfettiShape) -> UIImage? {
        let size = CGSize(width: 14, height: 14)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            color.setFill()
            
            switch shape {
            case .rectangle:
                // A classic rectangle
                let path = UIBezierPath(rect: CGRect(x: 3, y: 0, width: 8, height: 14))
                path.fill()
                
            case .circle:
                // A perfect circle
                let path = UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: 8, height: 8))
                path.fill()
                
            case .triangle:
                // A custom hand-drawn triangle path
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 7, y: 2)) // Top point
                path.addLine(to: CGPoint(x: 14, y: 12)) // Bottom right
                path.addLine(to: CGPoint(x: 0, y: 12)) // Bottom left
                path.close()
                path.fill()
                
            case .pill:
                // A rounded rectangle (pill shape)
                let path = UIBezierPath(roundedRect: CGRect(x: 2, y: 0, width: 10, height: 14), cornerRadius: 5)
                path.fill()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        CompletionPopupView(onGoToProgress: {
            print("Navigate to progress tab tapped!")
        })
    }
}

