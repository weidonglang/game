@echo off
setlocal

if not exist src\main.cpp (
  echo src\main.cpp not found.
  exit /b 1
)

g++ .\src\main.cpp -Wall -Wextra -std=c++17 -O2 -mwindows -lgdi32 -luser32 -o .\reactor_cooling_crisis.exe
if errorlevel 1 exit /b 1

echo Built reactor_cooling_crisis.exe
