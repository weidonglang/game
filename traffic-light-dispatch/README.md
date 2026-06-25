# Traffic Light Dispatch Challenge

- Game name: Traffic Light Dispatch Challenge
- Source requirement: `E:\javacode\game-automation-repo\limits\final_15_games_c_cpp_r.md` (`Traffic Light Dispatch Challenge`)
- Tech stack: C++, Win32 API, GDI rendering, base R analysis
- Tracking issue: https://github.com/weidonglang/game/issues/31

## Playable Windows EXE

```text
traffic-light-dispatch/traffic_light_dispatch.exe
```

Double-click the EXE to open the visual intersection control room.

## Core Rules Implemented

- Four directions generate vehicles every simulated second.
- The active signal phase alternates between north/south and east/west.
- The player adjusts NS and EW green durations to reduce queues and waiting time.
- Cars leave only when their direction has a green phase.
- A congestion score tracks average wait and queue pressure.
- Runtime telemetry is written to `data/traffic_log.csv`.

## Controls

- `Q/W`: decrease/increase NS green duration.
- `A/S`: decrease/increase EW green duration.
- `Space`: pause/resume.
- `R`: reset.
- `L`: toggle CSV logging.
- `Esc`: quit.

The same controls are available as on-screen buttons.

## Build

```powershell
cd E:\javacode\game-automation-repo\traffic-light-dispatch
.\build.bat
```

## Run

```powershell
cd E:\javacode\game-automation-repo\traffic-light-dispatch
.\traffic_light_dispatch.exe
```

## Verification

```powershell
cd E:\javacode\game-automation-repo\traffic-light-dispatch
$p = Start-Process -FilePath '.\traffic_light_dispatch.exe' -ArgumentList '--self-test' -Wait -PassThru
$p.ExitCode
```

## R Analysis

```powershell
cd E:\javacode\game-automation-repo
Rscript .\traffic-light-dispatch\analysis\plot_traffic.R
```

The script reads `traffic-light-dispatch/data/traffic_log.csv` and writes `traffic-light-dispatch/analysis/traffic_wait.png`.
