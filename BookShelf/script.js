let books = JSON.parse(localStorage.getItem("books")) || []; // Load books from localStorage
let summaries = JSON.parse(localStorage.getItem("summaries")) || {}; // Load summaries from localStorage
let removedBook = null; // Temporary storage for removed book
let undoTimeout = null; // Timeout for undo operation

// Preload sample books
if (books.length === 0) {
  books = [
    { title: "1984", author: "George Orwell", genre: "Dystopian Fiction" },
    {
      title: "To Kill a Mockingbird",
      author: "Harper Lee",
      genre: "Classic Fiction",
    },
    {
      title: "The Great Gatsby",
      author: "F. Scott Fitzgerald",
      genre: "Classic Fiction",
    },
    { title: "Pride and Prejudice", author: "Jane Austen", genre: "Romance" },
    {
      title: "The Catcher in the Rye",
      author: "J.D. Salinger",
      genre: "Classic Fiction",
    },
  ];
  localStorage.setItem("books", JSON.stringify(books)); // Save to localStorage
}

// Display the books in the bookshelf
function displayBooks(filteredBooks = books) {
  const bookshelf = document.getElementById("bookshelf");
  bookshelf.innerHTML = "";
  filteredBooks.forEach((book, index) => {
    const bookDiv = document.createElement("div");
    bookDiv.className = "book";
    bookDiv.innerHTML = `
      <button class="removeBtn" onclick="removeBook(${index})">&times;</button>
      <h3>${book.title}</h3>
      <p>Author: ${book.author}</p>
      <p>Genre: ${book.genre}</p>
      <div>
        <button class="summaryBtn" onclick="getSummary(${index})">Summary</button>
        <button class="editSummaryBtn" onclick="editSummary(${index})">
          &#9998;
        </button>
      </div>
    `;
    bookshelf.appendChild(bookDiv);
  });

  // Show or hide the Undo option
  const undoContainer = document.getElementById("undoContainer");
  undoContainer.style.display = removedBook ? "block" : "none";
}

// Add a new book to the collection
document.getElementById("saveBookBtn").addEventListener("click", () => {
  const title = document.getElementById("title").value;
  const author = document.getElementById("author").value;
  const genre = document.getElementById("genre").value;

  if (title && author && genre) {
    const newBook = { title, author, genre };
    books.push(newBook);
    localStorage.setItem("books", JSON.stringify(books)); // Save to localStorage
    displayBooks();
    document.getElementById("addBookForm").style.display = "none";
    document.getElementById("title").value = "";
    document.getElementById("author").value = "";
    document.getElementById("genre").value = "";
  }
});

// Show the "Add Book" form
document.getElementById("addBookBtn").addEventListener("click", () => {
  document.getElementById("addBookForm").style.display = "block";
});

// Hide the "Add Book" form
document.getElementById("cancelBtn").addEventListener("click", () => {
  document.getElementById("addBookForm").style.display = "none";
});

// Remove a book by index
function removeBook(index) {
  // Temporarily store the removed book
  removedBook = books.splice(index, 1)[0];
  localStorage.setItem("books", JSON.stringify(books)); // Update localStorage
  displayBooks(); // Refresh the display

  // Set a 10-second timeout to clear the undo option
  clearTimeout(undoTimeout);
  undoTimeout = setTimeout(() => {
    removedBook = null;
    displayBooks(); // Refresh the display to hide Undo
  }, 10000);
}

// Undo the removal of a book
document.getElementById("undoBtn").addEventListener("click", () => {
  if (removedBook) {
    books.push(removedBook); // Restore the removed book
    removedBook = null; // Clear temporary storage
    localStorage.setItem("books", JSON.stringify(books)); // Update localStorage
    displayBooks();
    clearTimeout(undoTimeout); // Clear the timeout
  }
});

// Fetch or show stored summary
async function getSummary(index) {
  const book = books[index];
  const summaryModal = document.getElementById("summaryModal");
  const summaryText = document.getElementById("summaryText");
  summaryModal.style.display = "block";

  // Check if the summary already exists
  if (summaries[book.title]) {
    summaryText.textContent = summaries[book.title];
    return;
  }

  // Fetch summary from the backend
  summaryText.textContent = "Fetching summary...";
  const apiEndpoint = "http://127.0.0.1:5000/summary";
  try {
    const response = await fetch(apiEndpoint, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        title: book.title,
        author: book.author,
        genre: book.genre,
      }),
    });

    if (!response.ok) {
      throw new Error("Network response was not ok");
    }

    const data = await response.json();
    const summary = data.summary || "No summary available.";
    summaries[book.title] = summary; // Save the summary
    localStorage.setItem("summaries", JSON.stringify(summaries)); // Save to localStorage
    summaryText.textContent = summary;
  } catch (error) {
    summaryText.textContent =
      "Failed to fetch the summary. Please try again later.";
    console.error("Error fetching summary:", error);
  }
}

// Edit a summary
function editSummary(index) {
  const book = books[index];
  const newSummary = prompt(
    `Edit the summary for "${book.title}":`,
    summaries[book.title] || "",
  );
  if (newSummary) {
    summaries[book.title] = newSummary; // Update the summary
    localStorage.setItem("summaries", JSON.stringify(summaries)); // Save to localStorage
  }
}

// Search functionality
document.getElementById("searchBar").addEventListener("input", (e) => {
  const query = e.target.value.toLowerCase();
  const filteredBooks = books.filter(
    (book) =>
      book.title.toLowerCase().includes(query) ||
      book.author.toLowerCase().includes(query) ||
      book.genre.toLowerCase().includes(query),
  );
  displayBooks(filteredBooks); // Display filtered books
});

// Close the summary modal
document.getElementById("closeSummaryBtn").addEventListener("click", () => {
  document.getElementById("summaryModal").style.display = "none";
});

// Display books on page load
displayBooks();
