// Add a console log to confirm the script is running
console.log("Script loaded successfully.");

// Show/Hide sidebar after password authentication
document
  .getElementById("settingsButton")
  .addEventListener("click", function () {
    document.getElementById("passwordModal").style.display = "flex"; // Show password modal
  });

document
  .getElementById("submitPassword")
  .addEventListener("click", function () {
    const password = document.getElementById("passwordInput").value;
    if (password === "your-password") {
      // Replace 'your-password' with your actual password
      document.getElementById("passwordModal").style.display = "none"; // Hide password modal
      openSidebar();
    } else {
      alert("Incorrect password!");
    }
  });

// Function to open the sidebar
function openSidebar() {
  document.getElementById("sidebar").style.width = "300px";
}

// Close the sidebar
function closeSidebar() {
  document.getElementById("sidebar").style.width = "0";
}

// Save API keys to local storage
document.getElementById("saveSettings").addEventListener("click", function () {
  const openaiApiKey = document.getElementById("openaiApiKey").value;
  const unsplashApiKey = document.getElementById("unsplashApiKey").value;

  if (openaiApiKey.trim() && unsplashApiKey.trim()) {
    localStorage.setItem("openaiApiKey", openaiApiKey);
    localStorage.setItem("unsplashApiKey", unsplashApiKey);
    alert("API keys saved successfully!");
    closeSidebar(); // Close sidebar after saving
  } else {
    alert("Please provide both API keys!");
  }
});

// Form submission for story generation
document
  .getElementById("ideaForm")
  .addEventListener("submit", async function (event) {
    event.preventDefault(); // Prevent the form from reloading the page
    const idea = document.getElementById("ideaInput").value;

    // Show the loader and hide the story section
    document.getElementById("loader").style.display = "block";
    document.getElementById("storySection").style.display = "none";

    if (!idea.trim()) {
      alert("Please enter an idea!");
      document.getElementById("loader").style.display = "none"; // Hide loader if input is invalid
      return;
    }

    // Retrieve API keys from local storage
    const openaiApiKey = localStorage.getItem("openaiApiKey");
    const unsplashApiKey = localStorage.getItem("unsplashApiKey");

    if (!openaiApiKey || !unsplashApiKey) {
      alert("Please provide both API keys in the settings!");
      document.getElementById("loader").style.display = "none";
      return;
    }

    try {
      const response = await fetch(
        "https://api.openai.com/v1/chat/completions",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${openaiApiKey}`, // Use the stored OpenAI API key
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: "gpt-4",
            messages: [
              {
                role: "system",
                content:
                  "You are a creative AI that writes kids stories and poems.",
              },
              {
                role: "user",
                content: `Write a playful kids story and a short poem based on: ${idea}. Start with the story and clearly separate the poem with the title "Poem:"`,
              },
            ],
            max_tokens: 300,
            temperature: 0.7,
          }),
        },
      );

      const data = await response.json();

      if (data.choices && data.choices.length > 0) {
        const storyAndPoem = data.choices[0].message.content;

        const splitIndex = storyAndPoem.indexOf("Poem:");
        let story, poem;

        if (splitIndex !== -1) {
          story = storyAndPoem.slice(0, splitIndex).trim();
          poem = storyAndPoem.slice(splitIndex).trim();
        } else {
          story = storyAndPoem.trim();
          poem = "Poem could not be generated.";
        }

        // Display the generated story and poem
        document.getElementById("generatedStory").innerText =
          story || "Story could not be generated";
        document.getElementById("generatedPoem").innerText =
          poem || "Poem could not be generated";

        // Fetch and display the image based on the story or idea
        const imageUrl = await fetchStoryImage(idea, unsplashApiKey);
        document.getElementById("storyImage").src = imageUrl;

        // Hide the loader and show the story section
        document.getElementById("loader").style.display = "none";
        document.getElementById("storySection").style.display = "block";
      } else {
        throw new Error("No content returned from OpenAI API");
      }
    } catch (error) {
      console.error("Error generating story and poem:", error);
      alert(`There was an issue generating your story: ${error.message}`);

      // Hide loader in case of an error
      document.getElementById("loader").style.display = "none";
    }
  });

// Function to fetch an image based on the idea
async function fetchStoryImage(query, unsplashApiKey) {
  try {
    const response = await fetch(
      `https://api.unsplash.com/photos/random?query=${query}&client_id=${unsplashApiKey}`,
    );
    const data = await response.json();

    if (data.urls && data.urls.small) {
      return data.urls.small; // Return the small size image URL
    } else {
      throw new Error("No image found for the query");
    }
  } catch (error) {
    console.error("Error fetching image:", error);
    return "https://via.placeholder.com/400x300?text=No+Image+Found"; // Fallback image
  }
}
