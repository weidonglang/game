# Coin Flip Mini

A simple terminal-based coin flip guessing game built with Python standard library.

## How to Play

1. Run the game.
2. Guess whether the coin will land on **heads** or **tails**.
3. You can type the full word (`heads` / `tails`) or the abbreviation (`h` / `t`).
4. The game will flip a virtual coin and tell you if you won or lost.

## Files

| File | Description |
|------|-------------|
| `coin_flip.py` | Core game logic and CLI entry point |
| `test_coin_flip.py` | Unit tests using `unittest` |
| `README.md` | This documentation |

## How to Run

```bash
python coin-flip-mini/coin_flip.py
```

## How to Test

```bash
python -m unittest discover coin-flip-mini
```

## Example Input and Output

```
========================================
       Coin Flip Mini - Guess the Coin!
========================================
Guess heads (h) or tails (t). Enter 'q' to quit.

Your guess (heads/tails/h/t): heads
The coin shows: tails
You lose! Better luck next time.
----------------------------------------

Your guess (heads/tails/h/t): t
The coin shows: tails
You win! 🎉
----------------------------------------

Your guess (heads/tails/h/t): q
Thanks for playing!
```

## How to Exit

- Type `q` or `quit` at the prompt, then press Enter.
- Press `Ctrl+C` (KeyboardInterrupt) to exit immediately.
- Press `Ctrl+D` (EOF) on an empty line to exit gracefully.

## Notes

- No external dependencies required.
- Python 3.6+ recommended for f-string support.
- All game logic is contained in a single module for simplicity.