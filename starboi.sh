#!/bin/bash

# Check for jq dependency
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is not installed. Please install jq to use this script." >&2
    exit 1
fi

# Multiple Gemini API Keys
GEMINI_API_KEYS=(
    "AIzaSyDINe41S5P6HRiwkz-xQczWs6MCGBhjDFk"
    "AIzaSyBYxWEROm5u2SXQn3WjL2rVHZM1qtdBLt4"
    "AIzaSyBXGAIyWToJtB34NL2Ls0b63e0Q6zqkrqg"
)

# Function to get URL for a given API key
get_url() {
    echo "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$1"
}


#Show logo
echo -e "\e[38;2;0;200;255m★ startboi ★\e[0m"

#Intro message
echo "Hi! I'm Starboi :)."
echo "What do you want to do today?"
echo "Type 'exit' to say bye!."

# Parse command-line arguments for mode
MODE="chat"
if [[ "$1" == "-db" ]]; then
    MODE="db"
fi

if [[ "$MODE" == "db" ]]; then
    echo "Starboi DB Mode! Choose your option:"
    echo "1) sql"
    echo "2) plsql"
    read -p "Enter 1 for sql or 2 for plsql: " db_choice
    if [[ "$db_choice" == "1" ]]; then
        DB_TYPE="sql"
    elif [[ "$db_choice" == "2" ]]; then
        DB_TYPE="plsql"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
    echo "Type 'exit' to quit."
    while true; do
        read -p "You (DB): " user_input
        if [[ -z "$user_input" ]]; then
            continue
        fi
        if [[ "$user_input" == "exit" ]]; then
            echo "Starboi: Hasta la Vista, habibi!"
            break
        fi
        spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        i=0
        (
            while :; do
                printf "\r%s" "${spin:i++%${#spin}:1}"
                sleep 0.1
            done
        ) &
        spinner_pid=$!
        # Compose prompt for SQL/PLSQL
        if [[ "$DB_TYPE" == "sql" ]]; then
            prompt="Solve this SQL problem and give only the query: $user_input"
        else
            prompt="Solve this PLSQL problem and give only the code, no explanation: $user_input"
        fi
        payload=$(jq -n --arg text "$prompt" '{contents:[{parts:[{text:$text}]}]}')
        api_success=false
        for api_key in "${GEMINI_API_KEYS[@]}"; do
            URL=$(get_url "$api_key")
            response=$(curl -s -X POST "$URL" \
                -H "Content-Type: application/json" \
                -d "$payload")
            error_msg=$(echo "$response" | jq -r '.error.message // empty')
            if [[ -z "$error_msg" ]]; then
                api_success=true
                break
            fi
        done
        kill $spinner_pid >/dev/null 2>&1
        wait $spinner_pid 2>/dev/null
        printf "\r"
        tput el
        if ! $api_success; then
            echo "Starboi: [API Error] All API keys failed."
            continue
        fi
        ai_reply=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // "Sorry, I could not understand."')
        echo "$ai_reply"
    done
    exit 0
fi

# Infinite loop
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
    spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    i=0
    (
        while :; do
            printf "\r%s" "${spin:i++%${#spin}:1}"
            sleep 0.1
        done
    ) &
    spinner_pid=$!

    # Make API call and capture response
    payload=$(jq -n --arg text "$user_input" '{contents:[{parts:[{text:$text}]}]}')
    api_success=false
    for api_key in "${GEMINI_API_KEYS[@]}"; do
        URL=$(get_url "$api_key")
        response=$(curl -s -X POST "$URL" \
            -H "Content-Type: application/json" \
            -d "$payload")
        error_msg=$(echo "$response" | jq -r '.error.message // empty')
        if [[ -z "$error_msg" ]]; then
            api_success=true
            break
        fi
    done
    kill $spinner_pid >/dev/null 2>&1
    wait $spinner_pid 2>/dev/null
    printf "\r"           
    tput el 
    if ! $api_success; then
        echo "Starboi: [API Error] All API keys failed."
        continue
    fi
    ai_reply=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text // "Sorry, I could not understand."')
    echo "Starboi: $ai_reply"
done