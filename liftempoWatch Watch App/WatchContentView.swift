import SwiftUI

struct WatchContentView: View {
    private let connectivity = WatchConnectivityProvider()
    private let motionRecorder = MotionRecorder()

    @State private var isSetRunning = false
    @State private var sampleCount = 0

    var body: some View {
        VStack(spacing: 8) {
            Text("liftempo")
                .font(.headline)

            Text(isSetRunning ? "Set in progress" : "Ready")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Samples: \(sampleCount)")
                .font(.caption2)

            if isSetRunning {
                Button("End Set") {
                    isSetRunning = false
                    motionRecorder.stopRecording()
                    sampleCount = motionRecorder.samples.count

                    // 🔥 send samples to phone
                    connectivity.sendSetCompleted(samples: motionRecorder.samples)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Start Set") {
                    sampleCount = 0
                    isSetRunning = true
                    motionRecorder.startRecording()
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
