import SwiftUI

struct HotSpotsSlideUpView: View {
    
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
            }
            .blur(radius: getBlurRadius())
            .ignoresSafeArea()
            
            
            GeometryReader { proxy -> AnyView in
                let height = proxy.frame(in: .global).height
                
                return AnyView(
                    ZStack {
                        BlurView(style: .systemThinMaterialLight)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                        
                        VStack {
                            Capsule()
                                .fill(Color.gray)
                                .frame(width: 80, height: 4)
                                .padding(.top)
                            
                            Text("What's in the Area")
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .foregroundColor(.black)
                            
                            HotSpotContent()
                        }
                        .padding(.horizontal)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .offset(y: height - 200)
                    .offset(y: -offset > 0 ? -offset <= (height - 100) ? offset: -(height - 100): 0)
                    .gesture(
                        DragGesture()
                            .updating($gestureOffset, body: { value, out, _ in
                                out = value.translation.height
                            })
                            .onEnded { value in
                                let maxHeight = height - 100
                                withAnimation {
                                    if -offset > 100 && -offset < maxHeight / 2 {
                                        offset = -(maxHeight / 3)
                                    } else if -offset > maxHeight / 2 {
                                        offset = -maxHeight
                                    } else {
                                        offset = 0
                                    }
                                }
                                lastOffset = offset
                            }
                    )
                )
            }
        }
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset
        }
    }
    
    func getBlurRadius() -> CGFloat {
        let progress = -offset / (UIScreen.main.bounds.height - 100)
        
        return progress * 30
    }
}

struct HotSpotContent: View {
    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: 70, height:50)
                
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: 70, height:50)
            }
            
            HStack {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: 70, height:50)
                
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: 70, height:50)
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    HotSpotsSlideUpView()
}
