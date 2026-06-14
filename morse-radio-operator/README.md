# Morse Radio Operator

- Game name: `Morse Radio Operator`
- Source requirement: `E:\javacode\game-automation-repo\limits\third_batch_unrestricted_game_ideas.md`
- Tech stack: zero-dependency HTML, CSS, and JavaScript using the browser Web Audio API

## Core Rules Implemented

- The player tunes a radio dial toward the target mission frequency.
- Each mission plays a Morse transmission with simulated static.
- The player enters dot/dash Morse symbols, uses gaps between letters and words, and submits a decoded answer.
- The game checks the decoded text, tracks elapsed time, and awards points.
- Ten fixed missions are included to match the document's MVP requirement for multiple Morse phrases.

## How To Run

Open [`index.html`](E:/javacode/game-automation-repo/morse-radio-operator/index.html) in a browser.

Two simple Windows options:

```powershell
cd E:\javacode\game-automation-repo\morse-radio-operator
start index.html
```

Or:

```powershell
explorer.exe E:\javacode\game-automation-repo\morse-radio-operator\index.html
```

## Controls

- `Play Signal`: replay the current Morse transmission
- `.`: input dot
- `-`: input dash
- `Space`: letter gap
- `/`: word gap
- `Enter`: submit the current decode
- `Clear Input`: clear the current Morse sequence
- `Restart Mission`: restart the current mission timer and input

## Main Files

- `index.html`: UI layout for the radio console
- `style.css`: compact visual styling and responsive layout
- `script.js`: mission data, Morse encode/decode logic, tuning feedback, waveform display, and Web Audio playback

## Notes

- This MVP keeps the project dependency-free and directly runnable from the repository.
- Browser audio typically starts only after a user interaction, so click `Play Signal` once to begin.
