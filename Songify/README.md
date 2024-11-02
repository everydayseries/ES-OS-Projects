🎵 Song Recommendation System 🎧
================================

📖 Introduction
---------------

Welcome to the Song Recommendation System! This project combines the power of Last.fm's track data with Spotify's audio features to provide personalized song recommendations. Whether you're looking to discover new music or find songs similar to your favorites, this system has got you covered! 🚀

🛠️ How It Works
----------------

1.  🔍 **Song Database**: We fetch popular tracks from Last.fm and enrich them with audio features from Spotify.
2.  🧠 **Recommendation Engine**: Using machine learning techniques, we analyze song similarities based on their audio features.
3.  🎯 **Personalized Suggestions**: Enter a song you like, and get recommendations for similar tracks!
4.  🔄 **Always Up-to-Date**: Easily update the song database with the latest tracks from Last.fm.

🚀 Features
-----------

-   🔎 Fuzzy search: Find songs even with partial or slightly misspelled names.
-   🎶 Spotify Integration: Listen to recommended songs directly on Spotify.
-   📊 Similarity Scores: See how closely each recommendation matches your input.
-   🔄 Real-time Updates: Refresh the song database with current popular tracks.

🏗️ Project Structure
---------------------

-   `backend/`: Python Flask server
    -   `app.py`: Main server file
    -   `update_songs.py`: Script to update the song database
    -   `songs.csv`: Database of songs with audio features
-   `frontend/`: React application
    -   `src/App.jsx`: Main React component

🖥️ User Guide
--------------

### Getting Started

1.  Clone the repository
2.  Set up your Last.fm and Spotify API credentials in `backend/.env`
3.  Install dependencies:

    bash

    Copy code

    `cd backend && pip install -r requirements.txt
    cd ../frontend && npm install`

4.  Start the servers:

    bash

    Copy code

    `cd ../backend && python3 app.py &
    cd ../frontend && npm run dev`

### Using the Application

1.  🎵 **Enter a Song**: Type a song name in the search box. The system supports partial matching!
2.  🔍 **Get Recommendations**: Click "Get Recommendations" to see similar songs.
3.  🎧 **Listen to Songs**: Click "Play on Spotify" next to any recommendation to listen on Spotify.
4.  🔄 **Update Song Database**: Click "Update Songs" to refresh the database with the latest tracks.

🛠️ Technical Details
---------------------

-   Backend: Python Flask
-   Frontend: React with Tailwind CSS
-   APIs: Last.fm (track data), Spotify (audio features)
-   Machine Learning: Cosine similarity for song matching

🚨 Risks and Disclaimer
-----------------------

### Risks

-   **Data Accuracy**: Song recommendations are based on data from Last.fm and Spotify, which may not always reflect current trends, tastes, or the latest releases.
-   **API Limits**: The application relies on third-party APIs (Spotify and Last.fm), which may impose rate limits or change their data policies. This may impact the availability of features if limits are reached.
-   **Personal Data**: While this system does not collect personal data, users interacting with the Spotify API may be subject to Spotify's data privacy policies. Ensure compliance with these policies when using Spotify services.

### Disclaimer

This recommendation system is provided as-is, for educational and personal use only. The creators of this system are not responsible for any issues, losses, or unintended outcomes from using the application. The use of third-party APIs is governed by their respective terms and conditions. Be mindful of any restrictions or usage policies associated with Spotify and Last.fm when using this system.

🤝 Contributing
---------------

We welcome contributions! Feel free to submit issues or pull requests if you have ideas for improvements or new features.

📜 License
----------

This project is licensed under the MIT License. See the LICENSE file for details.

🙏 Acknowledgements
-------------------

-   Last.fm for providing track data
-   Spotify for audio features
-   All the awesome open-source libraries we've used!

Enjoy discovering new music! 🎶🕺💃
