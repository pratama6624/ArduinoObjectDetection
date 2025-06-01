//
//  ContentView.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 01/06/25.
//

import SwiftUI
import Vision
import AVFoundation
import ORSSerial

struct ContentView: View {
    @StateObject private var viewModel = HandPoseViewModel()
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: viewModel.captureSession)
                .frame(width: 640, height: 480)
                .cornerRadius(12)
                .padding()
            
            if let box = viewModel.boundingBox {
                GeometryReader { geo in
                    let frame = CGRect(x: box.origin.x * geo.size.width,
                                       y: (1 - box.origin.y - box.height) * geo.size.height,
                                       width: box.width * geo.size.width,
                                       height: box.height * geo.size.height)
                    
                    Rectangle()
                        .path(in: frame)
                        .stroke(Color.red, lineWidth: 4)
                        .animation(.easeInOut, value: viewModel.boundingBox)
                }
            }
            
            VStack {
                Spacer()
                Text("Jumlah jari terdeteksi: \(viewModel.fingerCount)")
                    .font(.title)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            viewModel.requestCameraAccess()
            viewModel.startCamera()
        }
    }
}
