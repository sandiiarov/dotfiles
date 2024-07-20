const observer = new MutationObserver(() => {
  if (document.title === "lazygit") {
    window.resizeTo(window.screen.availWidth - 200, window.screen.availHeight - 100);
    window.moveTo(100, 50);

    const tabs = document.querySelector(".tabs");
    if (tabs) {
      tabs.style.opacity = "0";
      tabs.style.height = "20px";
    }

    const footer = document.querySelector(".split-view-view .statusbar");
    if (footer) {
      footer.style.opacity = "0";
    }
  }
});

observer.observe(document, { childList: true, subtree: true });
