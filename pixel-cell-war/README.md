# Pixel Cell War

- Game name: Pixel Cell War
- Source requirement: `E:\javacode\game-automation-repo\limits\final_15_games_c_cpp_r.md` (`Pixel Cell War`)
- Tech stack: C, Win32 API, GDI rendering, base R analysis script
- Tracking issue: https://github.com/weidonglang/game/issues/3

## Playable Windows EXE

The game builds to a directly clickable Windows executable:

```text
pixel-cell-war/pixel_cell_war.exe
```

Double-click the EXE to open the visual game window.

## Core Rules Implemented

- The game renders a 40x30 cell battlefield in a native Windows window.
- Red is the player faction. Blue and green are rival factions.
- Click any grid square to place or reinforce a red cell.
- Each simulation tick uses a double-buffer update:
  - empty cells can be colonized by nearby factions;
  - surrounded cells can be captured by a stronger neighboring faction;
  - isolated cells can die out;
  - small mutation events create instability in crowded areas.
- The match runs for 250 turns.
- Every turn is appended to `data/cell_counts.csv`.
- The HUD shows turn count, faction counts, winner state, and control buttons.

## Controls

- Left mouse click on grid: place red cell.
- `Space`: play or pause.
- `N`: advance one turn while paused.
- `R`: reset the board.
- `S`: add a red seed cluster near the center.
- `L`: toggle CSV logging.
- `Esc`: quit.

The on-screen buttons mirror the main controls:

- Play/Pause
- Step
- Reset
- Seed Red
- Log On/Off

## Build

```powershell
cd E:\javacode\game-automation-repo\pixel-cell-war
.\build.bat
```

Manual build:

```powershell
cd E:\javacode\game-automation-repo\pixel-cell-war
gcc .\src\main.c -Wall -Wextra -std=c99 -O2 -mwindows -lgdi32 -luser32 -o .\pixel_cell_war.exe
```

## Run

```powershell
cd E:\javacode\game-automation-repo\pixel-cell-war
.\pixel_cell_war.exe
```

Or double-click:

```text
E:\javacode\game-automation-repo\pixel-cell-war\pixel_cell_war.exe
```

## Verification

```powershell
cd E:\javacode\game-automation-repo\pixel-cell-war
.\pixel_cell_war.exe --self-test
```

The self-test runs 250 simulation ticks without opening the window and exits with code `0` if the board remains valid.

## R Analysis

If R is installed:

```powershell
cd E:\javacode\game-automation-repo
Rscript .\pixel-cell-war\analysis\plot_counts.R
```

The analysis script reads `pixel-cell-war/data/cell_counts.csv` and writes:

```text
pixel-cell-war/analysis/cell_counts.png
```

## Project Files

- `src/main.c`: Win32 window, GDI rendering, controls, simulation rules, CSV logging
- `build.bat`: MinGW build helper
- `pixel_cell_war.exe`: directly clickable Windows build
- `analysis/plot_counts.R`: base R chart generator
- `data/cell_counts.csv`: generated during play or self-test
