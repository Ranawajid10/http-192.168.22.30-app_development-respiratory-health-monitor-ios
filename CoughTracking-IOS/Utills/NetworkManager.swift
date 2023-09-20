//
//  NetworkManager.swift
//  CoughTracking-IOS
//
//  Created by Ali Rizwan on 06/09/2023.
//

import SwiftUI
import Combine

class NetworkManager: ObservableObject {
    @Published var isInternetAvailable = false
    private var cancellables: Set<AnyCancellable> = []

    init() {
        checkInternetAvailability()
    }

    private func checkInternetAvailability() {
        let url = URL(string: "https://www.google.com")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map { _ in true }
            .catch { _ in Just(false) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isInternetAvailable, on: self)
            .store(in: &cancellables)
    }
}

