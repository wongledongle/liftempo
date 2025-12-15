//
//  ContentView.swift
//  liftempoWatch Watch App
//
//  Created by Arthur Wong on 12/15/25.
//

import SwiftUI

struct WatchContentView: View {
    private let connectivity = WatchConnectivityProvider()
    @State private var isSetRunning = false

    var body: some View {
        VStack(spacing: 12) {
            Text("liftempo")
                .font(.headline)

            Text(isSetRunning ? "Set in progress" : "Ready")
                .font(.caption)
                .foregroundStyle(.secondary)

            if isSetRunning {
                Button("End Set") {
                    isSetRunning = false
                    connectivity.sendSetCompleted()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Start Set") {
                    isSetRunning = true
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

#Preview {
    WatchContentView()
}


