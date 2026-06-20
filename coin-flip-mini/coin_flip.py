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
    return "heads"


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
    pass


if __name__ == "__main__":
    main()