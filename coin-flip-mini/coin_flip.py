#!/usr/bin/env python3
"""Coin Flip Mini - A simple terminal coin flip guessing game."""

import random


def normalize_choice(choice: str) -> str:
    """Normalize and validate user input.

    Supports "heads"/"h" and "tails"/"t", case-insensitive,
    with leading/trailing whitespace stripped.
    Returns "heads", "tails", or "invalid".
    """
    mapping = {
        "heads": "heads",
        "h": "heads",
        "tails": "tails",
        "t": "tails",
    }
    return mapping.get(choice.strip().lower(), "invalid")


def flip_coin() -> str:
    """Randomly return "heads" or "tails"."""
    return random.choice(["heads", "tails"])


def decide_result(player_choice: str, coin_result: str) -> str:
    """Determine if the player won, lost, or made an invalid choice.

    Returns "win", "lose", or "invalid".
    """
    if player_choice == "invalid":
        return "invalid"
    if player_choice == coin_result:
        return "win"
    return "lose"


def main() -> None:
    """Run the Coin Flip Mini CLI game."""
    print("=" * 40)
    print("       Coin Flip Mini - Guess the Coin!")
    print("=" * 40)
    print("Guess heads (h) or tails (t). Enter 'q' to quit.\n")

    while True:
        try:
            user_input = input("Your guess (heads/tails/h/t): ").strip()
        except EOFError:
            print()
            break

        if user_input.lower() in ("q", "quit"):
            print("Thanks for playing!")
            break

        player_choice = normalize_choice(user_input)
        if player_choice == "invalid":
            print("Invalid input. Please enter 'heads', 'tails', 'h', or 't'.")
            continue

        coin_result = flip_coin()
        result = decide_result(player_choice, coin_result)

        print(f"The coin shows: {coin_result}")
        if result == "win":
            print("You win! 🎉")
        else:
            print("You lose! Better luck next time.")

        print("-" * 40)
        print()


if __name__ == "__main__":
    main()