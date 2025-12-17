import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        NavigationStack {
            VStack {
                if sessionStore.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sets Yet",
                        systemImage: "waveform.path.ecg",
                        description: Text("Start a set on Apple Watch. The iPhone app will derive on-device features and show them here.")
                    )
                } else {
                    List(sessionStore.sessions) { session in
                        NavigationLink {
                            SessionDetailView(session: session)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Set at \(session.date.formatted(date: .omitted, time: .shortened))")
                                    Text("\(session.features.sampleCount) samples  •  \(session.features.estimatedHz, specifier: "%.1f") Hz")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("Accel mean \(session.features.accelerationMagnitudeMean, specifier: "%.4f")  •  Gyro mean \(session.features.rotationMagnitudeMean, specifier: "%.4f")")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    Text("Predictions: E \(session.features.predictionSummary.eccentricCount)  C \(session.features.predictionSummary.concentricCount)  U \(session.features.predictionSummary.unknownCount)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                }

                Button("Add dummy session") {
                    sessionStore.addSession()
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .navigationTitle("Tempo Sets")
        }
    }
}
