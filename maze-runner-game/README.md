# Maze Runner Mini Game

- Game name: Maze Runner Mini Game
- Source requirement: `E:\javacode\game-automation-repo\limits\ten_multilanguage_games_with_r.md` (`Maze Runner Analytics`)
- Tech stack: Python 3 standard library (`tkinter`, `csv`), base R analysis script

## Core Rules Implemented

- A new 15x15 maze is generated each run.
- The player starts at the maze entrance and must reach the green exit.
- Controls:
  - `W/A/S/D` or arrow keys: move one tile
  - `R`: restart after finishing
- The game tracks step count, elapsed time, and the shortest path length for the current maze.
- Completing a run appends the full movement path to `data/path_log.csv`.
- A minimal R script reads the CSV and renders a visit heatmap to `analysis/path_heatmap.png`.

## How To Run

### Play the game

```powershell
cd E:\javacode\game-automation-repo
py -3 .\maze-runner-game\main.py
```

If the Python launcher is unavailable on this machine, this interpreter path also works:

```powershell
cd E:\javacode\game-automation-repo
C:\Users\WDL\AppData\Local\Programs\Python\Python311\python.exe .\maze-runner-game\main.py
```

### Run the non-GUI verification check

```powershell
cd E:\javacode\game-automation-repo
py -3 .\maze-runner-game\main.py --self-test
```

Alternative explicit interpreter:

```powershell
cd E:\javacode\game-automation-repo
C:\Users\WDL\AppData\Local\Programs\Python\Python311\python.exe .\maze-runner-game\main.py --self-test
```

### Generate the R heatmap

If `Rscript` is installed and on `PATH`:

```powershell
cd E:\javacode\game-automation-repo
Rscript .\maze-runner-game\analysis\analyze.R
```

## Project Files

- `main.py`: maze generation, keyboard controls, win detection, and CSV logging
- `analysis/analyze.R`: reads `data/path_log.csv` and creates a heatmap PNG with base R
- `data/path_log.csv`: generated after completed runs

## Notes

- This MVP keeps the full core loop in Python to stay zero-dependency and easy to run in the current workspace.
- The R analysis script is included, but it requires a local R installation to execute.
