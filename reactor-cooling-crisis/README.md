# Reactor Cooling Crisis

- Game name: Reactor Cooling Crisis
- Source requirement: `E:\javacode\game-automation-repo\limits\final_15_games_c_cpp_r.md` (`Reactor Cooling Crisis`)
- Tech stack: C++, Win32 API, GDI rendering, base R analysis
- Tracking issue: https://github.com/weidonglang/game/issues/5

## Playable Windows EXE

Build output:

```text
reactor-cooling-crisis/reactor_cooling_crisis.exe
```

Double-click the EXE to open the visual reactor control room.

## Core Rules Implemented

- Keep the reactor in a stable operating band for 180 seconds.
- Temperature, pressure, power output, cooling flow, control rod depth, turbine load, and risk are updated every tick.
- Random cooling efficiency drops can happen during play.
- Overheating or excessive pressure causes meltdown.
- Too much control rod insertion or too little turbine load can cause a stall.
- CSV telemetry is written to `data/reactor_log.csv`.

## Controls

- Cooling: `Q` decreases, `W` increases.
- Rod depth: `A` withdraws rods, `S` inserts rods.
- Turbine load: `Z` decreases, `X` increases.
- `Space`: pause or resume.
- `R`: reset.
- `L`: toggle CSV logging.
- `Esc`: quit.

The window also has clickable buttons for each control.

## Build

```powershell
cd E:\javacode\game-automation-repo\reactor-cooling-crisis
.\build.bat
```

Manual build:

```powershell
cd E:\javacode\game-automation-repo\reactor-cooling-crisis
g++ .\src\main.cpp -Wall -Wextra -std=c++17 -O2 -mwindows -lgdi32 -luser32 -o .\reactor_cooling_crisis.exe
```

## Run

```powershell
cd E:\javacode\game-automation-repo\reactor-cooling-crisis
.\reactor_cooling_crisis.exe
```

Or double-click:

```text
E:\javacode\game-automation-repo\reactor-cooling-crisis\reactor_cooling_crisis.exe
```

## Verification

```powershell
cd E:\javacode\game-automation-repo\reactor-cooling-crisis
$p = Start-Process -FilePath '.\reactor_cooling_crisis.exe' -ArgumentList '--self-test' -Wait -PassThru
$p.ExitCode
```

The self-test simulates a full 180-second shift without opening the window.

## R Analysis

```powershell
cd E:\javacode\game-automation-repo
Rscript .\reactor-cooling-crisis\analysis\plot_reactor.R
```

The script reads `reactor-cooling-crisis/data/reactor_log.csv` and writes:

```text
reactor-cooling-crisis/analysis/reactor_curves.png
```

## Project Files

- `src/main.cpp`: Win32 visual game, reactor simulation, controls, CSV logging
- `build.bat`: MinGW build helper
- `reactor_cooling_crisis.exe`: directly clickable Windows build
- `analysis/plot_reactor.R`: base R telemetry plotter
