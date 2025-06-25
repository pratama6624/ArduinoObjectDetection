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

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
//    @StateObject private var arduinoController = ArduinoController()
    @StateObject private var bleController = BLEController()
    
    @StateObject private var ai = AIChatController()
    @State private var resultText: String = ""
    @State private var bleCommand: String?

    var body: some View {
        ZStack {
            VStack {
                Button("🎙️ Mulai Bicara") {
                    speechRecognizer.startListening { result in
                        resultText = result
                        if ["0", "2", "3", "4", "5", "6"].contains(result) {
                            bleCommand = result
                            // Kirim ke BLE di sini pakai sendCommand(result)
                        }
                    }
                }

                Text("🧠 Hasil: \(resultText)")
                
                Button(action: {
                    speechRecognizer.cekSuaraSaya()
                }) {
                    Text("Cek Suara Saya")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                HStack(spacing: 20) {
                    Button(action: {
                        speechRecognizer.startListening { command in
                            print("Perintah akhir: \(command)")
                            bleController.sendCommand(command) }
                    }) {
                        Text("Mulai Bicara")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        speechRecognizer.stopListening()
                    }) {
                        Text("Stop Bicara")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}
