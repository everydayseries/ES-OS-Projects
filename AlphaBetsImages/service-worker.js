self.addEventListener('install', e => {
  e.waitUntil(
    caches.open('alphabet-app').then(cache => {
      return cache.addAll([
        './',
        './index.html',
        './style.css',
        './app.js',
        './manifest.json',
        './icon-192.png',
        './icon-512.png',
        // Add sounds and other assets here
      ]);
    })
  );
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(response => {
      return response || fetch(e.request);
    })
  );
});
