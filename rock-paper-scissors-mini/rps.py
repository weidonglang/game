import random


def decide_winner(player: str, computer: str) -> str:
    """Decide the winner of a rock-paper-scissors round.

    Args:
        player: The player's choice (rock, paper, scissors).
        computer: The computer's choice (rock, paper, scissors).

    Returns:
        'player' if player wins, 'computer' if computer wins,
        'draw' if same, 'invalid' if either input is invalid.
    """
    valid_choices = {"rock", "paper", "scissors"}
    player = player.strip().lower()
    computer = computer.strip().lower()

    if player not in valid_choices or computer not in valid_choices:
        return "invalid"

    if player == computer:
        return "draw"

    win_map = {
        "rock": "scissors",
        "paper": "rock",
        "scissors": "paper",
    }

    if win_map[player] == computer:
        return "player"
    return "computer"


def get_computer_choice() -> str:
    """Return a random choice for the computer."""
    return random.choice(["rock", "paper", "scissors"])


def main():
    print("=== Rock Paper Scissors Mini ===")
    print("Enter rock, paper, or scissors (or 'quit' to exit)")

    while True:
        player_input = input("\nYour choice: ").strip().lower()
        if player_input == "quit":
            print("Thanks for playing!")
            break

        computer = get_computer_choice()
        result = decide_winner(player_input, computer)

        if result == "invalid":
            print("Invalid choice. Please enter rock, paper, or scissors.")
            continue

        print(f"Computer chose: {computer}")
        if result == "draw":
            print("It's a draw!")
        elif result == "player":
            print("You win!")
        else:
            print("Computer wins!")


if __name__ == "__main__":
    main()