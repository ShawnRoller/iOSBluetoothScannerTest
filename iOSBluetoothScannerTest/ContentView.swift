//
//  ContentView.swift
//  iOSBluetoothScannerTest
//
//  Created by Evolve Dev on 8/8/19.
//  Copyright © 2019 Evolve Dev. All rights reserved.
//

protocol ContentDelegate {
    func bluetoothScanPressed()
    func bluetoothDisconnectPressed()
}

import SwiftUI

struct ContentView: View {
    var delegate: ContentDelegate?
    
    var body: some View {
        VStack {
            Button(action: {
                self.delegate?.bluetoothScanPressed()
            }, label: {
                Text("Scan bluetooth")
            })
            Divider()
            Button(action: {
                self.delegate?.bluetoothDisconnectPressed()
            }, label: {
                Text("Disconnect bluetooth")
            })
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
