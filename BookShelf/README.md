# 📚 Bookshelf App

Welcome to the **Bookshelf App**! This application allows you to manage a collection of books, view or edit their summaries, and search through your collection easily. Perfect for book lovers! 🌟

---

## ✨ Features

- **📖 Add New Books:** Easily add new books to your collection.
- **🔍 Search Functionality:** Find books by title, author, or genre using the search bar.
- **📝 Edit Summaries:** Edit or add custom summaries for your favorite books.
- **📂 Local Storage:** All data is saved to your browser's local storage, so your collection persists between sessions.
- **⏪ Undo Deletion:** Accidentally deleted a book? Undo it within 10 seconds!
- **🌐 Fetch Summaries:** Automatically fetch book summaries from a backend API.

---

## 🛠️ How to Use

1. **View Books:**
   - Your books are displayed in the bookshelf on the main page.
2. **Add a Book:**
   - Click the "Add Book" button, fill in the form, and hit "Save".
3. **Remove a Book:**
   - Click the ❌ button on a book to remove it. Use the undo button if needed.
4. **Fetch Summaries:**
   - Click "Summary" to fetch a book's summary. If unavailable, you'll see a placeholder message.
5. **Edit Summaries:**
   - Click ✏️ to edit the summary of a book.
6. **Search:**
   - Use the search bar to find books by title, author, or genre.

---

## 🛑 Disclaimers and Risks

⚠️ **API Dependency:** Summaries are fetched from an external API. Ensure the backend service is running on `http://127.0.0.1:5000/summary` for this feature to work.

⚠️ **Local Storage Limitations:** Data is stored locally in your browser. Clearing your browser cache or switching devices will erase your collection.

⚠️ **No Authentication:** This app does not support user accounts. Anyone accessing the browser can modify the bookshelf.

⚠️ **Timeout for Undo:** You have only 10 seconds to undo a deleted book. After that, it's permanently removed.

---

## 🧩 File Structure

- **index.html:** The main interface for the Bookshelf App.
- **style.css:** Styles for the application.
- **app.js:** All JavaScript functionality, including book management, search, and summaries.

---

## 🚀 Getting Started

1. Clone or download the repository.
2. Open `index.html` in a modern browser.
3. Start managing your book collection!

For fetching summaries, ensure you have a backend service running at `http://127.0.0.1:5000/summary`.

---

## 🧑‍💻 Contributing

Feel free to fork this project and submit pull requests! Let's make this app even better for book lovers everywhere. 🌍

---

## 🐛 Known Issues

- **Network Errors:** Summary fetch may fail if the backend is unavailable.
- **Undo Timer:** Cannot extend the 10-second undo timer once it's started.
- **Limited Storage:** Local storage may run out of space for very large collections.

---

## 💡 Future Enhancements

- Add user accounts for multiple collections.
- Enable cloud syncing for collections.
- Improve error handling for summary fetches.
- Add customizable genres.

---

Enjoy your journey of literary exploration! 📚✨
