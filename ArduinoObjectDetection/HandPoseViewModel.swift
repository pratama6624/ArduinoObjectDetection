//    LED 1 -> Green D2 Telunjuk
//    LED 2 -> Yellow D3 Jari Tengah
//    LED 3 -> Red D4 Jari Manis
//    LED 4 -> Green D5 Jari Kelingking
//    LED 5 -> Yellow D6 Jempol

import Foundation
import Vision
import AVFoundation
import ORSSerial

class HandPoseViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var fingerCount: Int = 0
    @Published var boundingBox: CGRect? = nil

    private var serialPort: ORSSerialPort?
    let captureSession = AVCaptureSession()

    func startCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        captureSession.beginConfiguration()
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: .main)
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        captureSession.commitConfiguration()
        captureSession.startRunning()

        serialPort = ORSSerialPort(path: "/dev/cu.usbserial-10")
        serialPort?.baudRate = 9600
        serialPort?.open()
        print(serialPort?.isOpen == true ? "Serial open" : "Serial failed")
    }

    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial error: \(error.localizedDescription)")
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 1

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])

        guard let observation = request.results?.first else {
            DispatchQueue.main.async {
                self.boundingBox = nil
            }
            return
        }

        var count = 0
        var debugOutput: [String] = []

        if isThumbExtended(observation, debug: &debugOutput) { count += 1 }
        if isFingerExtended(observation, tip: .indexTip, pip: .indexPIP, debug: &debugOutput) { count += 1 }
        if isFingerExtended(observation, tip: .middleTip, pip: .middlePIP, debug: &debugOutput) { count += 1 }
        if isFingerExtended(observation, tip: .ringTip, pip: .ringPIP, debug: &debugOutput) { count += 1 }
        if isFingerExtended(observation, tip: .littleTip, pip: .littlePIP, debug: &debugOutput) { count += 1 }

        if let allPoints = try? observation.recognizedPoints(.all) {
            let validPoints = allPoints.values.filter { $0.confidence > 0.85 }
            let xs = validPoints.map { $0.location.x }
            let ys = validPoints.map { $0.location.y }

            if let minX = xs.min(), let maxX = xs.max(), let minY = ys.min(), let maxY = ys.max() {
                let bbox = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                DispatchQueue.main.async {
                    self.boundingBox = bbox
                }
            }
        }

        DispatchQueue.main.async {
            self.fingerCount = count
            self.sendToArduino(count)
            print("Detected \(count) fingers")
            debugOutput.forEach { print($0) }
        }
    }

    func isFingerExtended(_ observation: VNHumanHandPoseObservation,
                          tip: VNHumanHandPoseObservation.JointName,
                          pip: VNHumanHandPoseObservation.JointName,
                          debug: inout [String]) -> Bool {
        guard let tipPoint = try? observation.recognizedPoint(tip),
              let pipPoint = try? observation.recognizedPoint(pip),
              tipPoint.confidence > 0.85,
              pipPoint.confidence > 0.85 else {
            debug.append("Low confidence for \(tip.rawValue)")
            return false
        }

        debug.append("\(tip.rawValue): tip.y=\(tipPoint.location.y), pip.y=\(pipPoint.location.y)")
        return tipPoint.location.y < pipPoint.location.y
    }

    func isThumbExtended(_ observation: VNHumanHandPoseObservation, debug: inout [String]) -> Bool {
        guard let tip = try? observation.recognizedPoint(.thumbTip),
              let ip = try? observation.recognizedPoint(.thumbIP),
              tip.confidence > 0.85,
              ip.confidence > 0.85 else {
            debug.append("Low confidence for thumb")
            return false
        }

        let diffX = abs(tip.location.x - ip.location.x)
        debug.append("Thumb: tip.x=\(tip.location.x), ip.x=\(ip.location.x), diff=\(diffX)")
        return diffX > 0.07
    }

    func sendToArduino(_ count: Int) {
        guard let port = serialPort, port.isOpen else { return }
        let command = "F\(count)\n"
        port.send(command.data(using: .utf8)!)
    }

    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print(granted ? "Akses kamera OK" : "Akses kamera DITOLAK")
        }
    }
}
