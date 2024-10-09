# Tidy

This shell script modifies your terminal behavior based on the type of project directory you're in (Python or Node.js). It provides helpful information, like whether a `node_modules` or Python virtual environment (`.venv`) is present, and allows you to manage them with ease.

## Features

- Detects Node.js and Python project types.
- Prompts the user to delete the `node_modules` folder or create a Python virtual environment.
- Displays Node.js and Python versions.
- Outputs information in colorful and easy-to-read text.

## How to Use

1. Add the shell script to your `~/.zshrc` (for Zsh) or `~/.bashrc` (for Bash):
   ```bash
   source /path/to/shell_script.sh

