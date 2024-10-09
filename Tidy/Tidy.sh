# Define color variables for easy reuse
RED="\033[31m"
GREEN="\033[92m"
YELLOW="\033[33m"
BLUE="\033[94m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
RESET="\033[0m"
BG_GREEN="\033[42m"
BG_LIGHT_BLUE="\033[104m"
BG_RESET="\033[49m"

# Function to reset the terminal background to default
reset_bg_color() {
    echo -e "${BG_RESET}"
}

# Custom cd function to check node_modules, Python files, and change shell background
cd() {
    # Call the builtin cd command with the provided directory
    builtin cd "$@" || return

    # Track whether the folder is Node.js or Python related
    is_node=false
    is_python=false

    # If the directory contains a node_modules folder or package.json, mark it as Node.js-related
    if [ -d "node_modules" ] || [ -f "package.json" ]; then
        is_node=true
        echo -e "${BG_LIGHT_BLUE}${WHITE}This is a Node.js project.${RESET}${BG_RESET}"
    fi

    # Use globbing safely: check if any Python files are found without causing an error
    python_files=$(find . -maxdepth 1 -name "*.py" 2>/dev/null)
    if [ -n "$python_files" ]; then
        is_python=true
        echo -e "${BG_GREEN}${WHITE}This is a Python project.${RESET}${BG_RESET}"
    fi

    # If both Node.js and Python files exist, prioritize Node.js messages and color
    if [ "$is_node" = true ]; then
        echo -e "${BLUE}Node.js project detected.${RESET}"

        # Check for node_modules folder and prompt for deletion
        if [ -d "node_modules" ]; then
            echo -e "${YELLOW}This directory contains a node_modules folder. Do you want to delete it? (y/n)${RESET}"
            read -r answer
            if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
                echo -e "${RED}Removing node_modules...${RESET}"
                rm -rf node_modules
                echo -e "${GREEN}node_modules removed.${RESET}"
            else
                echo -e "${CYAN}Keeping node_modules.${RESET}"
            fi
        fi

        # If package.json is present, suggest package manager commands
        if [ -f "package.json" ]; then
            echo -e "${MAGENTA}Found a package.json file.${RESET}"
            if grep -q '"yarn"' package.json; then
                echo -e "${BLUE}You can use 'yarn install' to install dependencies.${RESET}"
            elif grep -q '"pnpm"' package.json; then
                echo -e "${BLUE}You can use 'pnpm install' to install dependencies.${RESET}"
            else
                echo -e "${BLUE}You can use 'npm install' to install dependencies.${RESET}"
            fi
        fi

        # Show Node.js and npm version
        if command -v node >/dev/null 2>&1; then
            echo -e "${GREEN}Node.js version: $(node -v)${RESET}"
        else
            echo -e "${RED}Node.js is not installed.${RESET}"
        fi

        if command -v npm >/dev/null 2>&1; then
            echo -e "${GREEN}npm version: $(npm -v)${RESET}"
        else
            echo -e "${RED}npm is not installed.${RESET}"
        fi
    fi

    # If Python files are found, show relevant Python messages
    if [ "$is_python" = true ]; then
        echo -e "${GREEN}Python files detected in this folder.${RESET}"

        # If no .venv is found, ask if a virtual environment should be created
        if [ ! -d ".venv" ]; then
            echo -e "${YELLOW}No .venv folder found. Do you want to create a virtual environment in this folder? (y/n)${RESET}"
            read -r create_venv
            if [[ "$create_venv" == "y" || "$create_venv" == "Y" ]]; then
                echo -e "${BLUE}Do you want to use a global virtual environment from ~/Software/.venv? (y/n)${RESET}"
                read -r use_global_venv
                if [[ "$use_global_venv" == "y" || "$use_global_venv" == "Y" ]]; then
                    echo -e "${CYAN}Using global virtual environment...${RESET}"
                    source ~/Software/.venv/bin/activate
                else
                    echo -e "${GREEN}Creating a local virtual environment...${RESET}"
                    python3 -m venv .venv
                    source .venv/bin/activate
                    echo -e "${GREEN}Virtual environment created and activated.${RESET}"
                fi

                # If requirements.txt is present, ask to install dependencies
                if [ -f "requirements.txt" ]; then
                    echo -e "${YELLOW}requirements.txt found. Do you want to install dependencies? (y/n)${RESET}"
                    read -r install_deps
                    if [[ "$install_deps" == "y" || "$install_deps" == "Y" ]]; then
                        pip install -r requirements.txt
                        echo -e "${GREEN}Dependencies installed.${RESET}"
                    fi
                fi
            fi
        fi

        # Display Python version and location
        if command -v python3 >/dev/null 2>&1; then
            echo -e "${GREEN}Python version: $(python3 --version)${RESET}"
            echo -e "${CYAN}Python location: $(which python3)${RESET}"
        else
            echo -e "${RED}Python is not installed.${RESET}"
        fi
    fi

    # Set background colors based on the type of project
    if [ "$is_node" = true ]; then
        echo -e "${BG_LIGHT_BLUE}"
    elif [ "$is_python" = true ]; then
        echo -e "${BG_GREEN}"
    else
        reset_bg_color
    fi
}

