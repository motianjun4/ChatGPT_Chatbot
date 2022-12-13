//
//  ModelData.swift
//  Chatbot
//
//  Created by Tianjun Mo on 2022/12/10.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    var text: String
    let isFromUser: Bool
    var isResponding: Bool = false

    init(text: String, isFromUser: Bool) {
        self.text = text
        self.isFromUser = isFromUser
    }

    init() {
        self.text = "thinking..."
        self.isFromUser = false
        self.isResponding = true
    }
}

class ModelData: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isTyping: Bool = false

    func send_stream(_ message: String) {
        // add the message to the list
        messages.append(Message(text: message, isFromUser: true))
        messages.append(Message())
        // send the message to the server

        ChatGPTAPI.shared.stream_chat(message, onDataUpdate: { data in
            let lastMsg = self.messages.last!

            DispatchQueue.main.async {
                self.messages[self.messages.count - 1].text = data
                self.messages[self.messages.count - 1].isResponding = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if self.messages.last?.text == data {
                    self.isTyping = false
                }
            }
        })
        // start typing
        isTyping = true
    }

    func createRandomTestMessages() {
        messages = [
            Message(text: "Please log in first.", isFromUser: false)
        ]
    }
}
