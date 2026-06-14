import argparse
import csv
import os
import random
import sys
import time
import tkinter as tk
from collections import deque
from dataclasses import dataclass
from tkinter import messagebox


CELL_SIZE = 32
MAZE_WIDTH = 15
MAZE_HEIGHT = 15
WALL = "#"
PATH = " "
DATA_DIR = os.path.join(os.path.dirname(__file__), "data")
LOG_PATH = os.path.join(DATA_DIR, "path_log.csv")


@dataclass
class Position:
    x: int
    y: int


def generate_maze(width: int, height: int, seed: int | None = None) -> list[list[str]]:
    randomizer = random.Random(seed)
    grid_width = width * 2 + 1
    grid_height = height * 2 + 1
    maze = [[WALL for _ in range(grid_width)] for _ in range(grid_height)]
    visited = [[False for _ in range(width)] for _ in range(height)]

    def carve(cx: int, cy: int) -> None:
        visited[cy][cx] = True
        maze[cy * 2 + 1][cx * 2 + 1] = PATH
        directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        randomizer.shuffle(directions)

        for dx, dy in directions:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < width and 0 <= ny < height and not visited[ny][nx]:
                maze[cy * 2 + 1 + dy][cx * 2 + 1 + dx] = PATH
                carve(nx, ny)

    carve(0, 0)
    maze[1][0] = PATH
    maze[grid_height - 2][grid_width - 1] = PATH
    return maze


def shortest_path_length(maze: list[list[str]]) -> int:
    start = (1, 1)
    goal = (len(maze[0]) - 2, len(maze) - 2)
    queue = deque([(start[0], start[1], 0)])
    visited = {start}

    while queue:
        x, y, distance = queue.popleft()
        if (x, y) == goal:
            return distance

        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if maze[ny][nx] == PATH and (nx, ny) not in visited:
                visited.add((nx, ny))
                queue.append((nx, ny, distance + 1))

    raise ValueError("Generated maze is not solvable.")


class MazeRunnerGame:
    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title("Maze Runner Mini Game")
        self.root.resizable(False, False)

        self.info_var = tk.StringVar()
        self.status_var = tk.StringVar(value="Use WASD or arrow keys to move.")

        self.info_label = tk.Label(root, textvariable=self.info_var, anchor="w", justify="left")
        self.info_label.pack(fill="x", padx=8, pady=(8, 4))

        canvas_width = (MAZE_WIDTH * 2 + 1) * CELL_SIZE
        canvas_height = (MAZE_HEIGHT * 2 + 1) * CELL_SIZE
        self.canvas = tk.Canvas(root, width=canvas_width, height=canvas_height, bg="#111111", highlightthickness=0)
        self.canvas.pack(padx=8)

        controls = tk.Frame(root)
        controls.pack(fill="x", padx=8, pady=8)

        tk.Button(controls, text="Restart", command=self.start_new_game).pack(side="left")
        tk.Label(controls, textvariable=self.status_var, anchor="w").pack(side="left", padx=12)

        self.root.bind("<KeyPress>", self.on_key_press)

        self.maze: list[list[str]] = []
        self.player = Position(1, 1)
        self.goal = Position(0, 0)
        self.step_count = 0
        self.start_time = 0.0
        self.session_id = ""
        self.shortest_steps = 0
        self.path_history: list[tuple[int, int, float]] = []
        self.finished = False

        self.start_new_game()

    def start_new_game(self) -> None:
        self.maze = generate_maze(MAZE_WIDTH, MAZE_HEIGHT)
        self.player = Position(1, 1)
        self.goal = Position(len(self.maze[0]) - 2, len(self.maze) - 2)
        self.step_count = 0
        self.start_time = time.perf_counter()
        self.session_id = time.strftime("%Y%m%d%H%M%S")
        self.shortest_steps = shortest_path_length(self.maze)
        self.path_history = [(self.player.x, self.player.y, 0.0)]
        self.finished = False
        self.status_var.set("Reach the green exit.")
        self.update_info()
        self.draw()

    def update_info(self) -> None:
        elapsed = time.perf_counter() - self.start_time if not self.finished else self.path_history[-1][2]
        self.info_var.set(
            f"Steps: {self.step_count}    "
            f"Shortest: {self.shortest_steps}    "
            f"Elapsed: {elapsed:.1f}s"
        )

    def draw(self) -> None:
        self.canvas.delete("all")

        for y, row in enumerate(self.maze):
            for x, tile in enumerate(row):
                color = "#1f1f1f" if tile == WALL else "#f2efe6"
                self.canvas.create_rectangle(
                    x * CELL_SIZE,
                    y * CELL_SIZE,
                    (x + 1) * CELL_SIZE,
                    (y + 1) * CELL_SIZE,
                    fill=color,
                    outline=color,
                )

        self.canvas.create_rectangle(
            self.goal.x * CELL_SIZE,
            self.goal.y * CELL_SIZE,
            (self.goal.x + 1) * CELL_SIZE,
            (self.goal.y + 1) * CELL_SIZE,
            fill="#3c9d5d",
            outline="#3c9d5d",
        )

        self.canvas.create_oval(
            self.player.x * CELL_SIZE + 6,
            self.player.y * CELL_SIZE + 6,
            (self.player.x + 1) * CELL_SIZE - 6,
            (self.player.y + 1) * CELL_SIZE - 6,
            fill="#d94f3d",
            outline="#d94f3d",
        )

    def on_key_press(self, event: tk.Event) -> None:
        if self.finished:
            if event.keysym.lower() == "r":
                self.start_new_game()
            return

        moves = {
            "Up": (0, -1),
            "Down": (0, 1),
            "Left": (-1, 0),
            "Right": (1, 0),
            "w": (0, -1),
            "s": (0, 1),
            "a": (-1, 0),
            "d": (1, 0),
        }

        if event.keysym not in moves and event.keysym.lower() not in moves:
            return

        dx, dy = moves.get(event.keysym, moves.get(event.keysym.lower(), (0, 0)))
        next_x = self.player.x + dx
        next_y = self.player.y + dy

        if self.maze[next_y][next_x] == WALL:
            self.status_var.set("That move hits a wall.")
            return

        self.player = Position(next_x, next_y)
        self.step_count += 1
        elapsed = time.perf_counter() - self.start_time
        self.path_history.append((self.player.x, self.player.y, elapsed))
        self.status_var.set("Keep going.")
        self.update_info()
        self.draw()

        if self.player == self.goal:
            self.finish_game()

    def finish_game(self) -> None:
        self.finished = True
        total_time = self.path_history[-1][2]
        efficiency = self.shortest_steps / self.step_count if self.step_count else 1.0
        self.write_log()
        self.update_info()
        self.status_var.set("Finished. Press Restart or R to play again.")
        messagebox.showinfo(
            "Maze Complete",
            (
                f"You escaped the maze.\n\n"
                f"Steps: {self.step_count}\n"
                f"Shortest path: {self.shortest_steps}\n"
                f"Efficiency: {efficiency:.2%}\n"
                f"Time: {total_time:.1f}s\n\n"
                f"Log saved to:\n{LOG_PATH}"
            ),
        )

    def write_log(self) -> None:
        os.makedirs(DATA_DIR, exist_ok=True)
        file_exists = os.path.exists(LOG_PATH)
        with open(LOG_PATH, "a", newline="", encoding="utf-8") as csvfile:
            writer = csv.writer(csvfile)
            if not file_exists:
                writer.writerow(["session_id", "step", "x", "y", "timestamp", "shortest_path"])

            for index, (x, y, timestamp) in enumerate(self.path_history, start=1):
                writer.writerow([self.session_id, index, x, y, f"{timestamp:.3f}", self.shortest_steps])


def run_self_test() -> int:
    maze = generate_maze(MAZE_WIDTH, MAZE_HEIGHT, seed=42)
    shortest = shortest_path_length(maze)
    open_tiles = sum(tile == PATH for row in maze for tile in row)

    if shortest <= 0 or open_tiles <= 0:
        print("Maze self-test failed.")
        return 1

    print(f"Maze self-test passed. shortest_path={shortest} open_tiles={open_tiles}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Maze Runner mini game")
    parser.add_argument("--self-test", action="store_true", help="Run a non-GUI maze verification check")
    args = parser.parse_args(argv)

    if args.self_test:
        return run_self_test()

    try:
        root = tk.Tk()
    except tk.TclError as exc:
        print(f"Tkinter is unavailable: {exc}", file=sys.stderr)
        return 1

    MazeRunnerGame(root)
    root.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
