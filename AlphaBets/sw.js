const cacheName = 'alphabet-app-v1';
const assets = [
    '/',
    '/index.html',
    '/styles.css',
    '/app.js',
    '/manifest.json',
    // Include all sound files and icons
    // Example:
    '/sounds/A.mp3',
    '/sounds/B.mp3',
    // ...
    '/sounds/clap.mp3',
    '/icons/icon-192.png',
    '/icons/icon-512.png'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(cacheName).then(cache => {
            return cache.addAll(assets);
        })
    );
});

self.addEventListener('fetch', event => {
    event.respondWith(
        caches.match(event.request).then(response => {
            return response || fetch(event.request);
        })
    );
});
