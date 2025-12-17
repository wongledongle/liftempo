import SwiftUI

struct WatchContentView: View {
    private let connectivity = WatchConnectivityProvider()
    private let motionRecorder = MotionRecorder()

    @State private var isSetRunning = false
    @State private var sampleCount = 0
    @State private var syncStatus = ""

    var body: some View {
        VStack(spacing: 8) {
            Text("liftempo")
                .font(.headline)

            Text(isSetRunning ? "Set in progress" : "Ready")
                .font(.caption)
                .foregroundStyle(.secondary)

            if !syncStatus.isEmpty {
                Text(syncStatus)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text("Samples: \(sampleCount)")
                .font(.caption2)

            if isSetRunning {
                Button("End Set") {
                    isSetRunning = false
                    motionRecorder.stopRecording()
                    sampleCount = motionRecorder.samples.count

                    let result = connectivity.sendSetCompleted(samples: motionRecorder.samples)
                    switch result {
                    case .sentImmediate:
                        syncStatus = "Synced to iPhone"
                    case .queued:
                        syncStatus = "Queued. Open iPhone app to receive."
                    case .noCompanionApp:
                        syncStatus = "Install this iPhone app first."
                    case .notActivated:
                        syncStatus = "Connectivity not ready. Try again."
                    case .unsupported:
                        syncStatus = "WatchConnectivity unsupported"
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Start Set") {
                    sampleCount = 0
                    syncStatus = ""
                    isSetRunning = true
                    motionRecorder.startRecording()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
