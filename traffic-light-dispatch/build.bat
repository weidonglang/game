@echo off
setlocal

if not exist src\main.cpp (
  echo src\main.cpp not found.
  exit /b 1
)

g++ .\src\main.cpp -Wall -Wextra -std=c++17 -O2 -mwindows -static -static-libgcc -static-libstdc++ -lgdi32 -luser32 -o .\traffic_light_dispatch.exe
if errorlevel 1 exit /b 1

echo Built traffic_light_dispatch.exe
