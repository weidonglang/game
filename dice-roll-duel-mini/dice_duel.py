import random


def decide_round(player_total: int, computer_total: int) -> str:
    """Decide the winner of a dice duel round.

    Args:
        player_total: Sum of player's two dice.
        computer_total: Sum of computer's two dice.

    Returns:
        'player' if player wins, 'computer' if computer wins,
        'draw' if totals are equal.
    """
    if player_total > computer_total:
        return "player"
    elif computer_total > player_total:
        return "computer"
    else:
        return "draw"


def roll_two_dice() -> int:
    """Roll two six-sided dice and return the total."""
    return random.randint(1, 6) + random.randint(1, 6)


def main():
    print("=== Dice Roll Duel Mini ===")
    print("You and the computer each roll two six-sided dice.")
    print("Highest total wins! (or 'quit' to exit)\n")

    round_num = 1
    player_score = 0
    computer_score = 0

    while True:
        input(f"Round {round_num}: Press Enter to roll...")
        player_total = roll_two_dice()
        computer_total = roll_two_dice()

        print(f"  You rolled: {player_total}")
        print(f"  Computer rolled: {computer_total}")

        result = decide_round(player_total, computer_total)
        if result == "player":
            print("  You win this round!")
            player_score += 1
        elif result == "computer":
            print("  Computer wins this round!")
            computer_score += 1
        else:
            print("  It's a draw!")

        print(f"  Score: You {player_score} - Computer {computer_score}\n")

        again = input("Play another round? (y/n): ").strip().lower()
        if again != "y":
            print("Thanks for playing!")
            break

        round_num += 1


if __name__ == "__main__":
    main()