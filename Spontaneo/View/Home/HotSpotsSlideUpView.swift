import SwiftUI

struct HotSpotsSlideUpView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Handle()
            
            Text("What's in the Area")
                .bold()
                .font(.system(size: 24))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<4) { _ in
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(width: 200, height: 100)
                            .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .frame(height: UIScreen.main.bounds.height * 0.4)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .offset(y: isPresented ? 0 : UIScreen.main.bounds.height)
        .animation(.spring(), value: isPresented)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height > 50 {
                        isPresented = false
                    }
                }
        )
    }
}

struct Handle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.secondary)
            .frame(width: 40, height: 5)
            .padding()
    }
}
