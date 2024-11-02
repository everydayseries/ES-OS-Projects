from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import MinMaxScaler
from fuzzywuzzy import process
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import os
from dotenv import load_dotenv
import subprocess

load_dotenv()

app = Flask(__name__)
CORS(app)

# Spotify API credentials
SPOTIFY_CLIENT_ID = os.getenv("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.getenv("SPOTIFY_CLIENT_SECRET")

# Initialize Spotify client
sp = spotipy.Spotify(auth_manager=SpotifyClientCredentials(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET))

# Load and preprocess the dataset
def load_songs():
    global songs
    songs = pd.read_csv('songs.csv')
    features = ['danceability', 'energy', 'key', 'loudness', 'mode', 'speechiness', 'acousticness', 'instrumentalness', 'liveness', 'valence', 'tempo']
    scaler = MinMaxScaler()
    songs[features] = scaler.fit_transform(songs[features])

load_songs()

def get_spotify_link(track_name, artist_name):
    query = f"track:{track_name} artist:{artist_name}"
    results = sp.search(q=query, type="track", limit=1)

    if results["tracks"]["items"]:
        return results["tracks"]["items"][0]["external_urls"]["spotify"]
    return None

@app.route('/recommend', methods=['POST'])
def recommend_songs():
    data = request.json
    input_song = data['song']
    features = ['danceability', 'energy', 'key', 'loudness', 'mode', 'speechiness', 'acousticness', 'instrumentalness', 'liveness', 'valence', 'tempo']

    # Find the closest match using fuzzy string matching
    closest_match, score, _ = process.extractOne(input_song, songs['name'])

    if score < 60:  # If the match score is too low, consider it not found
        return jsonify({'error': 'Song not found in the database'}), 404

    input_features = songs[songs['name'] == closest_match][features].values
    similarity_scores = cosine_similarity(input_features, songs[features])[0]
    similar_indices = similarity_scores.argsort()[::-1][1:6]  # Top 5 similar songs

    recommendations = songs.iloc[similar_indices][['name', 'artist']].to_dict('records')
    for i, rec in enumerate(recommendations):
        rec['similarity'] = round(similarity_scores[similar_indices[i]] * 100, 2)
        rec['spotify_link'] = get_spotify_link(rec['name'], rec['artist'])

    return jsonify(recommendations)

@app.route('/songs', methods=['GET'])
def get_songs():
    return jsonify(songs['name'].tolist())

@app.route('/update_songs', methods=['POST'])
def update_songs():
    try:
        result = subprocess.run(['python3', 'update_songs.py'], capture_output=True, text=True, check=True)
        load_songs()  # Reload the updated songs
        return jsonify({'message': 'Songs updated successfully', 'details': result.stdout}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({'error': 'Failed to update songs', 'details': e.stderr}), 500

if __name__ == '__main__':
    app.run(debug=True)
