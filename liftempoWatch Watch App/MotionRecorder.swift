import Foundation
import CoreMotion

class MotionRecorder {
    private let motionManager = CMMotionManager()

    private(set) var samples: [MotionSample] = []
    private(set) var isRecording: Bool = false

    func startRecording() {
        guard !isRecording else { return }

        // Make sure device motion is available on this watch
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion not available on this watch")
            return
        }

        samples.removeAll()
        isRecording = true

        // 50 Hz
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }

            if let error = error {
                print("Device motion error: \(error.localizedDescription)")
                return
            }

            guard let motion = motion, self.isRecording else { return }

            let now = Date().timeIntervalSince1970
            let rot = motion.rotationRate      // gyro
            let acc = motion.userAcceleration  // accel

            let sample = MotionSample(
                timestamp: now,
                rotX: rot.x,
                rotY: rot.y,
                rotZ: rot.z,
                accX: acc.x,
                accY: acc.y,
                accZ: acc.z
            )

            self.samples.append(sample)
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        motionManager.stopDeviceMotionUpdates()
        print("Stopped recording. Captured \(samples.count) samples.")
    }

    func reset() {
        samples.removeAll()
        isRecording = false
        motionManager.stopDeviceMotionUpdates()
    }
}
