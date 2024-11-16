// Get canvas and context
const canvas = document.getElementById("gameCanvas");
const ctx = canvas.getContext("2d");

// Game settings
const gridSize = 20;
let snake = [{ x: gridSize * 5, y: gridSize * 5 }];
let food = getRandomFoodPosition();
let dx = gridSize;
let dy = 0;
let score = 0;
let gameOver = false;
let gamePaused = false;
let playerName = "";
let gameSpeed = 100;
let isFast = false;

// Customization settings
const snakeColorInput = document.getElementById("snakeColor");
const foodColorInput = document.getElementById("foodColor");
const snakeShapeInput = document.getElementById("snakeShape");

// Start and restart buttons
const startButton = document.getElementById("startButton");
const restartButton = document.getElementById("restartButton");
const speedButton = document.getElementById("speedButton");
const resetLeaderboardButton = document.getElementById(
  "resetLeaderboardButton",
);
const confettiElement = document.getElementById("confetti");

// Leaderboard
let leaderboard = JSON.parse(localStorage.getItem("leaderboard")) || [];

// Game loop interval
let gameInterval;

// Start the game
function startGame() {
  const nameInput = document.getElementById("playerName").value.trim();
  if (!nameInput) {
    alert("Please enter your name.");
    return;
  }
  playerName = nameInput;
  score = 0;
  gameOver = false;
  gamePaused = false;
  snake = [{ x: gridSize * 5, y: gridSize * 5 }];
  dx = gridSize;
  dy = 0;
  food = getRandomFoodPosition();
  startButton.style.display = "none";
  restartButton.style.display = "inline-block";
  startGameLoop();
  displayLeaderboard();
}

function startGameLoop() {
  clearInterval(gameInterval);
  gameInterval = setInterval(gameLoop, gameSpeed);
}

function toggleSpeed() {
  isFast = !isFast;
  gameSpeed = isFast ? 50 : 100;
  speedButton.textContent = `Speed: ${isFast ? "Fast" : "Normal"}`;
  startGameLoop();
}

function gameLoop() {
  if (gameOver || gamePaused) return;

  moveSnake();
  checkCollisions();
  drawGame();
}

function moveSnake() {
  const head = { x: snake[0].x + dx, y: snake[0].y + dy };
  snake.unshift(head);

  if (head.x === food.x && head.y === food.y) {
    score += 1;
    food = getRandomFoodPosition();
    updateLeaderboard(); // Update leaderboard with real-time score
    displayLeaderboard();
  } else {
    snake.pop();
  }
}

function changeDirection(direction) {
  const LEFT = "left",
    UP = "up",
    RIGHT = "right",
    DOWN = "down";
  if (direction === LEFT && dx === 0) {
    dx = -gridSize;
    dy = 0;
  } else if (direction === UP && dy === 0) {
    dx = 0;
    dy = -gridSize;
  } else if (direction === RIGHT && dx === 0) {
    dx = gridSize;
    dy = 0;
  } else if (direction === DOWN && dy === 0) {
    dx = 0;
    dy = gridSize;
  }
}

document.addEventListener("keydown", (event) => {
  const direction = event.key.replace("Arrow", "").toLowerCase();
  changeDirection(direction);

  // Pause the game with "P" key
  if (event.key.toLowerCase() === "p") togglePause();
});

function togglePause() {
  gamePaused = !gamePaused;
  if (!gamePaused) {
    startGameLoop();
  }
}

function checkCollisions() {
  const head = snake[0];
  if (
    head.x < 0 ||
    head.y < 0 ||
    head.x >= canvas.width ||
    head.y >= canvas.height ||
    snake
      .slice(1)
      .some((segment) => segment.x === head.x && segment.y === head.y)
  ) {
    gameOver = true;
    clearInterval(gameInterval);
    updateLeaderboard();
    displayLeaderboard();
    checkForConfetti(); // Check if confetti should be shown
  }
}

function drawGame() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Draw snake
  ctx.fillStyle = snakeColorInput.value;
  snake.forEach((segment) => {
    if (snakeShapeInput.value === "circle") {
      ctx.beginPath();
      ctx.arc(
        segment.x + gridSize / 2,
        segment.y + gridSize / 2,
        gridSize / 2,
        0,
        Math.PI * 2,
      );
      ctx.fill();
    } else {
      ctx.fillRect(segment.x, segment.y, gridSize, gridSize);
    }
  });

  // Draw food
  ctx.fillStyle = foodColorInput.value;
  ctx.fillRect(food.x, food.y, gridSize, gridSize);

  // Display score on canvas
  ctx.fillStyle = "black";
  ctx.font = "16px Arial";
  ctx.fillText(`Score: ${score}`, 10, 20);

  if (gameOver) {
    ctx.font = "30px Arial";
    ctx.fillText("Game Over", canvas.width / 4, canvas.height / 2);
    ctx.font = "16px Arial";
    ctx.fillText(
      "Press 'Restart Game' to play again",
      canvas.width / 8,
      canvas.height / 2 + 30,
    );
  }
}

function getRandomFoodPosition() {
  return {
    x: Math.floor(Math.random() * (canvas.width / gridSize)) * gridSize,
    y: Math.floor(Math.random() * (canvas.height / gridSize)) * gridSize,
  };
}

function restartGame() {
  clearInterval(gameInterval);
  startGame();
}

function updateLeaderboard() {
  const existingPlayer = leaderboard.find((entry) => entry.name === playerName);
  if (existingPlayer) {
    if (score > existingPlayer.score) {
      existingPlayer.score = score;
      checkForConfetti();
    }
  } else {
    leaderboard.push({ name: playerName, score });
    checkForConfetti();
  }
  leaderboard.sort((a, b) => b.score - a.score);
  leaderboard = leaderboard.slice(0, 5);
  localStorage.setItem("leaderboard", JSON.stringify(leaderboard));
}

function displayLeaderboard() {
  const leaderboardBody = document.getElementById("leaderboardBody");
  leaderboardBody.innerHTML = "";
  leaderboard.forEach((entry, index) => {
    const row = document.createElement("tr");
    row.innerHTML = `<td>${index + 1}</td><td>${entry.name}</td><td>${entry.name === playerName ? score : entry.score}</td>`;
    leaderboardBody.appendChild(row);
  });
}

function checkForConfetti() {
  if (
    leaderboard[0] &&
    leaderboard[0].name === playerName &&
    leaderboard[0].score === score
  ) {
    showConfetti();
  }
}

function showConfetti() {
  confettiElement.style.display = "block";
  setTimeout(() => {
    confettiElement.style.display = "none";
  }, 2000);
}

function resetLeaderboard() {
  leaderboard = [];
  localStorage.setItem("leaderboard", JSON.stringify(leaderboard));
  displayLeaderboard();
}

// Display leaderboard initially
displayLeaderboard();
