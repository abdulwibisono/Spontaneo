import SwiftUI
import MapKit
import Combine

class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var isSearching = false
    
    private var searchCompleter: MKLocalSearchCompleter?
    private var region: Binding<MKCoordinateRegion>?
    private var onCompletionSelected: ((MKLocalSearchCompletion) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    func bind(
        searchCompleter: MKLocalSearchCompleter,
        searchResults: Binding<[MKLocalSearchCompletion]>,
        isSearching: Binding<Bool>,
        region: Binding<MKCoordinateRegion>,
        onCompletionSelected: @escaping (MKLocalSearchCompletion) -> Void
    ) {
        self.searchCompleter = searchCompleter
        self.region = region
        self.onCompletionSelected = onCompletionSelected
        
        $searchResults
            .sink { newValue in
                searchResults.wrappedValue = newValue
            }
            .store(in: &cancellables)
        
        $isSearching
            .sink { newValue in
                isSearching.wrappedValue = newValue
            }
            .store(in: &cancellables)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        isSearching = !completer.results.isEmpty
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}
