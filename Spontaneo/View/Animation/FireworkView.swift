import SwiftUI

struct FireworkView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { _ in
                Circle()
                    .fill(Color.random)
                    .frame(width: 8, height: 8)
                    .offset(x: isAnimating ? CGFloat.random(in: -100...100) : 0,
                            y: isAnimating ? CGFloat.random(in: -100...100) : 0)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 1)
                            .repeatCount(1, autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}
