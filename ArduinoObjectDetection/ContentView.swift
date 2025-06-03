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
    @StateObject private var arduinoController = ArduinoController()

    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 20) {
                    Button(action: {
                        speechRecognizer.startListening { command in
                            print("Perintah akhir: \(command)")
                            arduinoController.sendCommand(command) }
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
