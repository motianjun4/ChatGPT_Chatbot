window.onerror = function (message, source, lineno, colno, error) {
  console.log(`lineno: ${lineno}, ${message}, ${source}, ${colno}, ${error}`);
};

addEventListener("load", (event) => {
  window.sendMsg = (msg) => {
    document.querySelector("textarea").value = msg;
    document.querySelector("textarea").nextSibling.click();
  };

  setTimeout(() => {
    console.log("started");
    const config = { attributes: false, childList: true, subtree: false };
    var mutations = [];
    const callback = (mutationList, observer) => {
      for (const mutation of mutationList) {
        if (mutation.type === "childList" && mutation.addedNodes.length > 0) {
          for (const node of mutation.addedNodes) {
            if (node.classList.contains("bg-gray-50")) {
                console.log("added", node);
                const getText = () => {
                    return node.innerText.trim();
                }
              mutations.push(node);
              let observer = new MutationObserver((mutations) => {
                mutations.forEach((mutation) => {
                  let text = getText();
                  if (window.webkit) {
                      let msg = {text: text};
                    window.webkit.messageHandlers.handler.postMessage(msg);
                  }
                });
              });
              observer.observe(node, { subtree: true, characterData: true });
            }
          }
        }
      }
    };
    const observer = new MutationObserver(callback);
    const targetNode = document.querySelector("main > div > div > div > div");
    observer.observe(targetNode, config);
    console.log(observer);
  }, 500);
});
