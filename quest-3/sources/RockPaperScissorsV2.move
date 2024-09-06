address 0xa1abb7aed7dbbc1561efd8f37a4049935460451d0a0951ddc8d6b821a77fd5db {

module RockPaperScissors {
    use std::signer;
    use aptos_framework::randomness;

    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;

    // Original game struct
    struct Game has key, drop {
        player: address,
        player_move: u8,   
        computer_move: u8,
        result: u8,
    }

    // Modifying the game struct to keep track of both player and computer wins
    // This version implements the keeping track of player or computer wins
    struct GameV2 has key, drop {
        player: address,
        player_move: u8,   
        computer_move: u8,
        result: u8,
        player_wins: u64, // tracking player wins
        computer_wins: u64, // tracking computer wins
    }

    // Creating a new game struct to track the number of rounds to be played
    struct GameV3 has key, drop {
        player: address,
        player_move: u8,   
        computer_move: u8,
        result: u8,
        player_wins: u64, // tracking player wins
        computer_wins: u64, // tracking computer wins
        total_rounds: u64, // rounds to be played
        current_round: u64, // current round
    }

    // Original start game function
    public entry fun start_game(account: &signer) acquires GameV2 {
        let player = signer::address_of(account);

        if (exists<GameV2>(player)) {
            // If a game already exists for the player, reset the existing game
            let game = borrow_global_mut<GameV2>(player);
            game.player_move = 0;
            game.computer_move = 0;
            game.result = 0;
        } else {
            // If no game exists, create a new one
            let game = GameV2 {
                player,
                player_move: 0,
                computer_move: 0,
                result: 0,
                player_wins: 0,
                computer_wins: 0,
            };
            move_to(account, game);
        }
    }

    public entry fun start_game_v3(account: &signer, total_rounds: u64) acquires GameV3 {
        let player = signer::address_of(account);

        if (exists<GameV3>(player)) {
            // If a game already exists for the player
            let game = borrow_global_mut<GameV3>(player);
            
            // Check if the previous game has ended
            if (game.current_round > game.total_rounds) {
                // If the game has ended, start a new series of rounds
                game.total_rounds = if (total_rounds > 0) total_rounds else game.total_rounds;
                game.current_round = 1;
            } else {
                // If the game hasn't ended, just increment the current round
                game.current_round = game.current_round + 1;
            };

            // Reset move and result for the new round
            game.player_move = 0;
            game.computer_move = 0;
            game.result = 0;

        } else {
            // If no game exists, create a new one
            let game = GameV3 {
                player,
                player_move: 0,
                computer_move: 0,
                result: 0,
                player_wins: 0,
                computer_wins: 0,
                total_rounds,
                current_round: 1,
            };
            move_to(account, game);
        }
    }


    public entry fun set_player_move(account: &signer, player_move: u8) acquires GameV3 {
        let game = borrow_global_mut<GameV3>(signer::address_of(account));
        if (game.current_round > game.total_rounds){
            abort 1
        };
        game.player_move = player_move;
    }

    #[randomness]
    entry fun randomly_set_computer_move(account: &signer) acquires GameV3 {
        randomly_set_computer_move_internal(account);
    }

    public(friend) fun randomly_set_computer_move_internal(account: &signer) acquires GameV3 {
        let game = borrow_global_mut<GameV3>(signer::address_of(account));
        if (game.current_round > game.total_rounds){
            abort 1
        };
        let random_number = randomness::u8_range(1, 4);
        game.computer_move = random_number;
    }

    public entry fun finalize_game_results(account: &signer) acquires GameV3 {
        let game = borrow_global_mut<GameV3>(signer::address_of(account));

        if (game.current_round > game.total_rounds){
            abort 1
        };

        // Determine the winner of the current round and update the result
        let result = determine_winner(game.player_move, game.computer_move);
        game.result = result;

        // Update the score based on the result
        if (result == 2) { // player wins
            game.player_wins = game.player_wins + 1;
        } else if (result == 3) { // computer wins
            game.computer_wins = game.computer_wins + 1;
        };

        // Increment the round counter
        game.current_round = game.current_round + 1;

        // Check if the game has reached the final round
        if (game.current_round >= game.total_rounds) {
            // Determine the overall winner
            if (game.player_wins > game.computer_wins) {
                // Player wins the game
                game.result = 2;
            } else if (game.computer_wins > game.player_wins) {
                // Computer wins the game
                game.result = 3;
            } else {
                // It's a draw
                game.result = 1;
            }
        }
    }

    fun determine_winner(player_move: u8, computer_move: u8): u8 {
        if (player_move == ROCK && computer_move == SCISSORS) {
            2 // player wins
        } else if (player_move == PAPER && computer_move == ROCK) {
            2 // player wins
        } else if (player_move == SCISSORS && computer_move == PAPER) {
            2 // player wins
        } else if (computer_move == ROCK && player_move == SCISSORS) {
            3
        }  else if (computer_move == PAPER && player_move == ROCK) {
            3
        }  else if (computer_move == SCISSORS && player_move == PAPER) {
            3
        }  else {
            1 // draw
        } 
    }

    // Functionality to allow the player to reset the game
    public entry fun reset_game(account: &signer) acquires GameV3 {
        let game = borrow_global_mut<GameV3>(signer::address_of(account));
        game.player_move = 0;
        game.computer_move = 0;
        game.result = 0;
        game.player_wins = 0;
        game.computer_wins = 0;
        game.total_rounds = 0;
        game.current_round = 1;
    }

    // deprecated
    public entry fun set_total_rounds(_account: &signer, _rounds: u64) {
        // This function is deprecated and no longer does anything
    }

    #[view]
    public fun get_player_move(account_addr: address): u8 acquires GameV3 {
        borrow_global<GameV3>(account_addr).player_move
    }

    #[view]
    public fun get_computer_move(account_addr: address): u8 acquires GameV3 {
        borrow_global<GameV3>(account_addr).computer_move
    }

    #[view]
    public fun get_game_results(account_addr: address): u8 acquires GameV3 {
        borrow_global<GameV3>(account_addr).result
    }

    // Adding functions to retrieve the scores both the player or the computer
    #[view]
    public fun get_player_score(account_addr: address): u64 acquires GameV3 {
        borrow_global<GameV3>(account_addr).player_wins
    }

    #[view]
    public fun get_computer_score(account_addr: address): u64 acquires GameV3 {
        borrow_global<GameV3>(account_addr).computer_wins
    }

    // Adding a function to get the number of rounds left
    #[view]
    public fun is_game_over(account_addr: address): bool acquires GameV3 {
        let game = borrow_global<GameV3>(account_addr);
        game.current_round > game.total_rounds
    }

    // Checking the number of rounds left
    #[view]
    public fun check_rounds_left(account_addr: address): u64 acquires GameV3 {
        let game = borrow_global<GameV3>(account_addr);
        game.total_rounds - game.current_round
    }

}
}

// I implemented the following functionalities
// reset_game (basically restarting a new game), 
// keeping_score, (keeping track of the no of wins of both computer and the player)
// round_system (basically a best of round kind of functionlity.)