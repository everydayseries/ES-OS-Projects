import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [inputSong, setInputSong] = useState('');
  const [recommendations, setRecommendations] = useState([]);
  const [error, setError] = useState('');
  const [songs, setSongs] = useState([]);
  const [isUpdating, setIsUpdating] = useState(false);
  const [updateMessage, setUpdateMessage] = useState('');

  useEffect(() => {
    fetchSongs();
  }, []);

  const fetchSongs = async () => {
    try {
      const response = await axios.get('http://localhost:5000/songs');
      setSongs(response.data);
    } catch (err) {
      console.error('Error fetching songs:', err);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const response = await axios.post('http://localhost:5000/recommend', { song: inputSong });
      setRecommendations(response.data);
    } catch (err) {
      setError('Error: Song not found or unable to get recommendations');
    }
  };

  const handleUpdateSongs = async () => {
    setIsUpdating(true);
    setUpdateMessage('');
    try {
      const response = await axios.post('http://localhost:5000/update_songs');
      setUpdateMessage(response.data.message);
      fetchSongs();  // Refresh the song list
    } catch (err) {
      setUpdateMessage('Error: Failed to update songs');
    } finally {
      setIsUpdating(false);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-8 text-center text-blue-600">Song Recommendation System</h1>
      <div className="mb-8 flex justify-between items-center">
        <form onSubmit={handleSubmit} className="flex-grow mr-4">
          <div className="flex">
            <input
              list="songs"
              type="text"
              value={inputSong}
              onChange={(e) => setInputSong(e.target.value)}
              placeholder="Enter a song name"
              className="flex-grow px-4 py-2 rounded-l-lg border-t border-b border-l text-gray-800 border-gray-200 bg-white"
            />
            <datalist id="songs">
              {songs.map((song, index) => (
                <option key={index} value={song} />
              ))}
            </datalist>
            <button type="submit" className="px-4 py-2 rounded-r-lg bg-blue-500 text-white font-semibold hover:bg-blue-600">
              Get Recommendations
            </button>
          </div>
        </form>
        <button
          onClick={handleUpdateSongs}
          disabled={isUpdating}
          className="px-4 py-2 rounded-lg bg-green-500 text-white font-semibold hover:bg-green-600 disabled:bg-gray-400"
        >
          {isUpdating ? 'Updating...' : 'Update Songs'}
        </button>
      </div>
      {updateMessage && (
        <p className={`mb-4 ${updateMessage.includes('Error') ? 'text-red-500' : 'text-green-500'}`}>
          {updateMessage}
        </p>
      )}
      {error && <p className="text-red-500 mb-4">{error}</p>}
      {recommendations.length > 0 && (
        <div>
          <h2 className="text-2xl font-semibold mb-4">Recommended Songs:</h2>
          <ul className="bg-white rounded-lg shadow-md">
            {recommendations.map((song, index) => (
              <li key={index} className="px-6 py-4 border-b border-gray-200 last:border-b-0 flex justify-between items-center">
                <div>
                  <span className="font-semibold">{song.name}</span> by {song.artist}
                  {song.spotify_link && (
                    <a
                      href={song.spotify_link}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="ml-2 text-green-500 hover:text-green-700"
                    >
                      Play on Spotify
                    </a>
                  )}
                </div>
                <div className="text-sm text-gray-600">
                  Similarity: {song.similarity}%
                </div>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

export default App;
