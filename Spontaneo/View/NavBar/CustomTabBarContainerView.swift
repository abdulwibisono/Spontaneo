import SwiftUI

struct CustomTabBarContainerView<Content: View>: View {
    @Binding var selection: TabBarItem
    let content: Content
    @State private var tabs: [TabBarItem] = []
    @State private var localSelection: TabBarItem = .home
    @Namespace private var namespace
    
    init(selection: Binding<TabBarItem>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            ZStack {
                // Non-floating tab bar (always present)
                CustomTabBarView(tabs: tabs, selection: $selection, localSelection: localSelection, namespace: namespace, isFloating: false)
                    .opacity(selection == .home ? 0 : 1)
                
                // Floating tab bar (only visible on home)
                CustomTabBarView(tabs: tabs, selection: $selection, localSelection: localSelection, namespace: namespace, isFloating: true)
                    .opacity(selection == .home ? 1 : 0)
                    .offset(y: selection == .home ? 0 : 20)
            }
            .animation(.easeInOut, value: selection)
        }
        .onPreferenceChange(TabBarItemsPreferenceKey.self, perform: { value in
            self.tabs = value
        })
        .onChange(of: selection) { newValue in
            withAnimation(.easeInOut) {
                localSelection = newValue
            }
        }
    }
}
