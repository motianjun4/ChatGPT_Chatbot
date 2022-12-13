//
//  Chat.swift
//  Chatbot
//
//  Created by Tianjun Mo on 2022/12/10.
//

import SwiftUI

struct Chat: View {
    @StateObject var modelData = ModelData()
    @State var messageInput: String = ""
    @State var showModal: Bool = false
    @Namespace var bottomID
    var body: some View {
        VStack {
            ZStack {
                ChatGPTPage().blur(radius: 1).opacity(0.1)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(modelData.messages) { message in
                                MessageRow(message: message)
                            }
                            Spacer().id(bottomID)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .onChange(of: modelData.messages.last?.text) { _ in
                        proxy.scrollTo(bottomID)
                    }
                }
            }
            HStack {
                TextField("Type a message...", text: $messageInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 10)
                Button(action: {
                    modelData.send_stream(messageInput)
                    messageInput = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(messageInput.isEmpty)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            if modelData.isTyping {
                HStack {
                    Spacer()
                    Text("Chatbot is typing...")
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                }
            }
        }
        .sheet(isPresented: $showModal, content: {
            ChatGPTAuth(isModalShow: $showModal)
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Log in") {
                    showModal = true
                }
            }
        }
        .navigationTitle("Chatbot").navigationBarTitleDisplayMode(.inline)

        .onAppear {
            modelData.createRandomTestMessages()
            _ = ChatGPTAPI.shared
        }.task(id: showModal) {
            if showModal == false {
                ChatGPTWebViewStore.shared.webView.load(URLRequest(url: URL(string: "https://chat.openai.com/")!))
            }
        }
    }

    // scroll to the bottom of the scroll view
    func scrollToBottom() {
        withAnimation {
            if modelData.messages.count > 0 {
                let lastIndex = modelData.messages.count - 1
                let lastMessage = modelData.messages[lastIndex]
                let lastMessageId = lastMessage.id
                let lastMessageIndex = modelData.messages.firstIndex(where: { $0.id == lastMessageId })
                if let lastMessageIndex = lastMessageIndex {
                    let lastMessageOffset = CGFloat(lastMessageIndex) * 100
                    let maxOffset = UIScreen.main.bounds.height * 2
                    if lastMessageOffset < maxOffset {
                        let offset = CGPoint(x: 0, y: lastMessageOffset)
                        UIScrollView.appearance().setContentOffset(offset, animated: true)
                    }
                }
            }
        }
    }
}

struct Chat_Previews: PreviewProvider {
    static var previews: some View {
        Chat()
    }
}
