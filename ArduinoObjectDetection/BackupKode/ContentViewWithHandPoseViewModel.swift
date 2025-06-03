//
//  ContentView.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 01/06/25.
//

import SwiftUI
// import Vision
import AVFoundation
// import ORSSerial
import Speech

struct ContentViewBackupWithHandPoseViewModel: View {
    // Matikan dulu aja karena project handpose tidak masuk akal
    // @StateObject private var viewModel = HandPoseViewModel()
    @StateObject private var speechRecognizer = SpeechRecognizerBackup()

    var body: some View {
        ZStack {
            // Kamera dimatikan sementara
            // CameraPreviewView(session: viewModel.captureSession)
            //     .frame(width: 640, height: 480)
            //     .cornerRadius(12)
            //     .padding()

            // Bounding box juga dimatikan
            /*
            if let box = viewModel.boundingBox {
                GeometryReader { geo in
                    let frame = CGRect(
                        x: box.origin.x * geo.size.width,
                        y: (1 - box.origin.y - box.height) * geo.size.height,
                        width: box.width * geo.size.width,
                        height: box.height * geo.size.height
                    )

                    Rectangle()
                        .path(in: frame)
                        .stroke(Color.red, lineWidth: 4)
                        .animation(.easeInOut, value: viewModel.boundingBox)
                }
            }
            */

            VStack {
                Spacer()

                // viewModel.fingerCount dinonaktifkan
                /*
                Text("Jumlah jari terdeteksi: \(viewModel.fingerCount)")
                    .font(.title)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 10)
                */

                HStack(spacing: 20) {
                    Button(action: {
                        speechRecognizer.startListening()
                    }) {
                        Text("🎤 Mulai Bicara")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        speechRecognizer.stopListening()
                    }) {
                        Text("🔇 Stop Bicara")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // viewModel.requestCameraAccess()
            // viewModel.startCamera()
        }
    }
}

// MARK: - SpeechRecognizer Class
class SpeechRecognizerBackup: ObservableObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "id-ID"))!
    private var audioEngine: AVAudioEngine?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var request: SFSpeechAudioBufferRecognitionRequest?

    func startListening() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                print("Akses mikrofon ditolak.")
                return
            }

            DispatchQueue.main.async {
                do {
                    try self.listen()
                } catch {
                    print("Gagal mulai: \(error.localizedDescription)")
                }
            }
        }
    }

    private func listen() throws {
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

        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                print("Dikenali: \(result.bestTranscription.formattedString)")
            } else if let error = error {
                print("Tidak dikenali: \(error.localizedDescription)")
            }
        }

        print("🎙️ Mulai dengar suara...")
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
