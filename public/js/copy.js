var secret_link = document.getElementById('secret_link');
secret_link.dataset.clipboardText = window.location.href;

var clipboard = new ClipboardJS('#secret_link');

clipboard.on('success', function(e) {
    secret_link.innerHTML = 'copied';
    e.clearSelection();
});

clipboard.on('error', function(e) {
    secret_link.innerHTML = 'error';
});
