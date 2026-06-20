# C Lucky Wheel Mini

A terminal-based lucky wheel game written in C.

## How to Play

1. The wheel has 8 slots, each with a different prize.
2. Pick a slot number (1-8) to test your luck.
3. The wheel spins and lands on a random slot.
4. If your slot matches the winning slot, you win that prize!

## Files

| File | Description |
|------|-------------|
| `lucky_wheel.c` | Lucky wheel game source code |

## Compilation

```bash
gcc -std=c99 -Wall -Wextra -pedantic lucky_wheel.c -o lucky_wheel.exe
```

## Usage

```bash
./lucky_wheel.exe
```

## How to Exit

Type `q` at any prompt, or press Ctrl+C / Ctrl+D.