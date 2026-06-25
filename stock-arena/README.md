# Stock Arena

- Game name: Stock Arena
- Source requirement: `E:\javacode\game-automation-repo\limits\final_15_games_c_cpp_r.md` (`Stock Arena`)
- Tech stack: C++, Win32 API, GDI rendering, base R analysis
- Tracking issue: https://github.com/weidonglang/game/issues/33

## Playable Windows EXE

```text
stock-arena/stock_arena.exe
```

Double-click the EXE to open the trading desk.

## Core Rules Implemented

- Trade three assets over a 60-day season.
- Each asset has a trend, volatility, and daily news shock.
- Use buy and sell buttons to adjust holdings.
- Cash, holdings, portfolio value, and daily event text are visible in the window.
- Daily logs are written to `data/portfolio_log.csv`.

## Controls

- Click Buy/Sell buttons for ALPHA, BETA, and GAMMA.
- `N`: advance one day.
- `R`: reset.
- `L`: toggle CSV logging.
- `Esc`: quit.

## Build

```powershell
cd E:\javacode\game-automation-repo\stock-arena
.\build.bat
```

## Run

```powershell
cd E:\javacode\game-automation-repo\stock-arena
.\stock_arena.exe
```

## Verification

```powershell
cd E:\javacode\game-automation-repo\stock-arena
$p = Start-Process -FilePath '.\stock_arena.exe' -ArgumentList '--self-test' -Wait -PassThru
$p.ExitCode
```

## R Analysis

```powershell
cd E:\javacode\game-automation-repo
Rscript .\stock-arena\analysis\plot_portfolio.R
```

The script writes `stock-arena/analysis/portfolio_curve.png`.
