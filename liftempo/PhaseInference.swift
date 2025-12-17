#if os(iOS)
import Foundation
import CoreML

enum PhaseLabel: String {
    case eccentric
    case concentric
    case unknown
}

struct PhasePrediction {
    let label: PhaseLabel
    let confidence: Double
    let source: String
}

final class PhaseClassifier {
    static let shared = PhaseClassifier()

    private let model: MLModel?

    private init() {
        if let url = Bundle.main.url(forResource: "PhaseClassifier", withExtension: "mlmodelc") {
            model = try? MLModel(contentsOf: url)
        } else {
            model = nil
        }
    }

    func predict(vector: PhaseFeatureVector) -> PhasePrediction {
        if let prediction = modelPrediction(vector: vector) {
            return prediction
        }
        return heuristicPrediction(vector: vector)
    }

    private func modelPrediction(vector: PhaseFeatureVector) -> PhasePrediction? {
        guard let model else { return nil }

        var dictionary: [String: MLFeatureValue] = [:]
        for (index, value) in vector.values.enumerated() {
            dictionary["f\(index)"] = MLFeatureValue(double: value)
        }

        guard
            let provider = try? MLDictionaryFeatureProvider(dictionary: dictionary),
            let result = try? model.prediction(from: provider)
        else {
            return nil
        }

        let rawLabel = result.featureValue(for: "label")?.stringValue
            ?? result.featureValue(for: "classLabel")?.stringValue
            ?? PhaseLabel.unknown.rawValue

        let label = PhaseLabel(rawValue: rawLabel) ?? .unknown
        let confidence = result.featureValue(for: "labelProbability")?.dictionaryValue[rawLabel] as? Double
            ?? result.featureValue(for: "classProbability")?.dictionaryValue[rawLabel] as? Double
            ?? 0.5

        return PhasePrediction(label: label, confidence: confidence, source: "coreml")
    }

    private func heuristicPrediction(vector: PhaseFeatureVector) -> PhasePrediction {
        let strongestAxisMean = [vector.meanAccX, vector.meanAccY, vector.meanAccZ]
            .max(by: { abs($0) < abs($1) }) ?? 0

        let label: PhaseLabel
        if abs(strongestAxisMean) < 0.015 && vector.meanRotMagnitude < 0.08 {
            label = .unknown
        } else if strongestAxisMean >= 0 {
            label = .concentric
        } else {
            label = .eccentric
        }

        let rawConfidence = min(
            0.98,
            max(
                0.35,
                abs(strongestAxisMean) * 6.0
                    + vector.meanRotMagnitude * 0.45
                    + vector.stdAccMagnitude * 0.8
            )
        )

        return PhasePrediction(label: label, confidence: rawConfidence, source: "heuristic")
    }
}
#endif
