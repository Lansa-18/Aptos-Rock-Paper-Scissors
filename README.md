# Rock Paper Scissors on Aptos
This project implements a Rock Paper Scissors game as a smart contract on the Aptos blockchain. The game allows players to compete against a computer opponent, with support for multi-round matches and score tracking.

## Project Setup
- Clone the repo with ```git clone https://github.com/Lansa-18/Aptos-Rock-Paper-Scissors``` into your desired project folder
- Install the Aptos CLI using ```curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3```
- To confirm if it has been properly installed run `aptos info`
- if prompted to, run the command provided in your terminal output to add the Aptos CLI’s bin directory to your PATH environment variable. For example:
```export PATH="/home/stackie123/.local/bin:$PATH"```
- Run `aptos init` to initialize an account, select `testnet` and ensure to replace the address given to you with the one at the top most level of the code at `line 1`
- Run `aptos move publish` to deploy the contract.
  
## Features

- Play Rock Paper Scissors against a computer opponent.
- Multi-round matches with customizable number of rounds.
- Score tracking across multiple games.
- Random computer move generation.
- Game state management.
- View functions to check game status and scores.

## How to Play

- Start a new game by calling start_game_v3 with the desired number of rounds.
- Set your move for each round using set_player_move (1 for Rock, 2 for Paper, 3 for Scissors).
- The computer's move is set automatically using randomly_set_computer_move.
- After both moves are set, call finalize_game_results to determine the winner of the round and update scores.
- Repeat steps 2-4 for each round until the game is over.
- Use view functions to check the game status, scores, and results at any time.

## Key Functions

- **start_game_v3:** Initializes a new game or starts a new round series.
- **set_player_move:** Sets the player's move for the current round.
- **randomly_set_computer_move:** Generates and sets a random move for the computer.
- **finalize_game_results:** Determines the winner of the current round and updates scores.
- **reset_game:** Resets the game state to start a new game.
- **is_game_over:** Checks if the current game has ended.
- **check_rounds_left:** Returns the number of rounds left in the current game.

## Functionalities I Implemented
- **reset_game:** basically restarting a new game
- **keeping_score:** (keeping track of the no of wins of both computer and the player
- **round_system:** basically a best of round kind of functionlity.

## Demo Video
[Watch the Video here](https://youtu.be/3mEk993ThQg)

## Development Notes

The contract uses Aptos's randomness module for generating computer moves.
The game implements a versioning system (GameV3) to allow for future upgrades while maintaining backward compatibility.
A deprecated set_total_rounds function is kept for compatibility with previous versions.

Peace ✌️✌️🍀
