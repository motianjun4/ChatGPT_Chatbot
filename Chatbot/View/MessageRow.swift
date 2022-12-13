//
//  MessageRow.swift
//  Chatbot
//
//  Created by Tianjun Mo on 2022/12/10.
//

import SwiftUI

struct MessageRow: View {
    var message: Message
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
            } else {
                Text(message.text).italic(message.isResponding)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                Spacer()
            }
        }
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageRow(message: Message())
            MessageRow(message: Message(text: "Hello", isFromUser: true))
            MessageRow(message: Message(text: "Hi", isFromUser: false))
        }
    }
}
