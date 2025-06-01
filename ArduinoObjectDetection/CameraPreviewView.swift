//
//  CameraPreviewView 2.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 01/06/25.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        
        view.wantsLayer = true
        view.layer = CALayer()
        view.layer?.addSublayer(previewLayer)
        
        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
