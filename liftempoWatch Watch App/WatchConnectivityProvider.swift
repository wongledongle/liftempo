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

    func sendSetCompleted() {
        let session = WCSession.default

        guard session.isReachable else {
            print("iPhone not reachable from watch")
            return
        }

        print("Watch sending set_completed message to iPhone")

        session.sendMessage(
            ["event": "set_completed"],
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
