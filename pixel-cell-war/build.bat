@echo off
setlocal

if not exist src\main.c (
  echo src\main.c not found.
  exit /b 1
)

gcc .\src\main.c -Wall -Wextra -std=c99 -O2 -mwindows -lgdi32 -luser32 -o .\pixel_cell_war.exe
if errorlevel 1 exit /b 1

echo Built pixel_cell_war.exe
