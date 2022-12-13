//
//  ChatGPTAuth.swift
//  Chatbot
//
//  Created by Tianjun Mo on 2022/12/10.
//

import SwiftUI
import WebKit

struct ChatGPTAuth: View {
    @StateObject var webViewStore = WebViewStore()
    @Binding var isModalShow: Bool

    init(isModalShow: Binding<Bool>) {
        self._isModalShow = isModalShow
    }

    var body: some View {
        VStack {
            WebView(webView: webViewStore.webView).onAppear {
                self.webViewStore.webView.load(URLRequest(url: URL(string: "https://chat.openai.com/")!))
            }.onChange(of: self.webViewStore.webView.url?.absoluteString) { newValue in
                if newValue != "https://chat.openai.com/chat" {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.webViewStore.webView.url?.absoluteString == "https://chat.openai.com/chat" {
                        self.isModalShow = false
                    }
                }
            }
        }
    }
}

struct ChatGPTAuth_Previews: PreviewProvider {
    static var previews: some View {
        ChatGPTAuth(isModalShow: Binding(get: {
            true
        }, set: { _, _ in

        }))
    }
}
