address 0xa1abb7aed7dbbc1561efd8f37a4049935460451d0a0951ddc8d6b821a77fd5db {

module RockPaperScissors {
    use std::signer;
    use aptos_framework::randomness;

    const ROCK: u8 = 1;
    const PAPER: u8 = 2;
    const SCISSORS: u8 = 3;

    // Modifying the game struct to keep track of both player and computer wins
    struct Game has key, drop {
        player: address,
        player_move: u8,   
        computer_move: u8,
        result: u8,
        player_wins: u64, // tracking player wins
        computer_wins: u64, // tracking computer wins
    }

   // Edited the start game function to take into account if previous user resources exists.
   public entry fun start_game(account: &signer) acquires Game {
        let player = signer::address_of(account);

        if (exists<Game>(player)) {
            // If a game already exists for the player, reset the existing game
            let game = borrow_global_mut<Game>(player);
            game.player_move = 0;
            game.computer_move = 0;
            game.result = 0;
        } else {
            // If no game exists, create a new one
            let game = Game {
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


    public entry fun set_player_move(account: &signer, player_move: u8) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player_move = player_move;
    }

    #[randomness]
    entry fun randomly_set_computer_move(account: &signer) acquires Game {
        randomly_set_computer_move_internal(account);
    }

    public(friend) fun randomly_set_computer_move_internal(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        let random_number = randomness::u8_range(1, 4);
        game.computer_move = random_number;
    }

    public entry fun finalize_game_results(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));

        // Determine the winner of the game and update the result accordingly
        let result = determine_winner(game.player_move, game.computer_move);
        game.result = result;

        // Updating the score base on the result
        if (result == 2 ) { // meaning the player wins
            game.player_wins = game.player_wins + 1;
        } else if (result == 3) { // meaning the computer wins
            game.computer_wins = game.computer_wins + 1;
        }

        // game.result = determine_winner(game.player_move, game.computer_move);
    }

    fun determine_winner(player_move: u8, computer_move: u8): u8 {
        if (player_move == ROCK && computer_move == SCISSORS) {
            2 // player wins
        } else if (player_move == PAPER && computer_move == ROCK) {
            2 // player wins
        } else if (player_move == SCISSORS && computer_move == PAPER) {
            2 // player wins
        } else if (player_move == computer_move) {
            1 // draw
        } else {
            3 // computer wins
        }
    }

    // Functionality to allow the player to reset the game
    public entry fun reset_game(account: &signer) acquires Game {
        let game = borrow_global_mut<Game>(signer::address_of(account));
        game.player_move = 0;
        game.computer_move = 0;
        game.result = 0;
    }

    #[view]
    public fun get_player_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).player_move
    }

    #[view]
    public fun get_computer_move(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).computer_move
    }

    #[view]
    public fun get_game_results(account_addr: address): u8 acquires Game {
        borrow_global<Game>(account_addr).result
    }

    // Adding functions to retrieve the scores both the player or the computer
    #[view]
    public fun get_player_score(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).player_wins
    }

    #[view]
    public fun get_computer_score(account_addr: address): u64 acquires Game {
        borrow_global<Game>(account_addr).computer_wins
    }

}
}