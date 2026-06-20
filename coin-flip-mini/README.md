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

## How to Exit

Type `q` or `quit` at any prompt, or press Ctrl+C / Ctrl+D.