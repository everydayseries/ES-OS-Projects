# ✨ Magical Story Generator ✨

Welcome to the **Magical Story Generator**, a Progressive Web App (PWA) that generates imaginative kids' stories and poems based on your ideas! Using the power of OpenAI's GPT model and Unsplash's image API, this app allows you to input a story idea and receive a beautifully crafted tale and an image to match.

## 📝 Overview

This app is designed to make storytelling fun and interactive. You provide an idea, and our app transforms it into a unique story and poem just for you. Additionally, the app fetches an illustrative image from Unsplash to complement your story, creating an engaging and complete storytelling experience.

## 🔧 Requirements

1. **OpenAI API Key**: You need an API key from OpenAI to use the language model for generating stories and poems.
2. **Unsplash API Key**: You’ll need an Unsplash API key to fetch images based on your story idea.

## 🚀 Getting Started

Follow these steps to set up and use the **Magical Story Generator**:

### 1. Clone the Repository
Clone this repository to your local machine:

```bash
git clone <repository-url>
cd magical-story-generator
```

### 2. Set Up Your API Keys

**Get OpenAI API Key**:
- Sign up at [OpenAI](https://platform.openai.com/signup).
- Generate an API key from the [OpenAI API Key Page](https://platform.openai.com/account/api-keys).

**Get Unsplash API Key**:
- Sign up at [Unsplash Developers](https://unsplash.com/developers).
- Register a new application and obtain an API key.

### 3. Run the App Locally
Open the project in a local server or simply open the `index.html` file in your browser to test the app.

### 4. Enter API Keys
To input your API keys:

- Click the **⚙️ Settings** button on the top of the page.
- Enter your **OpenAI API Key** and **Unsplash API Key** in the fields provided.
- Click **💾 Save API Keys** to save them securely in your browser's local storage.

### 5. Start Creating Stories!

1. Enter a brief idea in the text box, such as "a dragon learns to sing" or "a magical forest adventure."
2. Click the **📝 Create My Story! 🎉** button.
3. Wait a few moments as the app generates your story, poem, and fetches an image.

### 📂 Project Structure

- **index.html**: The main HTML page of the app.
- **styles.css**: Styling for the app.
- **app.js**: Main JavaScript file handling logic for story and image generation, sidebar settings, and API interactions.

### 📚 Additional Notes

- **Progressive Web App**: This app is designed as a PWA, so it can be installed on mobile devices for a more app-like experience.
- **Password Protection**: The settings sidebar is protected by a password. Replace `'your-password'` in `app.js` with a custom password of your choice.

### 🤔 Troubleshooting

- **API Key Issues**: Ensure the keys are correct and have the necessary permissions on the respective platforms.
- **No Image Found**: If Unsplash doesn’t have an image for your idea, a placeholder image will be displayed.

### ⚠️ Risks and Disclaimers

#### API Usage Costs
- **OpenAI and Unsplash API Usage**: This app relies on external APIs, which may incur costs based on usage. Ensure you understand the pricing structures of both OpenAI and Unsplash and monitor your usage to avoid unexpected charges.

#### Data Privacy
- **Local Storage**: API keys are saved in your browser’s local storage for convenience. This storage method is not encrypted, so avoid using the app on public or shared devices, as it may expose your API keys to others.

#### Story Content
- **Generated Content**: While we strive to make the app child-friendly by providing prompts for kids' stories, the generated content may not always be suitable for all audiences, as it is generated based on a language model’s interpretation of inputs. Always review stories and images before sharing them with children.

#### Image Appropriateness
- **Unsplash Image Search**: Images are fetched based on your story idea. Although Unsplash is a trusted source for images, there is no guarantee that all results will be appropriate for children. Please review images before sharing.

#### Liability
- **No Liability for External API Issues**: This app depends on external APIs. We cannot be held responsible for any issues arising from downtime, API changes, or costs associated with these services.

### 🌟 Contributing

We welcome contributions! If you'd like to improve the story generation logic, styling, or add new features, feel free to open a pull request.
