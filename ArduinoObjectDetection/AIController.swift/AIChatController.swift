//
//  AIChatController.swift
//  ArduinoObjectDetection
//
//  Created by Pratama One on 22/06/25.
//

import Foundation

class AIChatController: ObservableObject {
    private let apiKey = "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"
    private let model = "meta-llama/llama-4-scout-17b-16e-instruct"
    private let endpoint = "https://api.groq.com/openai/v1/chat/completions"

    func tanyaKeAI(_ prompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: endpoint) else {
            print("URL error")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    let respons = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        print("AI Jawab: \(respons)")
                        completion(respons)
                    
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("Failed to parse")
                    completion(nil)
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
