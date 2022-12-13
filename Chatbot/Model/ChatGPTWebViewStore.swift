import Combine
import WebKit

@dynamicMemberLookup
public class ChatGPTWebViewStore: NSObject, ObservableObject {
    public static let shared: ChatGPTWebViewStore = .init()
    @Published public var receivedMsg: String = ""
    @Published public var webView: WKWebView {
        didSet {
            setupObservers()
        }
    }
  
    override private init() {
        self.webView = WKWebView()
        super.init()
        let config = WKWebViewConfiguration()
        let userScript = WKUserScript(source: ChatGPTWebViewStore.getScript(), injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        config.userContentController.addUserScript(userScript)
        config.userContentController.add(self, name: "handler")
        let source = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        config.userContentController.add(self, name: "logHandler")
        self.webView = WKWebView(frame: .zero, configuration: config)
        self.webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.2 Mobile/15E148 Safari/604.1"
        setupObservers()
    }
    
    private static func getScript() -> String {
        if let filepath = Bundle.main.path(forResource: "script", ofType: "js") {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                print(error)
            }
        } else {
            print("script.js not found!")
        }
        return ""
    }
  
    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            return webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }
        // Setup observers for all KVO compliant properties
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward)
        ]
        if #available(iOS 15.0, macOS 12.0, *) {
            observers += [
                subscriber(for: \.themeColor),
                subscriber(for: \.underPageBackgroundColor),
                subscriber(for: \.microphoneCaptureState),
                subscriber(for: \.cameraCaptureState)
            ]
        }
#if swift(>=5.7)
        if #available(iOS 16.0, macOS 13.0, *) {
            observers.append(subscriber(for: \.fullscreenState))
        }
#else
        if #available(iOS 15.0, macOS 12.0, *) {
            observers.append(subscriber(for: \.fullscreenState))
        }
#endif
    }
  
    private var observers: [NSKeyValueObservation] = []
  
    public subscript<T>(dynamicMember keyPath: KeyPath<WKWebView, T>) -> T {
        webView[keyPath: keyPath]
    }
}

extension ChatGPTWebViewStore: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "logHandler" {
            print("LOG: \(message.body)")
        } else if message.name == "handler" {
            let msg = message.body as! [String: Any]
            debugPrint("msg:", msg["text"])
            receivedMsg = msg["text"] as! String
        }
    }
}
