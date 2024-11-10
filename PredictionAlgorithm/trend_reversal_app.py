import streamlit as st
import yfinance as yf
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
import matplotlib.pyplot as plt

# Streamlit title and description
st.title("S&P 500 Trend Reversal Prediction")
st.write("This app allows you to explore trend reversals in the S&P 500 index using technical indicators and machine learning.")

# Sidebar controls for indicator parameters
st.sidebar.header("Indicator Parameters")

# RSI parameters
rsi_period = st.sidebar.slider("RSI Period", min_value=5, max_value=50, value=14)

# MACD parameters
macd_short_period = st.sidebar.slider("MACD Short Period", min_value=5, max_value=50, value=12)
macd_long_period = st.sidebar.slider("MACD Long Period", min_value=10, max_value=100, value=26)
macd_signal_period = st.sidebar.slider("MACD Signal Period", min_value=5, max_value=50, value=9)

# Bollinger Bands parameters
bollinger_period = st.sidebar.slider("Bollinger Band Period", min_value=5, max_value=50, value=20)
bollinger_std_dev = st.sidebar.slider("Bollinger Band Std Dev", min_value=1, max_value=3, value=2)

# Trend reversal threshold
reversal_threshold = st.sidebar.slider("Trend Reversal Threshold", min_value=0.01, max_value=0.05, value=0.02)

# Graph customization options
st.sidebar.header("Visualization Options")

# Plot style
plot_style = st.sidebar.selectbox("Plot Style", ["default", "seaborn", "fivethirtyeight", "bmh", "ggplot"], index=0)

# Color scheme
price_color = st.sidebar.color_picker("Price Line Color", "#1f77b4")
actual_reversal_color = st.sidebar.color_picker("Actual Reversal Color", "#2ecc71")
predicted_reversal_color = st.sidebar.color_picker("Predicted Reversal Color", "#e74c3c")

# Marker size and transparency
marker_size = st.sidebar.slider("Marker Size", min_value=20, max_value=200, value=100)
line_width = st.sidebar.slider("Line Width", min_value=1, max_value=5, value=2)
alpha = st.sidebar.slider("Transparency", min_value=0.1, max_value=1.0, value=0.6)

# Y-axis scale
y_axis_scale = st.sidebar.selectbox("Y-axis Scale", ["linear", "log"])

# Download SPX data
@st.cache_data
def load_data():
    spx_data = yf.download('^GSPC', start='2000-01-01', end='2023-01-01', interval='1d')
    spx_data.reset_index(inplace=True)
    return spx_data[['Date', 'Open', 'High', 'Low', 'Close', 'Volume']]

spx_data = load_data()

# RSI calculation
def calculate_rsi(data, period):
    delta = data['Close'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    rs = gain / loss
    rsi = 100 - (100 / (1 + rs))
    return rsi

spx_data['RSI'] = calculate_rsi(spx_data, rsi_period)

# MACD calculation
def calculate_macd(data, short_period, long_period, signal_period):
    short_ema = data['Close'].ewm(span=short_period, adjust=False).mean()
    long_ema = data['Close'].ewm(span=long_period, adjust=False).mean()
    macd = short_ema - long_ema
    signal_line = macd.ewm(span=signal_period, adjust=False).mean()
    return macd, signal_line

spx_data['MACD'], spx_data['Signal_Line'] = calculate_macd(spx_data, macd_short_period, macd_long_period, macd_signal_period)

# Bollinger Bands calculation
def calculate_bollinger_bands(data, period, num_std_dev):
    sma = data['Close'].rolling(window=period).mean()
    rolling_std = data['Close'].rolling(window=period).std()
    upper_band = sma + (rolling_std * num_std_dev)
    lower_band = sma - (rolling_std * num_std_dev)
    return sma, upper_band, lower_band

spx_data['SMA'], spx_data['Upper_Band'], spx_data['Lower_Band'] = calculate_bollinger_bands(spx_data, bollinger_period, bollinger_std_dev)

# Standard Deviation for volatility
spx_data['Standard_Deviation'] = spx_data['Close'].rolling(window=20).std()

# Label trend reversals
def label_trend_reversals(data, threshold):
    data['Return'] = data['Close'].pct_change()
    data['Reversal'] = np.where(data['Return'] > threshold, 1, np.where(data['Return'] < -threshold, -1, 0))
    return data

spx_data = label_trend_reversals(spx_data, reversal_threshold)
spx_data.dropna(inplace=True)

# Create feature matrix
feature_columns = ['RSI', 'MACD', 'Signal_Line', 'SMA', 'Upper_Band', 'Lower_Band', 'Standard_Deviation']
X = spx_data[feature_columns]
y = spx_data['Reversal']

# Split the data while preserving index information
indices = np.arange(len(X))
X_train_idx, X_test_idx, y_train, y_test = train_test_split(indices, y, test_size=0.2, random_state=42)

# Get the actual training and test sets
X_train = X.iloc[X_train_idx]
X_test = X.iloc[X_test_idx]

# Train the Random Forest model
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Make predictions
y_pred = model.predict(X_test)
accuracy = accuracy_score(y_test, y_pred)

# Display evaluation results in an expander
with st.expander("Model Performance Metrics"):
    st.write("Model Accuracy:", accuracy)
    st.text("Classification Report:")
    st.text(classification_report(y_test, y_pred))

# Set the plot style
plt.style.use(plot_style)

# Create a figure for plotting
fig, ax = plt.subplots(figsize=(14, 8))

# Plot SPX Close Price
ax.plot(spx_data['Date'], spx_data['Close'],
        label='SPX Close Price',
        color=price_color,
        linewidth=line_width,
        alpha=alpha)

# Plot actual reversals
actual_reversals = spx_data[spx_data['Reversal'] != 0]
ax.scatter(actual_reversals['Date'],
          actual_reversals['Close'],
          color=actual_reversal_color,
          marker='o',
          label='Actual Reversal',
          alpha=alpha,
          s=marker_size)

# Plot predicted reversals
test_dates = spx_data.iloc[X_test_idx]['Date']
test_prices = spx_data.iloc[X_test_idx]['Close']
predicted_reversals_mask = y_pred != 0

ax.scatter(test_dates[predicted_reversals_mask],
          test_prices[predicted_reversals_mask],
          color=predicted_reversal_color,
          marker='x',
          label='Predicted Reversal',
          alpha=alpha,
          s=marker_size)

# Set y-axis scale
ax.set_yscale(y_axis_scale)

# Formatting the plot
ax.set_title('S&P 500 Trend Reversal Analysis', pad=20)
ax.set_xlabel('Date')
ax.set_ylabel('Price')
ax.legend(loc='upper left')
plt.xticks(rotation=45)
plt.grid(True, alpha=0.3)

# Add padding to the layout
plt.tight_layout()

# Display the plot
st.pyplot(fig)

# Add additional statistics in an expander
with st.expander("Additional Statistics"):
    col1, col2, col3 = st.columns(3)

    with col1:
        st.metric("Total Reversals", len(spx_data[spx_data['Reversal'] != 0]))

    with col2:
        st.metric("Upward Reversals", len(spx_data[spx_data['Reversal'] == 1]))

    with col3:
        st.metric("Downward Reversals", len(spx_data[spx_data['Reversal'] == -1]))
