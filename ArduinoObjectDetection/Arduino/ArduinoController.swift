//
//  ArduinoController.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 03/06/25.
//

import Foundation
import ORSSerial

class ArduinoController: NSObject, ObservableObject, ORSSerialPortDelegate {
    private var serialPort : ORSSerialPort?
    
    override init() {
        super.init()
        if let port = ORSSerialPort(path: "/dev/cu.usbserial-10") {
            self.serialPort = port
            self.serialPort?.baudRate = 9600
            self.serialPort?.delegate = self
            self.serialPort?.open()
        }
    }
    
    func sendCommand(_ command: String) {
        guard let port = serialPort, port.isOpen else {
            print("Port belum terbuka.")
            return
        }

        if let data = "\(command)\n".data(using: .utf8) {
            port.send(data)
            print("Kirim: \(command)")
        }
    }

    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        self.serialPort = nil
    }
}
