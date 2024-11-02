// // Save items to localStorage
// function saveItems() {
//   localStorage.setItem('items', JSON.stringify(items));
// }

// // Load items from localStorage
// function loadItems() {
//   const savedItems = localStorage.getItem('items');
//   if (savedItems) {
//     items = JSON.parse(savedItems);
//   }
// }

// // Call loadItems on window.onload
// window.onload = () => {
//   loadItems();

// Define an array to hold the items (images, names, and voices)
let items = [
  {
    image: 'images/apple.png',
    name: 'Apple',
    voice: 'sounds/apple.mp3'
  },
  {
    image: 'images/banana.png',
    name: 'Banana',
    voice: 'sounds/banana.mp3'
  },
  {
    image: 'images/cherry.png',
    name: 'Cherry',
    voice: 'sounds/cherry.mp3'
  },
  {
    image: 'images/grapes.png',
    name: 'Grapes',
    voice: 'sounds/grapes.mp3'
  },
  {
    image: 'images/lemon.png',
    name: 'Lemon',
    voice: 'sounds/lemon.mp3'
  },
  {
    image: 'images/orange.png',
    name: 'Orange',
    voice: 'sounds/orange.mp3'
  },
  {
    image: 'images/pear.png',
    name: 'Pear', 
    voice: 'sounds/pear.mp3'
  },
  {
    image: 'images/pineapple.png',
    name: 'Pineapple',
    voice: 'sounds/pineapple.mp3'
  },
  {
    image: 'images/plums.png',
    name: 'Plums',
    voice: 'sounds/plums.mp3'
  },
  {
    image: 'images/strawberry.png',
    name: 'Strawberry',
    voice: 'sounds/strawberry.mp3'
  }
];




// The current item to be displayed
let currentItem = null;

// Number of images to show (default 5)
let imagesToShow = 5;

// Function to get random items excluding the current item
function getRandomItems() {
  const randomItems = [];
  const itemsCopy = items.slice();
  itemsCopy.splice(itemsCopy.indexOf(currentItem), 1);
  for (let i = 0; i < imagesToShow - 1; i++) {
    const index = Math.floor(Math.random() * itemsCopy.length);
    randomItems.push(itemsCopy.splice(index, 1)[0]);
  }
  randomItems.push(currentItem);
  return shuffleArray(randomItems);
}

// Shuffle function remains the same
function shuffleArray(array) {
  return array.sort(() => Math.random() - 0.5);
}

// Play the voice of the item
function playVoice(item) {
  const audio = new Audio(item.voice);
  audio.play();
}

// Play claps sound
function playClaps() {
  const audio = new Audio('sounds/clap.wav');
  audio.play();
}

// Show animation
function showAnimation() {
  const display = document.getElementById('display-item');
  display.classList.add('animate');
  setTimeout(() => {
    display.classList.remove('animate');
  }, 1000);
}

// Start the game
function startGame() {
  currentItem = items[Math.floor(Math.random() * items.length)];
  const display = document.getElementById('display-item');
  display.innerHTML = `<img src="${currentItem.image}" alt="${currentItem.name}">`;
  const buttonsContainer = document.getElementById('buttons');
  buttonsContainer.innerHTML = '';
  const randomItems = getRandomItems();
  randomItems.forEach(item => {
    const button = document.createElement('div');
    button.className = 'button';
    button.innerHTML = `<img src="${item.image}" alt="${item.name}">`;
    // button.innerHTML = `<p class="image-name">"${item.name}"</p>`;
    button.onclick = () => {
      playVoice(item);
      if (item === currentItem) {
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

// Handle edit mode
let isEditMode = false;

function enterEditMode() {
  const password = prompt('Enter password:');
  if (password === 'your_password') {
    isEditMode = true;
    showEditMode();
  } else {
    alert('Incorrect password');
  }
}

function showEditMode() {
  const app = document.getElementById('app');
  app.innerHTML = '';

  // Create side box for number of images to show
  const sideBox = document.createElement('div');
  sideBox.id = 'side-box';
  sideBox.innerHTML = `
    <label>Number of images to show:</label>
    <input type="number" id="imagesToShowInput" value="${imagesToShow}" min="2" max="${items.length}">
    <button id="exitEditMode">Exit Edit Mode</button>
  `;
  app.appendChild(sideBox);

  const imagesContainer = document.createElement('div');
  imagesContainer.id = 'edit-images-container';

  items.forEach((item, index) => {
    const itemDiv = document.createElement('div');
    itemDiv.className = 'edit-item';

    itemDiv.innerHTML = `
      <img src="${item.image}" alt="${item.name}">
      <input type="text" value="${item.name}" data-index="${index}" class="item-name-input">
      <button class="delete-button" data-index="${index}">X</button>
    `;

    imagesContainer.appendChild(itemDiv);
  });

  // Add the plus button
  const addItemDiv = document.createElement('div');
  addItemDiv.className = 'edit-item add-item';
  addItemDiv.innerHTML = `<span>+</span>`;
  addItemDiv.onclick = () => {
    addNewItem();
  };
  imagesContainer.appendChild(addItemDiv);

  app.appendChild(imagesContainer);

  // Event listeners for inputs and delete buttons
  document.querySelectorAll('.item-name-input').forEach(input => {
    input.addEventListener('change', (e) => {
      const index = e.target.dataset.index;
      items[index].name = e.target.value;
      saveItems();
    });
  });

  document.querySelectorAll('.delete-button').forEach(button => {
    button.addEventListener('click', (e) => {
      const index = e.target.dataset.index;
      items.splice(index, 1);
      saveItems(); // Save changes
      showEditMode(); // Refresh the edit mode
    });
  });

  // Event listener for imagesToShow input
  document.getElementById('imagesToShowInput').addEventListener('change', (e) => {
    imagesToShow = parseInt(e.target.value);
    saveSettings();
  });

  // Exit edit mode button
  document.getElementById('exitEditMode').addEventListener('click', () => {
    exitEditMode();
  });
}

function addNewItem() {
  // Create the modal overlay
  const modalOverlay = document.createElement('div');
  modalOverlay.id = 'modal-overlay';

  // Create the modal content
  const modalContent = document.createElement('div');
  modalContent.id = 'modal-content';

  modalContent.innerHTML = `
    <h2>Add New Item</h2>
    <form id="add-item-form">
      <label for="item-image">Image:</label>
      <input type="file" id="item-image" accept="image/*" required><br><br>
      <label for="item-name">Name:</label>
      <input type="text" id="item-name" required><br><br>
      <label for="item-voice">Voice:</label>
      <input type="file" id="item-voice" accept="audio/*" required><br><br>
      <button type="submit">Add Item</button>
      <button type="button" id="cancel-button">Cancel</button>
    </form>
  `;

  modalOverlay.appendChild(modalContent);
  document.body.appendChild(modalOverlay);

  // Handle form submission
  document.getElementById('add-item-form').addEventListener('submit', (e) => {
    e.preventDefault();

    const imageInput = document.getElementById('item-image');
    const nameInput = document.getElementById('item-name');
    const voiceInput = document.getElementById('item-voice');

    const imageFile = imageInput.files[0];
    const voiceFile = voiceInput.files[0];
    const name = nameInput.value.trim();

    if (imageFile && voiceFile && name) {
      const reader = new FileReader();
      reader.onload = (event) => {
        const imageUrl = event.target.result;

        const voiceReader = new FileReader();
        voiceReader.onload = (voiceEvent) => {
          const voiceUrl = voiceEvent.target.result;

          items.push({
            image: imageUrl,
            name: name,
            voice: voiceUrl
          });

          saveItems();
          closeModal();
          showEditMode();
        };
        voiceReader.readAsDataURL(voiceFile);
      };
      reader.readAsDataURL(imageFile);
    }
  });

  // Handle cancel button
  document.getElementById('cancel-button').addEventListener('click', () => {
    closeModal();
  });

  function closeModal() {
    document.body.removeChild(modalOverlay);
  }
}

// Exit edit mode
function exitEditMode() {
  isEditMode = false;
  document.getElementById('app').innerHTML = originalAppContent;
  startGame();
}

// Save items to localStorage for persistence
function saveItems() {
  localStorage.setItem('items', JSON.stringify(items));
}

// Save settings to localStorage
function saveSettings() {
  localStorage.setItem('imagesToShow', imagesToShow);
}

// Load items from localStorage
function loadItems() {
  const savedItems = localStorage.getItem('items');
  if (savedItems) {
    items = JSON.parse(savedItems);
  }
  const savedImagesToShow = localStorage.getItem('imagesToShow');
  if (savedImagesToShow) {
    imagesToShow = parseInt(savedImagesToShow);
  }
}

let originalAppContent = '';

window.onload = () => {
  originalAppContent = document.getElementById('app').innerHTML;
  loadItems();
  startGame();

  // Register service worker
  if ('serviceWorker' in navigator) {
    if (location.hostname !== 'localhost' && location.protocol === 'https:') {
      navigator.serviceWorker.register('service-worker.js');
    }
  }
  

  // Hot-key listener
  document.addEventListener('keydown', (e) => {
    if (e.key === 'E' || e.key === 'e') {
      enterEditMode();
    }
  });
};

