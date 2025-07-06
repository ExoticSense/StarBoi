#!/bin/bash

# Check for jq dependency
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is not installed. Please install jq to use this script." >&2
    exit 1
fi

# Source .env from current directory or home directory
if [ -f .env ]; then
    source .env
elif [ -f "$HOME/.starboi.env" ]; then
    source "$HOME/.starboi.env"
else
    echo "Error: .env file with GEMINI_API_KEY not found." >&2
    exit 1
fi

API_KEY=$GEMINI_API_KEY
URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY"


#Show logo
echo -e "\e[38;2;0;200;255m★ startboi ★\e[0m"

#Intro message
echo "Hi! I'm Starboi :)."
echo "What do you want to do today?"
echo "Type 'exit' to say bye!."

#Infinite loop
while true; do
    # Prompt user input
    read -p "You: " user_input

    # Handle empty input
    if [[ -z "$user_input" ]]; then
        continue
    fi

    # Check for exit
    if [[ "$user_input" == "exit" ]]; then
        echo "Starboi: Hasta la Vista, habibi!"
        break
    fi


    # Show loading spinner while waiting for response
    spin='-\|/'
    i=0
    (
        while :; do
            printf "\rStarboi: Thinking... %s" "${spin:i++%${#spin}:1}"
            sleep 0.1
        done
    ) &
    spinner_pid=$!

    # Make API call and capture response
    response=$(curl -s -X POST "$URL" \
        -H "Content-Type: application/json" \
        -d '{
            "contents": [
                {
                    "parts": [
                        {
                            "text": "'"$user_input"'"
                        }
                    ]
                }
            ]
        }')

    # Stop spinner
    kill $spinner_pid >/dev/null 2>&1
    wait $spinner_pid 2>/dev/null
    printf "\r"           
    tput el 

    # Handle API errors gracefully
    error_msg=$(echo "$response" | jq -r '.error.message // empty')
    if [[ -n "$error_msg" ]]; then
        echo "Starboi: [API Error] $error_msg"
        continue
    fi

    # Extract the AI's reply from the JSON response
    ai_reply=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // "Sorry, I could not understand."')

    echo "Starboi: $ai_reply"
done