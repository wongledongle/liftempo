//
//  PhoneConnectivity.swift
//  liftempo
//
//  Created by Arthur Wong on 12/15/25.
//


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

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Required on iOS but you can leave empty for now
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Required on iOS, reactivate
        WCSession.default.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("iPhone received message: \(message)")

        guard let event = message["event"] as? String else { return }

        if event == "set_completed" {
            DispatchQueue.main.async { [weak self] in
                self?.sessionStore?.addSession()
            }
        }
    }
}
