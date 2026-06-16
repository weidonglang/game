@echo off
setlocal

if not exist src\main.c (
  echo src\main.c not found.
  exit /b 1
)

gcc .\src\main.c -Wall -Wextra -std=c99 -O2 -o .\dice_duel.exe
if errorlevel 1 exit /b 1

echo Built dice_duel.exe
