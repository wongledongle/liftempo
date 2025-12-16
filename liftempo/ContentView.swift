import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore

    @State private var isShowingExportSheet = false
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            VStack {
                if sessionStore.sessions.isEmpty {
                    Text("No sets yet")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List(sessionStore.sessions) { session in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Set at \(session.date.formatted(date: .omitted, time: .shortened))")
                                Text("Samples: \(session.samples.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }

                HStack {
                    // Debug button to add a dummy session
                    Button("Add dummy session") {
                        sessionStore.addSession()
                    }
                    .buttonStyle(.bordered)

                    // 🔥 Export CSV button
                    Button("Export CSV") {
                        exportCSV()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Tempo Sets")
            .sheet(isPresented: $isShowingExportSheet, onDismiss: {
                exportURL = nil
            }) {
                if let exportURL = exportURL {
                    ActivityView(activityItems: [exportURL])
                } else {
                    Text("No file to export")
                }
            }
        }
    }

    private func exportCSV() {
        let csvString = CSVExporter.sessionsToCSV(sessionStore.sessions)

        // Write to a temporary file
        do {
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("liftempo_sessions.csv")

            try csvString.data(using: .utf8)?.write(to: fileURL, options: .atomic)

            exportURL = fileURL
            isShowingExportSheet = true
        } catch {
            print("Failed to write CSV: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
}
