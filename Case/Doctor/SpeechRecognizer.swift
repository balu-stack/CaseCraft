//
//  SpeechRecognizer.swift
//  Case
//
//  Created by SAIL L1 on 25/02/26.
//


import Foundation
import Speech
import AVFoundation

@MainActor
final class SpeechRecognizer: ObservableObject {

    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String? = nil

    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-IN"))

    func requestPermissions() async -> Bool {
        // Speech permission
        let speechAuth = await withCheckedContinuation { (cont: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }

        guard speechAuth == .authorized else {
            errorMessage = "Speech permission not granted."
            return false
        }

        // Microphone permission
        let micGranted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            AVAudioApplication.requestRecordPermission { granted in
                cont.resume(returning: granted)
            }
        }

        guard micGranted else {
            errorMessage = "Microphone permission not granted."
            return false
        }

        return true
    }

    func start() async {
        if isRecording { return }
        errorMessage = nil
        transcript = ""

        let ok = await requestPermissions()
        guard ok else { return }

        do {
            // Cancel existing task
            task?.cancel()
            task = nil

            // Audio session
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)

            request = SFSpeechAudioBufferRecognitionRequest()
            guard let request else { throw NSError(domain: "ASR", code: 1) }

            request.shouldReportPartialResults = true

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)

            // Remove old tap if any
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                self?.request?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true

            task = recognizer?.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }

                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }

                if error != nil || (result?.isFinal == true) {
                    Task { @MainActor in
                        await self.stop()
                    }
                }
            }

        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            await stop()
        }
    }

    func stop() async {
        if !isRecording { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        request?.endAudio()
        request = nil

        task?.cancel()
        task = nil

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch { }

        isRecording = false
    }
}
extension CaseFormData {
    var missingRequiredFields: [String] {
        var missing: [String] = []

        func req(_ label: String, _ value: String) {
            if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                missing.append(label)
            }
        }

        // Example required fields (add yours)
        req("Chief Complaint", chiefComplaint)
        req("Presenting Illness", presentingIllness)
        req("Missing Teeth", missingTeeth)
        req("Head Shape", headShape)
        req("Face Shape", faceShape)

        return missing
    }

    var isComplete: Bool { missingRequiredFields.isEmpty }
}
