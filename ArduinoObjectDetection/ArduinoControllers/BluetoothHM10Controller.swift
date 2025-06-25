//
//  BluettothHM10Controller.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 08/06/25.
//

import Foundation
import CoreBluetooth

class BLEController: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var commandCharacteristic: CBCharacteristic?

    private let targetServiceUUID = CBUUID(string: "FFE0") // Service UUID HM-10
    private let targetCharacteristicUUID = CBUUID(string: "FFE1") // Char UUID HM-10

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Public
    func sendCommand(_ command: String) {
        guard let peripheral = connectedPeripheral,
              let characteristic = commandCharacteristic else {
            print("BLE belum siap")
            return
        }

        if let data = command.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            print("Kirim via BLE: \(command)")
        }
    }

    // MARK: - CoreBluetooth Delegates

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth ON, mulai scanning...")
            centralManager.scanForPeripherals(withServices: [targetServiceUUID])
        } else {
            print("Bluetooth belum aktif")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Ditemukan: \(peripheral.name ?? "Unknown")")
        centralManager.stopScan()
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Terhubung ke \(peripheral.name ?? "peripheral")")
        peripheral.discoverServices([targetServiceUUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services where service.uuid == targetServiceUUID {
                peripheral.discoverCharacteristics([targetCharacteristicUUID], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics where characteristic.uuid == targetCharacteristicUUID {
                self.commandCharacteristic = characteristic
                print("Characteristic siap dipakai")
            }
        }
    }
}
