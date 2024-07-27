let isPrettified = false;

const observer = new MutationObserver(() => {
  const tabs = document.querySelector(".tabs");
  const footer = document.querySelector(".split-view-view .statusbar");

  if (!isPrettified && (window.screenY > 0 || window.screenX > 0)) {
    window.resizeTo(window.screen.availWidth - 200, window.screen.availHeight - 100);
    window.moveTo(100, 50);

    if (tabs) {
      tabs.style.opacity = "0";
      tabs.style.height = "20px";
    }

    if (footer) {
      footer.style.opacity = "0";
    }

    isPrettified = true;
  }

  if (isPrettified && window.screenY === 0 && window.screenX === 0) {
    if (tabs) {
      tabs.style.opacity = "1";
      tabs.style.height = "28px";
    }

    if (footer) {
      footer.style.opacity = "1";
    }

    isPrettified = false;
  }
});

observer.observe(document, { childList: true, subtree: true });
