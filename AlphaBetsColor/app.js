const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
let currentLetter = '';

function getRandomLetters() {
  const randomLetters = [];
  const lettersCopy = letters.slice();
  lettersCopy.splice(lettersCopy.indexOf(currentLetter), 1);
  for(let i = 0; i < 4; i++) {
    const index = Math.floor(Math.random() * lettersCopy.length);
    randomLetters.push(lettersCopy.splice(index, 1)[0]);
  }
  randomLetters.push(currentLetter);
  return shuffleArray(randomLetters);
}

function shuffleArray(array) {
  return array.sort(() => Math.random() - 0.5);
}

function playSound(letter) {
  const audio = new Audio('sounds/' + letter + '.wav');
  audio.play();
}

function playClaps() {
  const audio = new Audio('sounds/clap.wav');
  audio.play();
}

function showAnimation() {
  const display = document.getElementById('display-letter');
  display.classList.add('animate');
  setTimeout(() => {
    display.classList.remove('animate');
  }, 1000);
}

function startGame() {
  currentLetter = letters[Math.floor(Math.random() * letters.length)];
  document.getElementById('display-letter').textContent = currentLetter;
  const buttonsContainer = document.getElementById('buttons');
  buttonsContainer.innerHTML = '';
  const randomLetters = getRandomLetters();
  randomLetters.forEach(letter => {
    const button = document.createElement('div');
    button.className = 'button';
    button.textContent = letter;
    button.onclick = () => {
      playSound(letter);
      if(letter === currentLetter) {
        setTimeout(() => {
          playClaps();
          showAnimation();
        }, 500);
        setTimeout(() => {
          startGame();
        }, 2000);
      }
    };
    buttonsContainer.appendChild(button);
  });
}

window.onload = () => {
  startGame();
  if('serviceWorker' in navigator) {
    navigator.serviceWorker.register('service-worker.js');
  }
};
