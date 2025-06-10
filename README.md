# Mastermind Swift Game 🎯

A command-line implementation of the classic Mastermind game written in Swift. Players try to guess a 4-digit secret code where each digit is between 1-6.

## About the Game

Mastermind is a code-breaking game where you need to guess a secret 4-digit code. After each guess, you'll receive feedback:
- **B (Black)**: Correct digit in the correct position
- **W (White)**: Correct digit in the wrong position

You have 10 attempts to crack the code!

## Prerequisites

- Docker installed on your system
- Internet connection (the game connects to a remote API)

## How to Run

### Using Docker (Recommended)

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/AliMajidi1/mastermind-swift.git
   cd mastermind-swift
   ```

2. **Run the game using Docker**
   ```bash
   sudo docker run --rm -it -v $(pwd):/src swift swift /src/main.swift
   ```

   **Command breakdown:**
   - `sudo docker run` - Run a Docker container with elevated privileges
   - `--rm` - Automatically remove the container when it exits
   - `-it` - Interactive mode with TTY (allows user input)
   - `-v $(pwd):/src` - Mount current directory to `/src` in the container
   - `swift` - Use the official Swift Docker image
   - `swift /src/main.swift` - Execute the Swift file

### Alternative: One-liner from any directory

If you want to run it from a different directory, use the full path:

```bash
sudo docker run --rm -it -v /path/to/mastermind-swift:/src swift swift /src/main.swift
```

Replace `/path/to/mastermind-swift` with the actual path to where you downloaded the code.

## Game Instructions

1. **Starting the Game**: The game will automatically create a new game session and display your Game ID.

2. **Making Guesses**: 
   - Enter a 4-digit number where each digit is between 1-6
   - Example: `1234`, `5566`, `1111`

3. **Reading Feedback**:
   - `B` means you got a digit right and it's in the correct position
   - `W` means you got a digit right but it's in the wrong position
   - Example: If the secret is `1234` and you guess `1324`, you'll get `BBW` (first two digits correct position, third digit correct but wrong position)

4. **Winning**: Get 4 B's (all digits in correct positions)

5. **Exiting**: Type `exit` at any time to quit the game

## Example Game Session

```
🎯 Welcome to Mastermind!
Guess the 4-digit secret code. Each digit should be between 1-6.
After each guess, you'll receive:
B (Black): Correct digit in correct position
W (White): Correct digit in wrong position
Type 'exit' at any time to quit the game.

🎮 New game started! Game ID: abc123

--- Attempt 1/10 ---
Enter your 4-digit guess (1-6): 1234

🔍 Your guess: 1234
📊 Result: BW
✅ 1 correct digit(s) in correct position
⚪ 1 correct digit(s) in wrong position

--- Attempt 2/10 ---
Enter your 4-digit guess (1-6): 1356
...
```

## Troubleshooting

### Docker Permission Issues
If you get permission errors, make sure Docker is installed correctly:
```bash
# Check if Docker is running
docker --version

# If you don't want to use sudo, add your user to docker group (Linux/macOS)
sudo usermod -aG docker $USER
# Then log out and log back in
```

### Network Issues
The game requires internet connection to communicate with the Mastermind API at `https://mastermind.darkube.app`. If you see network errors:
- Check your internet connection
- Ensure your firewall isn't blocking the connection
- Try again after a few moments

### Invalid Input
Make sure your guesses:
- Are exactly 4 digits long
- Only contain numbers 1-6
- Don't include spaces or other characters

## Game Features

- ✅ Interactive command-line interface
- ✅ Real-time feedback on guesses
- ✅ Attempt counter (10 maximum attempts)
- ✅ Input validation
- ✅ Graceful error handling
- ✅ Clean game session management
- ✅ Easy exit option

## Technical Details

- **Language**: Swift
- **API**: RESTful API for game logic
- **Container**: Official Swift Docker image
- **Platform**: Cross-platform (Linux, macOS, Windows with Docker)

## License

This project is open source. Feel free to fork and modify!

---

**Have fun cracking the code! 🕵️‍♂️**
