#!/bin/bash
source .env 

API_KEY=$GEMINI_API_KEY
URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY"


# 1. Show logo
echo -e "\e[38;2;0;200;255m★ startboi ★\e[0m"

# 2. Intro message
echo "Hi! I'm Starboi :)."
echo "What do you want to do today?"
echo "Type 'exit' to say bye!."

# 3. Infinite loop
while true; do
    # Prompt user input
    read -p "You: " user_input

    # Check for exit
    if [[ "$user_input" == "exit" ]]; then
        echo "Starboi: Hasta la Vista, habibi!"
        break
    fi

    # 4. Call Gemini API with curl
    # For now, just echo back a placeholder
    echo "Starboi: Thinking..."
    echo "Starboi: (This is where Gemini’s response will go)"
done
