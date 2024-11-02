import pylast
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import csv
import os
from dotenv import load_dotenv

load_dotenv()

# Last.fm API credentials
LASTFM_API_KEY = os.getenv("LASTFM_API_KEY")
LASTFM_API_SECRET = os.getenv("LASTFM_API_SECRET")

# Spotify API credentials
SPOTIFY_CLIENT_ID = os.getenv("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.getenv("SPOTIFY_CLIENT_SECRET")

# Initialize Last.fm network
network = pylast.LastFMNetwork(api_key=LASTFM_API_KEY, api_secret=LASTFM_API_SECRET)

# Initialize Spotify client
sp = spotipy.Spotify(auth_manager=SpotifyClientCredentials(client_id=SPOTIFY_CLIENT_ID, client_secret=SPOTIFY_CLIENT_SECRET))

def get_top_tracks(limit=50):
    chart = network.get_top_tracks(limit=limit)
    return [(track.item.get_name(), track.item.get_artist().get_name()) for track in chart]

def get_audio_features(track_name, artist_name):
    query = f"track:{track_name} artist:{artist_name}"
    results = sp.search(q=query, type="track", limit=1)
    
    if results["tracks"]["items"]:
        track_id = results["tracks"]["items"][0]["id"]
        audio_features = sp.audio_features(track_id)[0]
        return audio_features
    return None

def update_songs_csv():
    top_tracks = get_top_tracks()
    
    with open("songs.csv", "w", newline="") as csvfile:
        fieldnames = ["name", "artist", "danceability", "energy", "key", "loudness", "mode", "speechiness", "acousticness", "instrumentalness", "liveness", "valence", "tempo"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        
        for track_name, artist_name in top_tracks:
            audio_features = get_audio_features(track_name, artist_name)
            if audio_features:
                writer.writerow({
                    "name": track_name,
                    "artist": artist_name,
                    "danceability": audio_features["danceability"],
                    "energy": audio_features["energy"],
                    "key": audio_features["key"],
                    "loudness": audio_features["loudness"],
                    "mode": audio_features["mode"],
                    "speechiness": audio_features["speechiness"],
                    "acousticness": audio_features["acousticness"],
                    "instrumentalness": audio_features["instrumentalness"],
                    "liveness": audio_features["liveness"],
                    "valence": audio_features["valence"],
                    "tempo": audio_features["tempo"]
                })
    
    print("songs.csv has been updated with the latest top tracks from Last.fm")

if __name__ == "__main__":
    update_songs_csv()
