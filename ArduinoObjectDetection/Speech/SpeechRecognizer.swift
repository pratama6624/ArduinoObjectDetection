//
//  Untitled.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 03/06/25.
//

import Foundation
import AVFoundation
import Speech

// MARK: - SpeechRecognizer Class
class SpeechRecognizer: ObservableObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID"))!
    private var audioEngine: AVAudioEngine?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    
    private func parsePerintah(from text: String) -> String? {
        let lowercased = text.lowercased()

        let perintah: [(keyword: String, command: String)] = [
            ("lampu satu", "F2"),
            ("lampu 1", "F2"),
            ("lampu dua", "F3"),
            ("lampu 2", "F3"),
            ("lampu tiga", "F4"),
            ("lampu 3", "F4"),
            ("lampu empat", "F5"),
            ("lampu 4", "F5"),
            ("lampu lima", "F6"),
            ("lampu 5", "F6"),
            ("semua mati", "F0"),
            ("matikan semua", "F0"),
            ("semua lampu mati", "F0")
        ]

        for item in perintah {
            if lowercased.contains(item.keyword) {
                return item.command
            }
        }

        return nil
    }

    func startListening(completion: @escaping (String) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                print("Akses mikrofon ditolak.")
                return
            }

            DispatchQueue.main.async {
                do {
                    try self.listen(completion: completion)
                } catch {
                    print("Gagal mulai: \(error.localizedDescription)")
                }
            }
        }
    }

    private func listen(completion: @escaping (String) -> Void) throws {
        stopListening()

        audioEngine = AVAudioEngine()
        request = SFSpeechAudioBufferRecognitionRequest()

        guard let audioEngine = audioEngine,
              let request = request else {
            throw NSError(domain: "SpeechRecognizer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Gagal inisialisasi komponen."])
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        
        var lastSpokenTime = Date()
        var finalString = ""

        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                finalString = result.bestTranscription.formattedString
                lastSpokenTime = Date()
                print("Real-time: \(finalString)")
            }
            
            if let error = error {
                print("Speech error: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if Date().timeIntervalSince(lastSpokenTime) >= 3 {
                    self.stopListening()
                    
                    if let command = self.parsePerintah(from: finalString) {
                        completion(command)
                    } else {
                        print("Tidak ada perintah cocok.")
                        completion(finalString)
                    }
                }
            }
        }

        print("Mulai dengar suara...")
    }

    func stopListening() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        print("Perekaman dihentikan.")
    }
}
