#!/bin/bash

# Check for jq dependency
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is not installed. Please install jq to use this script." >&2
    exit 1
fi

# Multiple Gemini API Keys
GEMINI_API_KEYS=(
    "AIzaSyCR1gWqf-kwM74jj9-RKuqtQbQ_SYfkCag"
    "AIzaSyDLmzPy5AbpXQz2UnB1aMu7e5rY8V4evUM"
    "AIzaSyC4_Se9jduGynInvNVWUWMnfHU9KvRQSeI"
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

    # For PLSQL allow skipping schema; SQL requires schema
    if [[ "$DB_TYPE" == "plsql" ]]; then
        read -p "Do you want to provide a schema? (y/N): " provide_schema
        if [[ "$provide_schema" =~ ^[Yy]$ ]]; then
            echo
            echo "Enter your database schema. Finish by typing a single line with: END"
            SCHEMA=""
            while IFS= read -r line; do
                [[ "$line" == "END" ]] && break
                SCHEMA+="$line"$'\n'
            done
            echo "Schema saved."
        else
            SCHEMA=""
            echo "Proceeding without schema. PLSQL answers will be generated without schema context."
        fi
    else
        echo
        echo "Enter your database schema. Finish by typing a single line with: END"
        SCHEMA=""
        while IFS= read -r line; do
            [[ "$line" == "END" ]] && break
            SCHEMA+="$line"$'\n'
        done
        echo "Schema saved."
    fi

    echo "Now you can ask questions related to the above schema (or general PLSQL if no schema)."
    echo "Commands: 'schema' to re-enter schema, 'exit' to quit."

    # Question loop (uses saved SCHEMA)
    while true; do
        read -p "You (DB): " user_input
        if [[ -z "$user_input" ]]; then
            continue
        fi
        if [[ "$user_input" == "exit" ]]; then
            echo "Starboi: Hasta la Vista, habibi!"
            break
        fi
        if [[ "$user_input" == "schema" ]]; then
            echo
            echo "Re-enter your database schema. Finish by typing a single line with: END"
            SCHEMA=""
            while IFS= read -r line; do
                [[ "$line" == "END" ]] && break
                SCHEMA+="$line"$'\n'
            done
            echo "Schema updated."
            continue
        fi

        # spinner (no text)
        spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
        i=0
        (
            while :; do
                printf "\r%s" "${spin:i++%${#spin}:1}"
                sleep 0.1
            done
        ) &
        spinner_pid=$!

        # Compose prompt using saved schema; omit schema if empty for plsql
        if [[ "$DB_TYPE" == "sql" ]]; then
            prompt="Given the following database schema:\n$SCHEMA\nAnswer the SQL question and provide ONLY the SQL query (no explanation):\n$user_input"
        else
            if [[ -n "$SCHEMA" ]]; then
                prompt="Given the following database schema:\n$SCHEMA\nAnswer the PLSQL question and provide ONLY the PLSQL code (no explanation):\n$user_input"
            else
                prompt="Answer the PLSQL question and provide ONLY the PLSQL code (no explanation):\n$user_input"
            fi
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