# Moon Lander Mini Game

- Game name: Moon Lander Mini Game
- Source requirement: `E:\javacode\limits\final_15_games_c_cpp_r.md`
- Tech stack: C, terminal UI, no external dependencies

## Core Rules Implemented

- The lander tracks altitude, vertical velocity, fuel, and angle through `struct Lander`.
- Each turn updates the lander using gravity and optional thrust.
- Controls:
  - `W`: apply thrust and consume fuel
  - `A`: tilt left by 5 degrees
  - `D`: tilt right by 5 degrees
  - `Enter`: coast for one step
  - `Q`: quit
- Safe landing condition:
  - `|velocity| < 3`
  - `|angle| < 5`
- The game shows a landing result and supports restarting after each run.

## How To Run

### Option 1: build script

```powershell
cd E:\javacode\moon-lander-game
.\build.bat
.\moon_lander.exe
```

### Option 2: direct compile

```powershell
cd E:\javacode\moon-lander-game
gcc .\src\main.c -o .\moon_lander.exe -lm
.\moon_lander.exe
```

## Project Files

- `src/main.c`: game loop and landing logic
- `build.bat`: local build helper for MinGW GCC
- `README.md`: run instructions and implemented rules
