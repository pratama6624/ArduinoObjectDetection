//
//  SRTEntry.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 07/06/25.
//

//import Foundation
//import AVFoundation
//
//struct SRTEntry {
//    let index: Int
//    let startTime: TimeInterval
//    let endTime: TimeInterval
//    let text: String
//}
//
//func parseSRTTime(_ timeString: String) -> TimeInterval {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "HH:mm:ss,SSS"
//    guard let date = formatter.date(from: timeString) else { return 0 }
//    let calendar = Calendar.current
//    let comps = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
//    let seconds = (Double(comps.hour ?? 0) * 3600 +
//                   Double(comps.minute ?? 0) * 60 +
//                   Double(comps.second ?? 0) +
//                   Double(comps.nanosecond ?? 0) / 1_000_000_000)
//    return seconds
//}
//
//func parseSRT(filePath: String) -> [SRTEntry] {
//    guard let content = try? String(contentsOfFile: filePath, encoding: .utf8) else { return [] }
//    let blocks = content.components(separatedBy: "\n\n")
//    var results: [SRTEntry] = []
//
//    for block in blocks {
//        let lines = block.components(separatedBy: .newlines).filter { !$0.isEmpty }
//        guard lines.count >= 3,
//              let index = Int(lines[0]) else { continue }
//
//        let timeParts = lines[1].components(separatedBy: " --> ")
//        guard timeParts.count == 2 else { continue }
//
//        let start = parseSRTTime(timeParts[0])
//        let end = parseSRTTime(timeParts[1])
//        let text = lines.dropFirst(2).joined(separator: " ")
//
//        results.append(SRTEntry(index: index, startTime: start, endTime: end, text: text))
//    }
//
//    return results
//}
//
//func cutAudio(inputURL: URL, entries: [SRTEntry], outputDir: URL) async {
//    let asset = AVURLAsset(url: inputURL)
//
//    for entry in entries {
//        let start = CMTime(seconds: entry.startTime, preferredTimescale: 600)
//        let duration = CMTime(seconds: entry.endTime - entry.startTime, preferredTimescale: 600)
//        let timeRange = CMTimeRange(start: start, duration: duration)
//
//        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
//            print("[✗] Export session creation failed for clip \(entry.index)")
//            continue
//        }
//
//        exportSession.timeRange = timeRange
//        exportSession.outputFileType = .wav
//
//        let outputURL = outputDir.appendingPathComponent("myvoice\(String(format: "%03d", entry.index)).wav")
//        exportSession.outputURL = outputURL
//
//        do {
//            try await exportSession.export(to: outputURL, as: .wav)
//            print("[✓] Clip \(entry.index) saved: \(entry.text)")
//        } catch {
//            print("[✗] Clip \(entry.index) failed: \(error.localizedDescription)")
//        }
//    }
//}
//
//@main
//struct AudioClipperApp {
//    static func main() async {
//        let currentPath = FileManager.default.currentDirectoryPath
//
//        let inputAudioURL = URL(fileURLWithPath: currentPath).appendingPathComponent("myvoiceinput.wav")
//        let srtPath = URL(fileURLWithPath: currentPath).appendingPathComponent("myvoiceinput.srt").path
//        let outputDir = URL(fileURLWithPath: currentPath).appendingPathComponent("output_audio_my_voice")
//
//        try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
//
//        let entries = parseSRT(filePath: srtPath)
//        await cutAudio(inputURL: inputAudioURL, entries: entries, outputDir: outputDir)
//    }
//}
