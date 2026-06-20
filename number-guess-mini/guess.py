import random


def check_guess(secret: int, guess: int) -> str:
    """Compare guess with secret and return result.

    Returns:
        "low"      if guess is smaller than secret
        "high"     if guess is larger than secret
        "correct"  if guess equals secret
    """
    if guess < secret:
        return "low"
    elif guess > secret:
        return "high"
    else:
        return "correct"


def main():
    secret = random.randint(1, 100)
    attempts = 0

    print("=== Number Guess Mini ===")
    print("I have picked a number between 1 and 100.")
    print("Enter 'q' or 'quit' to exit at any time.\n")

    while True:
        user_input = input("Your guess: ").strip()

        if user_input.lower() in ("q", "quit"):
            print(f"Goodbye! The number was {secret}.")
            break

        try:
            guess = int(user_input)
        except ValueError:
            print("Invalid input. Please enter a number (1-100), or 'q' to quit.\n")
            continue

        attempts += 1
        result = check_guess(secret, guess)

        if result == "low":
            print("Too low!\n")
        elif result == "high":
            print("Too high!\n")
        else:
            print(f"Correct! You guessed it in {attempts} tries.\n")
            break


if __name__ == "__main__":
    main()