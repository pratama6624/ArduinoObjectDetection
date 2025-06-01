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
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
