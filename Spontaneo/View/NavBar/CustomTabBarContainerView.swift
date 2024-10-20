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
                CustomTabBarView(tabs: tabs, selection: $selection, localSelection: localSelection, namespace: namespace, isFloating: false)
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
