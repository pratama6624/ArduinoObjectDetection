//
//  SRTEntry.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 07/06/25.
//

import Foundation

// You can create SRT file from wav audio file with tool like turbo script

struct SRTEntry {
    let index: Int
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
}
