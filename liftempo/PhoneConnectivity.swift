import Foundation
import WatchConnectivity

class PhoneConnectivity: NSObject, WCSessionDelegate {
    static let shared = PhoneConnectivity()

    private var sessionStore: SessionStore?

    func configure(with store: SessionStore) {
        self.sessionStore = store

        guard WCSession.isSupported() else {
            print("WCSession not supported on this device")
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("iPhone WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("iPhone WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleIncoming(message: message)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        handleIncoming(message: userInfo)
    }

    private func handleIncoming(message: [String: Any]) {
        print("iPhone received connectivity payload: \(message.keys)")

        guard let event = message["event"] as? String, event == "set_completed" else { return }

        let samples: [MotionSample]

        if let rawSamples = message["samples"] as? [[String: Double]] {
            samples = rawSamples.compactMap { dict -> MotionSample? in
                guard
                    let t = dict["t"],
                    let rx = dict["rx"],
                    let ry = dict["ry"],
                    let rz = dict["rz"],
                    let ax = dict["ax"],
                    let ay = dict["ay"],
                    let az = dict["az"]
                else {
                    return nil
                }

                return MotionSample(
                    timestamp: t,
                    rotX: rx,
                    rotY: ry,
                    rotZ: rz,
                    accX: ax,
                    accY: ay,
                    accZ: az
                )
            }
        } else {
            samples = []
        }

        DispatchQueue.main.async { [weak self] in
            self?.sessionStore?.addSession(samples: samples)
        }
    }
}
