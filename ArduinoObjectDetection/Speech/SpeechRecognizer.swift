//
//  Untitled.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 03/06/25.
//

import Foundation
import AVFoundation
import Speech
import CoreML

// MARK: - SpeechRecognizer Class
class SpeechRecognizer: ObservableObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID"))!
    private var audioEngine: AVAudioEngine?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private let voiceClassifier = try? CleanVoiceTraining(configuration: .init())
    
    private var debounceTimer: Timer?
    var hasHandledFinalResult = false
    let speechSynthesizer: AVSpeechSynthesizer = {
        let synth = AVSpeechSynthesizer()
        return synth
    }()
    
    // --------------------
    
    @Published var isKontrolAktif: Bool = false
    private let ai = AIChatController()
    
    private func cekModeKontrol(_ text: String) -> Bool {
        let keyword = ["aktifkan mode kontrol", "masuk mode kontrol", "siap kontrol"]
        return keyword.contains(where: text.lowercased().contains)
    }

    private func cekKeluarModeKontrol(_ text: String) -> Bool {
        let keyword = ["selesai kontrol", "berhenti kontrol", "keluar mode kontrol"]
        return keyword.contains(where: text.lowercased().contains)
    }
    
    // --------------------
    
    func cekLabelModel() {
        guard let dummyArray = try? MLMultiArray(shape: [15600], dataType: .float32) else {
            print("Gagal bikin dummy MLMultiArray")
            return
        }
        
        for i in 0..<dummyArray.count {
            dummyArray[i] = 0
        }

        do {
            let model = try CleanVoiceTraining()
            let prediction = try model.prediction(audioSamples: dummyArray)
            print("Labels yang ada di model:")
            for label in prediction.targetProbability.keys {
                print("- \(label)")
            }
        } catch {
            print("Error load model atau prediksi: \(error)")
        }
    }
    
    func cekSuaraSaya() {
        cekLabelModel()
        print("🔊 Mulai cek suara...")

        let audioEngine = AVAudioEngine()
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Temp file path
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("cek_suara.wav")

        // Setup AVAudioFile for writing
        guard let audioFile = try? AVAudioFile(forWriting: fileURL, settings: format.settings) else {
            print("❌ Gagal buat file rekaman")
            return
        }

        // Start recording tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            do {
                try audioFile.write(from: buffer)
            } catch {
                print("⚠️ Gagal tulis buffer ke file: \(error)")
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("🎙️ Mulai rekaman 3 detik...")
        } catch {
            print("❌ Gagal mulai audio engine: \(error)")
            return
        }

        // Stop recording after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            print("🛑 Rekaman selesai")

            // Process audio file to MLMultiArray
            do {
                let mlArray = try self.loadAudioSamplesAsMLMultiArray(from: fileURL)
                let classifier = try CleanVoiceTraining()

                let prediction = try classifier.prediction(audioSamples: mlArray)
                print("🧠 Prediksi label: \(prediction.target)")
                if prediction.target.lowercased().contains("pratama") {
                    print("✅ Ini suara kamu!")
                } else {
                    print("❌ Bukan kamu.")
                }
            } catch {
                print("⚠️ Gagal klasifikasi suara: \(error)")
            }
        }
    }

    // Helper function: Load audio samples from file, convert to float array of length 15,600 and wrap in MLMultiArray
    func loadAudioSamplesAsMLMultiArray(from url: URL) throws -> MLMultiArray {
        let file = try AVAudioFile(forReading: url)
        let format = file.processingFormat
        let frameCount = UInt32(file.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw NSError(domain: "AudioBufferError", code: -1)
        }
        try file.read(into: buffer)

        // Extract float samples from buffer (mono or stereo mixdown)
        let channelData = buffer.floatChannelData![0]
        let sampleCount = Int(buffer.frameLength)

        // Convert to [Float]
        var samples = Array(UnsafeBufferPointer(start: channelData, count: sampleCount))

        // Target size for model input
        let targetSize = 15600

        // Resize to targetSize:
        // If shorter, pad with zeros; if longer, trim
        if samples.count < targetSize {
            samples += Array(repeating: 0, count: targetSize - samples.count)
        } else if samples.count > targetSize {
            samples = Array(samples[0..<targetSize])
        }

        // Create MLMultiArray from samples
        let mlArray = try MLMultiArray(shape: [NSNumber(value: targetSize)], dataType: .float32)
        for i in 0..<targetSize {
            mlArray[i] = NSNumber(value: samples[i])
        }
        return mlArray
    }
    
    private func parsePerintah(from text: String) -> String? {
        let lowercased = text.lowercased()

        let perintah: [(keyword: String, command: String)] = [
            // Lampu (pin 2–4 di Arduino)
            ("lampu satu", "1"),
            ("lampu 1", "1"),
            ("lampu dua", "2"),
            ("lampu 2", "2"),
            ("lampu tiga", "3"),
            ("lampu 3", "3"),

            // Matikan semua lampu
            ("semua mati", "0"),
            ("matikan semua", "0"),
            ("matikan lampu", "0"),

            // Stepper (A–D)
            ("buka tirai sedikit", "A"),     // 25°
            ("buka tirai seperempat", "B"),  // 50°
            ("buka tirai setengah", "C"),    // 75°
            ("buka tirai sepenuhnya", "D"),       // 100°

            // Buzzer
            ("bunyikan", "Z"),
            ("bunyikan alarm", "Z"),
            ("diam", "X"),
            ("matikan suara", "X"),

            // RTC (lihat waktu)
            ("jam berapa", "T"),
            ("lihat waktu", "T"),

            // Selenoid (relay pin 13)
            ("buka pintu", "S"),
            ("buka kunci", "S"),
            ("tutup pintu", "s"),
            ("tutup kunci", "s")
        ]

        for item in perintah {
            if lowercased.contains(item.keyword) {
                return item.command
            }
        }

        return nil
    }

    func startListening(completion: @escaping (String) -> Void) {
        hasHandledFinalResult = false
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
    
    func speak(_ text: String, completion: (() -> Void)? = nil) {
        let utterance = AVSpeechUtterance(string: text)
        if let indoVoice = AVSpeechSynthesisVoice(language: "id-ID") {
            utterance.voice = indoVoice
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        speechSynthesizer.speak(utterance)
    }

    private func listen(completion: @escaping (String) -> Void) throws {
        let model = try CleanVoiceTraining()
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
                print("Real-time: \(finalString)")
                
                // Reset timer tiap kali ada update
                self.debounceTimer?.invalidate()
                DispatchQueue.main.async {
                    self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                        if !self.hasHandledFinalResult {
                            self.hasHandledFinalResult = true
                            self.stopListening()

                            let finalLower = finalString.lowercased()

                            if self.cekModeKontrol(finalLower) {
                                self.isKontrolAktif = true
                                self.speak("Mode kontrol diaktifkan")
                                print("Mode kontrol diaktifkan")
                                return
                            }

                            if self.cekKeluarModeKontrol(finalLower) {
                                self.isKontrolAktif = false
                                self.speak("Mode kontrol dinonaktifkan")
                                print("Mode kontrol dinonaktifkan")
                                return
                            }

                            if self.isKontrolAktif, let command = self.parsePerintah(from: finalLower) {
                                self.speak("Menjalankan perintah \(command)")
                                print("Menjalankan perintah \(command)")
                                completion(command) // Kirim ke Arduino
                            } else if self.isKontrolAktif {
                                self.speak("Perintah tidak dikenali dalam mode kontrol")
                                print("Perintah tidak dikenali dalam mode kontrol")
                            } else {
                                // Bukan mode kontrol → kirim ke AI
                                self.ai.tanyaKeAI(finalLower) { response in
                                    DispatchQueue.main.async {
                                        if let jawaban = response {
                                            self.speak(jawaban)
                                            print(jawaban)
                                        } else {
                                            self.speak("Maaf, saya tidak mengerti.")
                                            print("Maaf, saya tidak mengerti.")
                                        }
                                        completion(finalString)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if let error = error {
                print("Speech error: \(error.localizedDescription)")
            }
        }

        print("Mulai dengar suara...")
    }

    func stopListening() {
        // 1. Minta recognitionTask selesai secara elegant
        recognitionTask?.finish()
        recognitionTask?.cancel()
        recognitionTask = nil

        // 2. Stop audio
        request?.endAudio()
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)

        // 3. Reset buffer & engine
        request = nil
        audioEngine = nil

        print("Perekaman dihentikan.")
    }
}
