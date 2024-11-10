# S&P 500 Trend Reversal Prediction - README

## Overview

This Streamlit application allows users to analyze and predict trend reversals in the S&P 500 index using historical data, technical indicators, and machine learning. The tool leverages technical indicators like RSI, MACD, and Bollinger Bands, alongside a machine learning model (Random Forest Classifier) to predict upward and downward trends in the market.

## Features

- **Data Download:** Downloads S&P 500 historical data from Yahoo Finance.
- **Technical Indicators:** Calculates RSI, MACD, and Bollinger Bands.
- **Machine Learning:** Trains a Random Forest Classifier to predict trend reversals.
- **User Customization:** Provides sidebar controls for adjusting indicator parameters and visualization options.
- **Interactive Visualization:** Plots S&P 500 price, actual trend reversals, and predicted trend reversals, with adjustable styling options.
- **Model Performance Metrics:** Displays model accuracy and a classification report.

## Requirements

### Python Libraries

- **Streamlit:** For the web interface.
- **yfinance:** For downloading financial data.
- **pandas, numpy:** For data manipulation and processing.
- **scikit-learn:** For machine learning model training and evaluation.
- **matplotlib:** For plotting.

Install the required packages using:

```bash
pip install streamlit yfinance pandas numpy scikit-learn matplotlib
```
## How to Use

1. **Run the Application:**
   Launch the app with the following command:

   ```bash
   streamlit run <filename.py>
   ```

   2. **Adjust Parameters:**
      Use the sidebar to modify parameters for technical indicators (RSI, MACD, Bollinger Bands) and the trend reversal threshold. Additionally, the sidebar offers customization options for plot styling, such as colors, line width, marker size, transparency, and y-axis scale.

   3. **View Model Performance:**
      After running the prediction, view the model’s accuracy and a detailed classification report, available within the "Model Performance Metrics" expander section.

   4. **Visualize Trends:**
      The main plot displays the S&P 500 price history along with actual and predicted trend reversals. Users can customize the plot by adjusting colors, marker sizes, line width, and transparency through the sidebar options.

   5. **Explore Statistics:**
      The "Additional Statistics" expander section offers metrics on total trend reversals, including a breakdown of upward and downward reversals, for further insights into market movement trends.


## Code Structure

- **Data Loading:** The `load_data` function fetches historical S&P 500 data using the `yfinance` library and formats it for further analysis.
- **Technical Indicator Calculations:**
  - `calculate_rsi`: Calculates the Relative Strength Index (RSI) for measuring market momentum.
  - `calculate_macd`: Computes the Moving Average Convergence Divergence (MACD) and its signal line, often used to gauge trend strength and direction.
  - `calculate_bollinger_bands`: Generates Bollinger Bands, which provide a dynamic range for price movements based on volatility.
- **Labeling Reversals:** The `label_trend_reversals` function identifies potential upward and downward reversals using a user-defined threshold on price changes, labeling them for use in model training.
- **Machine Learning Model:** The code uses `train_test_split` to split the labeled data into training and testing sets, with a Random Forest Classifier trained to predict trend reversals based on selected technical indicators.
- **Plotting and Visualization:** The app provides an interactive plot that displays the S&P 500 price history along with actual and predicted trend reversals. Users can adjust plot colors, marker sizes, line widths, and y-axis scale through sidebar controls.

## Disclaimer

This application is intended solely for educational and informational purposes and should not be used as financial or investment advice. Predicting financial markets involves a high degree of uncertainty, and no model can predict market movements with complete accuracy. Users should conduct their own research or consult a financial advisor before making any investment decisions.

**Data Note:** The application relies on historical data from Yahoo Finance, which may have limitations in terms of accuracy, timeliness, and completeness.
