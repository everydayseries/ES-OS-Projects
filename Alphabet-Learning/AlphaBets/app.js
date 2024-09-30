const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
let currentLetter = '';

function init() {
    displayRandomLetter();
    displayLetterButtons();
}

function displayRandomLetter() {
    currentLetter = letters[Math.floor(Math.random() * letters.length)];
    const letterDisplay = document.getElementById('letter-display');
    letterDisplay.textContent = currentLetter;
}

function displayLetterButtons() {
    const buttonsContainer = document.getElementById('buttons-container');
    buttonsContainer.innerHTML = ''; // Clear previous buttons

    const options = generateLetterOptions();
    options.forEach(letter => {
        const button = document.createElement('div');
        button.classList.add('button');
        button.textContent = letter;
        button.addEventListener('click', () => handleButtonClick(letter));
        buttonsContainer.appendChild(button);
    });
}

function generateLetterOptions() {
    const options = new Set();
    options.add(currentLetter);

    while (options.size < 5) {
        const randomLetter = letters[Math.floor(Math.random() * letters.length)];
        options.add(randomLetter);
    }

    return Array.from(options).sort(() => Math.random() - 0.5);
}

function handleButtonClick(letter) {
    playSound(`sounds/${letter}.wav`);
    if (letter === currentLetter) {
        playSound('sounds/clap.wav');
        showAnimation();
        setTimeout(init, 3000);
    }
}

function playSound(src) {
    const audio = new Audio(src);
    audio.play();
}

function showAnimation() {
    const letterDisplay = document.getElementById('letter-display');
    letterDisplay.classList.add('animate');
    setTimeout(() => {
        letterDisplay.classList.remove('animate');
    }, 1000);
}

// Initialize the app
window.onload = init;

if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        navigator.serviceWorker.register('/sw.js')
            .then(reg => console.log('Service Worker Registered'))
            .catch(err => console.log('Service Worker Registration Failed', err));
    });
}
