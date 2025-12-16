import Foundation
import WatchConnectivity

class WatchConnectivityProvider: NSObject, WCSessionDelegate {

    override init() {
        super.init()

        guard WCSession.isSupported() else {
            print("Watch WCSession not supported")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func sendSetCompleted(samples: [MotionSample]) {
        let session = WCSession.default

        guard session.isReachable else {
            print("iPhone not reachable from watch")
            return
        }

        // Convert MotionSample to a WCSession-safe payload (no custom types)
        let mapped: [[String: Double]] = samples.map { sample in
            return [
                "t": sample.timestamp,
                "rx": sample.rotX,
                "ry": sample.rotY,
                "rz": sample.rotZ,
                "ax": sample.accX,
                "ay": sample.accY,
                "az": sample.accZ
            ]
        }

        let message: [String: Any] = [
            "event": "set_completed",
            "timestamp": Date().timeIntervalSince1970,
            "samples": mapped
        ]

        print("Watch sending set_completed with \(samples.count) samples")

        session.sendMessage(
            message,
            replyHandler: nil,
            errorHandler: { error in
                print("Error sending message from watch: \(error.localizedDescription)")
            }
        )
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("Watch WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("Watch WCSession activated with state: \(activationState.rawValue)")
        }
    }
}
