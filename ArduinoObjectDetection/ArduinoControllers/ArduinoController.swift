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
        if let port = ORSSerialPort(path: "/dev/cu.usbserial-110") {
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

// Untuk wiring LED 5 buah (220 ohm resistor)
// 1. LED 1 (simulasi lampu utama)
// 2. LED 2 (simulasi lampu kamar 1)
// 3. LED 3 (simulasi lampu kamar 2)
// 4. LED 4 (simulasi lampu dapur)
// 5. LED 5 (simulasi lampu ruang belajar)

// Selenoid + Relay + Adaptor DC Power 9V 1A
