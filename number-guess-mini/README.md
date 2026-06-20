# Number Guess Mini

A minimal Python terminal number guessing game.

## Gameplay

The program randomly picks an integer between 1 and 100.
You enter numbers to guess. It tells you if your guess is **too low**, **too high**, or **correct**.
Enter `q` or `quit` at any time to exit.

## How to Run

```bash
python number-guess-mini/guess.py
```

Or navigate into the directory:

```bash
cd number-guess-mini
python guess.py
```

## How to Test

```bash
python -m unittest discover number-guess-mini
```

Or inside the directory:

```bash
python -m unittest
```

## Files

| File          | Description                              |
|---------------|------------------------------------------|
| `guess.py`    | Main game script with `check_guess()` fn |
| `test_guess.py` | Unit tests using Python `unittest`     |
| `README.md`   | This file                                |