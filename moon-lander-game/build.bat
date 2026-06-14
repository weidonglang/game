@echo off
gcc .\src\main.c -o .\moon_lander.exe -lm
if errorlevel 1 exit /b 1
echo Built moon_lander.exe
