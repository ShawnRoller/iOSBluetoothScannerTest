//
//  SceneDelegate.swift
//  iOSBluetoothScannerTest
//
//  Created by Evolve Dev on 8/8/19.
//  Copyright © 2019 Evolve Dev. All rights reserved.
//

import UIKit
import SwiftUI
import CoreBluetooth

class SceneDelegate: UIResponder, UIWindowSceneDelegate, ContentDelegate {

    var window: UIWindow?
    
    // Bluetooth
    let scannerCBUUID = CBUUID(string: "0x1812")
    var centralManager: CBCentralManager!
    var scannerPeripheral: CBPeripheral!
    var peripheralManager: CBPeripheralManager!


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView(delegate: self))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        self.setupBluetooth()
    }
    
    func bluetoothScanPressed() {
        print("scan pressed")
        self.scanForPeripherals()
    }
    
    func bluetoothDisconnectPressed() {
        print("disconnect pressed")
        self.centralManager.cancelPeripheralConnection(self.scannerPeripheral)
    }


}

// MARK: - Bluetooth
extension SceneDelegate: CBCentralManagerDelegate {

    func setupBluetooth() {

        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralManager = CBPeripheralManager.init(delegate: self, queue: DispatchQueue.main )

    }

    func scanForPeripherals() {

//        self.centralManager.scanForPeripherals(withServices: [self.scannerCBUUID])
        self.centralManager.scanForPeripherals(withServices: nil)

    }

    private func scan(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value else { return "" }
        let byteArray = [UInt8](characteristicData)

        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
//            return byteArray[1]
        } else {
//            return byteArray[1] << 8 + byteArray[2]
        }
        return ""
    }

    private func onScanReceived(_ scan: String) {
        print("Scanned: \(scan)")
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
            case .unknown:
                print("central.state is .unknown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredOff")
            case .poweredOn:
                print("central.state is .poweredOn")
            default:
                ()
        }

    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        central.cancelPeripheralConnection(peripheral)
        
        if peripheral.name ?? "" == "KDC280[000023]" {
            print(peripheral)
            print(peripheral.services as Any)
            print(advertisementData)
            print(RSSI)
            
            self.setupPeripheral(peripheral)
        }
    }

    func setupPeripheral(_ peripheral: CBPeripheral) {
        self.scannerPeripheral = peripheral
        self.scannerPeripheral.delegate = self
        self.centralManager.stopScan()
        self.centralManager.connect(self.scannerPeripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected!")
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
    }
    
}

extension SceneDelegate: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
//        self.testPeripheral(characteristics: characteristics)
        
        for characteristic in characteristics {
            print(characteristic)
            
            

            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid) containes read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid) containes notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func testPeripheral(characteristics: [CBCharacteristic]) {
        let value = 1234
        let data = withUnsafeBytes(of: value) { Data($0) }
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                self.scannerPeripheral.setNotifyValue(true, for: characteristic)
                self.scannerPeripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
            case self.scannerCBUUID:
                let scan = self.scan(from: characteristic)
                self.onScanReceived(scan)
                print(characteristic.value ?? "no value")
            default:
                print("unhandled characteristic, UUID: \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        
    }

}

extension SceneDelegate: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
}
