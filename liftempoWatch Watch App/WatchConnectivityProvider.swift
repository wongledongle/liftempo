import Foundation
import WatchConnectivity

class WatchConnectivityProvider: NSObject, WCSessionDelegate {
    enum SendResult {
        case sentImmediate
        case queued
        case noCompanionApp
        case notActivated
        case unsupported
    }

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

    func sendSetCompleted(samples: [MotionSample]) -> SendResult {
        guard WCSession.isSupported() else {
            return .unsupported
        }

        let session = WCSession.default
        guard session.activationState == .activated else {
            return .notActivated
        }

        guard session.isCompanionAppInstalled else {
            return .noCompanionApp
        }

        let mapped: [[String: Double]] = samples.map { sample in
            [
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

        if session.isReachable {
            session.sendMessage(
                message,
                replyHandler: nil,
                errorHandler: { error in
                    print("Error sending immediate message from watch: \(error.localizedDescription)")
                }
            )
            return .sentImmediate
        }

        session.transferUserInfo(message)
        return .queued
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
