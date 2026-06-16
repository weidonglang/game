# Classic Mini Games Automation Repo

This repository collects small, low-dependency games implemented from the requirement notes in `limits/`.
Each game is kept in its own directory with build or run instructions and a minimal playable loop.

## Repository Structure

```text
.
|-- limits/                    # Game requirement notes and implementation status
|-- moon-lander-game/           # C terminal Moon Lander
|-- maze-runner-game/           # Python maze game with R analysis
|-- morse-radio-operator/       # HTML/CSS/JavaScript Morse radio game
|-- pixel-cell-war/             # Native Windows visual cell simulation EXE
|-- auto-git-push.ps1           # Windows helper script
|-- .gitignore
`-- README.md
```

## Implemented Games

| Game | Directory | Tech stack | Run entry |
| --- | --- | --- | --- |
| Moon Lander Mini Game | `moon-lander-game/` | C terminal UI | Build and run `moon_lander.exe` |
| Maze Runner Mini Game | `maze-runner-game/` | Python 3, Tkinter, R analysis | Run `main.py` |
| Morse Radio Operator | `morse-radio-operator/` | HTML, CSS, JavaScript, Web Audio API | Open `index.html` |
| Pixel Cell War | `pixel-cell-war/` | C, Win32 API, GDI, R analysis | Double-click `pixel_cell_war.exe` |

## Run Games

### Moon Lander Mini Game

```powershell
cd E:\javacode\game-automation-repo\moon-lander-game
.\build.bat
.\moon_lander.exe
```

### Maze Runner Mini Game

```powershell
cd E:\javacode\game-automation-repo
py -3 .\maze-runner-game\main.py
```

Self-test:

```powershell
cd E:\javacode\game-automation-repo
py -3 .\maze-runner-game\main.py --self-test
```

Optional R analysis:

```powershell
cd E:\javacode\game-automation-repo
Rscript .\maze-runner-game\analysis\analyze.R
```

### Morse Radio Operator

```powershell
cd E:\javacode\game-automation-repo\morse-radio-operator
start index.html
```

### Pixel Cell War

Double-click this file:

```text
E:\javacode\game-automation-repo\pixel-cell-war\pixel_cell_war.exe
```

Or run it from PowerShell:

```powershell
cd E:\javacode\game-automation-repo\pixel-cell-war
.\pixel_cell_war.exe
```

Build from source:

```powershell
cd E:\javacode\game-automation-repo\pixel-cell-war
.\build.bat
```

Self-test:

```powershell
cd E:\javacode\game-automation-repo\pixel-cell-war
$p = Start-Process -FilePath '.\pixel_cell_war.exe' -ArgumentList '--self-test' -Wait -PassThru
$p.ExitCode
```

Optional R analysis:

```powershell
cd E:\javacode\game-automation-repo
Rscript .\pixel-cell-war\analysis\plot_counts.R
```

## Automation Workflow

The repo is designed for small Codex-driven development passes:

- Pick one unfinished game requirement from `limits/`.
- Create a standalone game directory.
- Implement the minimum playable version.
- Add focused verification commands.
- Mark only the implemented requirement in the relevant `limits/*.md` file.

The Windows helper script `auto-git-push.ps1` can be run manually:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "E:\javacode\game-automation-repo\auto-git-push.ps1"
```

## Development Constraints

- Work on one game per change.
- Prefer small, dependency-light implementations.
- Do not create nested git repositories inside game directories.
- Do not commit generated automation logs.
- Do not use `git push --force`.

## Status Notes

`limits/` Markdown files are used as the source requirement list and implementation record.
When a game is implemented, mark only that game's section, for example:

```text
Status: implemented
Implemented in: <game-directory>/
```
