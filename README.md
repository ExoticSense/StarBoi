# ★ Starboi ★

A simple, interactive Gemini AI terminal client for Linux.

## Features

- Chat with Gemini 2.0 Flash API from your terminal
- Fast, minimal, and easy to use
- Spinner animation while waiting for responses
- Graceful error handling

## Prerequisites

- Bash shell
- [`jq`](https://stedolan.github.io/jq/) installed (`sudo apt install jq` or equivalent)
- A [Gemini API key](https://aistudio.google.com/app/apikey)

## Installation

1. **Clone or Download this Repository**

    ```bash
    git clone https://github.com/your-username/StarBoi.git
    cd StarBoi
    ```

2. **Make the Script Executable**

    ```bash
    chmod +x starboi.sh
    ```

3. **(Optional) Move the Script to Your PATH**

    ```bash
    sudo cp starboi.sh /usr/local/bin/starboi
    ```

4. **Set Up Your API Key**

    Create a file named `.starboi.env` in your home directory:

    ```bash
    nano ~/.starboi.env
    ```

    Add this line (replace with your actual API key):

    ```
    GEMINI_API_KEY=your_actual_api_key
    ```

5. **Install jq**

    ```bash
    sudo apt install jq   # Debian/Ubuntu
    # or
    sudo dnf install jq   # Fedora
    # or
    brew install jq       # macOS/Homebrew
    ```

## Usage

Start the chat by running:

```bash
starboi
```
or (if not moved to PATH):

```bash
./starboi.sh
```

- Type your message and press Enter.
- Type `exit` to quit.

## Security

- **Never share your API key publicly.**
- Each user should use their own API key in their own `~/.starboi.env` file.

## Troubleshooting

- If you see an error about `jq`, install it as shown above.
- If you see an API error, check your API key and quota.

## License

MIT License

---

Made with ❤️ by Jeevan
