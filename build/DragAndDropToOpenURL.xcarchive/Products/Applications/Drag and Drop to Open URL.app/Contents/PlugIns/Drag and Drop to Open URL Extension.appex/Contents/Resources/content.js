document.addEventListener('dragstart', function(event) {
  // Store the link being dragged
  if (event.target.tagName === 'A') {
    event.dataTransfer.setData('text/plain', event.target.href);
  }
});

document.addEventListener('drop', function(event) {
  event.preventDefault();
  const url = event.dataTransfer.getData('text/plain');
  if (url) {
    // Send a message to the background script to open the URL in a new tab
    chrome.runtime.sendMessage({ action: 'openInBackground', url: url });
  }
});

document.addEventListener('dragover', function(event) {
  event.preventDefault();
});
