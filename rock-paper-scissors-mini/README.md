# Rock Paper Scissors Mini

A minimal Python terminal rock-paper-scissors game.

## How to Play

Run the game:

```bash
python rock-paper-scissors-mini/rps.py
```

Enter `rock`, `paper`, or `scissors` to play against the computer. Type `quit` to exit.

## Core Function

```python
def decide_winner(player: str, computer: str) -> str:
```

Returns `'player'`, `'computer'`, `'draw'`, or `'invalid'`.

## Run Tests

```bash
python -m unittest discover rock-paper-scissors-mini