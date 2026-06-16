#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define GRID_W 40
#define GRID_H 30
#define CELL_SIZE 18
#define GRID_LEFT 24
#define GRID_TOP 76
#define PANEL_LEFT 770
#define WINDOW_W 980
#define WINDOW_H 680
#define MAX_TURNS 250
#define TIMER_ID 7
#define TIMER_MS 130
#define LOG_PATH "data\\cell_counts.csv"

typedef enum {
    FACTION_EMPTY = 0,
    FACTION_RED = 1,
    FACTION_BLUE = 2,
    FACTION_GREEN = 3
} Faction;

typedef struct {
    unsigned char faction;
    unsigned char strength;
    unsigned char age;
} Cell;

typedef struct {
    RECT rect;
    const char *label;
    int id;
} Button;

static Cell grid[GRID_H][GRID_W];
static Cell next_grid[GRID_H][GRID_W];
static int turn_count = 0;
static int running = 0;
static int logging_enabled = 1;
static int red_count = 0;
static int blue_count = 0;
static int green_count = 0;
static int empty_count = GRID_W * GRID_H;
static HWND main_window = NULL;

static Button buttons[] = {
    {{PANEL_LEFT, 92, PANEL_LEFT + 170, 126}, "Play / Pause", 1},
    {{PANEL_LEFT, 136, PANEL_LEFT + 170, 170}, "Step", 2},
    {{PANEL_LEFT, 180, PANEL_LEFT + 170, 214}, "Reset", 3},
    {{PANEL_LEFT, 224, PANEL_LEFT + 170, 258}, "Seed Red", 4},
    {{PANEL_LEFT, 268, PANEL_LEFT + 170, 302}, "Log On / Off", 5}
};

static int rand_between(int min_value, int max_value) {
    return min_value + rand() % (max_value - min_value + 1);
}

static COLORREF faction_color(int faction) {
    switch (faction) {
        case FACTION_RED: return RGB(214, 54, 54);
        case FACTION_BLUE: return RGB(47, 107, 255);
        case FACTION_GREEN: return RGB(37, 165, 90);
        default: return RGB(22, 24, 28);
    }
}

static void ensure_data_dir(void) {
    CreateDirectoryA("data", NULL);
}

static void count_cells(void) {
    red_count = blue_count = green_count = empty_count = 0;
    for (int y = 0; y < GRID_H; y++) {
        for (int x = 0; x < GRID_W; x++) {
            switch (grid[y][x].faction) {
                case FACTION_RED: red_count++; break;
                case FACTION_BLUE: blue_count++; break;
                case FACTION_GREEN: green_count++; break;
                default: empty_count++; break;
            }
        }
    }
}

static void append_log(void) {
    FILE *file;

    if (!logging_enabled) {
        return;
    }

    ensure_data_dir();
    file = fopen(LOG_PATH, "a+");
    if (file == NULL) {
        return;
    }

    fseek(file, 0, SEEK_END);
    if (ftell(file) == 0) {
        fprintf(file, "turn,red_cells,blue_cells,green_cells,empty_cells\n");
    }
    fprintf(file, "%d,%d,%d,%d,%d\n", turn_count, red_count, blue_count, green_count, empty_count);
    fclose(file);
}

static void clear_log(void) {
    ensure_data_dir();
    remove(LOG_PATH);
}

static void set_cell(int x, int y, int faction, int strength) {
    if (x < 0 || x >= GRID_W || y < 0 || y >= GRID_H) {
        return;
    }
    grid[y][x].faction = (unsigned char)faction;
    grid[y][x].strength = (unsigned char)strength;
    grid[y][x].age = 0;
}

static void seed_cluster(int cx, int cy, int faction) {
    for (int dy = -2; dy <= 2; dy++) {
        for (int dx = -2; dx <= 2; dx++) {
            if (abs(dx) + abs(dy) <= 3 && rand() % 100 < 75) {
                set_cell(cx + dx, cy + dy, faction, rand_between(4, 9));
            }
        }
    }
}

static void seed_red_center(void) {
    seed_cluster(GRID_W / 2, GRID_H / 2, FACTION_RED);
    count_cells();
    append_log();
}

static void reset_board(void) {
    memset(grid, 0, sizeof(grid));
    memset(next_grid, 0, sizeof(next_grid));
    turn_count = 0;
    running = 0;

    seed_cluster(5, 5, FACTION_BLUE);
    seed_cluster(GRID_W - 7, GRID_H - 6, FACTION_GREEN);
    seed_cluster(GRID_W - 8, 6, FACTION_BLUE);
    seed_cluster(7, GRID_H - 7, FACTION_GREEN);
    seed_red_center();

    clear_log();
    count_cells();
    append_log();
}

static int dominant_faction(int red, int blue, int green, int *dominant_count) {
    int faction = FACTION_EMPTY;
    int best = 0;
    if (red > best) {
        best = red;
        faction = FACTION_RED;
    }
    if (blue > best) {
        best = blue;
        faction = FACTION_BLUE;
    }
    if (green > best) {
        best = green;
        faction = FACTION_GREEN;
    }
    *dominant_count = best;
    return faction;
}

static void simulate_turn(void) {
    if (turn_count >= MAX_TURNS) {
        running = 0;
        return;
    }

    for (int y = 0; y < GRID_H; y++) {
        for (int x = 0; x < GRID_W; x++) {
            int counts[4] = {0, 0, 0, 0};
            int strength_sum[4] = {0, 0, 0, 0};
            Cell current = grid[y][x];
            int dominant_count = 0;
            int dominant;

            for (int dy = -1; dy <= 1; dy++) {
                for (int dx = -1; dx <= 1; dx++) {
                    int nx = x + dx;
                    int ny = y + dy;
                    int faction;
                    if (dx == 0 && dy == 0) {
                        continue;
                    }
                    if (nx < 0 || nx >= GRID_W || ny < 0 || ny >= GRID_H) {
                        continue;
                    }
                    faction = grid[ny][nx].faction;
                    if (faction != FACTION_EMPTY) {
                        counts[faction]++;
                        strength_sum[faction] += grid[ny][nx].strength;
                    }
                }
            }

            dominant = dominant_faction(counts[FACTION_RED], counts[FACTION_BLUE], counts[FACTION_GREEN], &dominant_count);
            next_grid[y][x] = current;

            if (current.faction == FACTION_EMPTY) {
                if (dominant != FACTION_EMPTY && dominant_count >= 2 && rand() % 100 < 42 + dominant_count * 6) {
                    next_grid[y][x].faction = (unsigned char)dominant;
                    next_grid[y][x].strength = (unsigned char)(3 + strength_sum[dominant] / (dominant_count * 2 + 1));
                    next_grid[y][x].age = 0;
                }
            } else {
                int own = counts[current.faction];
                int pressure = dominant == FACTION_EMPTY ? 0 : counts[dominant] - own;
                int age = current.age < 250 ? current.age + 1 : 250;
                int strength = current.strength;

                if (strength > 1 && rand() % 100 < 18) {
                    strength--;
                }
                if (own >= 2 && strength < 15 && rand() % 100 < 24) {
                    strength++;
                }

                next_grid[y][x].age = (unsigned char)age;
                next_grid[y][x].strength = (unsigned char)strength;

                if (own == 0 && rand() % 100 < 18) {
                    next_grid[y][x].faction = FACTION_EMPTY;
                    next_grid[y][x].strength = 0;
                    next_grid[y][x].age = 0;
                } else if (dominant != FACTION_EMPTY && dominant != current.faction && pressure >= 2) {
                    int attack_score = strength_sum[dominant] + rand_between(0, 12);
                    int defense_score = strength * (own + 1) + rand_between(0, 10);
                    if (attack_score > defense_score) {
                        next_grid[y][x].faction = (unsigned char)dominant;
                        next_grid[y][x].strength = (unsigned char)(4 + dominant_count);
                        next_grid[y][x].age = 0;
                    }
                } else if (own >= 5 && rand() % 100 < 2) {
                    next_grid[y][x].faction = (unsigned char)rand_between(1, 3);
                    next_grid[y][x].strength = 4;
                    next_grid[y][x].age = 0;
                }
            }
        }
    }

    memcpy(grid, next_grid, sizeof(grid));
    turn_count++;
    count_cells();
    append_log();
}

static const char *winner_text(void) {
    if (turn_count < MAX_TURNS) {
        return running ? "Simulating" : "Paused";
    }
    if (red_count >= blue_count && red_count >= green_count) return "Red controls the field";
    if (blue_count >= red_count && blue_count >= green_count) return "Blue controls the field";
    return "Green controls the field";
}

static void draw_text(HDC hdc, int x, int y, const char *text, int size, COLORREF color) {
    HFONT font = CreateFontA(size, 0, 0, 0, FW_SEMIBOLD, FALSE, FALSE, FALSE,
                             ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                             DEFAULT_QUALITY, DEFAULT_PITCH | FF_SWISS, "Segoe UI");
    HFONT old_font = (HFONT)SelectObject(hdc, font);
    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, color);
    TextOutA(hdc, x, y, text, (int)strlen(text));
    SelectObject(hdc, old_font);
    DeleteObject(font);
}

static void fill_rect(HDC hdc, RECT rect, COLORREF color) {
    HBRUSH brush = CreateSolidBrush(color);
    FillRect(hdc, &rect, brush);
    DeleteObject(brush);
}

static void draw_button(HDC hdc, const Button *button) {
    HPEN border = CreatePen(PS_SOLID, 1, RGB(75, 83, 96));
    HPEN old_pen = (HPEN)SelectObject(hdc, border);
    fill_rect(hdc, button->rect, RGB(42, 48, 58));
    SelectObject(hdc, GetStockObject(HOLLOW_BRUSH));
    Rectangle(hdc, button->rect.left, button->rect.top, button->rect.right, button->rect.bottom);
    draw_text(hdc, button->rect.left + 12, button->rect.top + 7, button->label, 18, RGB(235, 238, 244));
    SelectObject(hdc, old_pen);
    DeleteObject(border);
}

static void draw_bar(HDC hdc, int x, int y, int width, int count, COLORREF color, const char *label) {
    char text[80];
    RECT back = {x, y + 24, x + width, y + 42};
    RECT front = {x, y + 24, x + (count * width) / (GRID_W * GRID_H), y + 42};
    fill_rect(hdc, back, RGB(36, 39, 45));
    fill_rect(hdc, front, color);
    snprintf(text, sizeof(text), "%s: %d", label, count);
    draw_text(hdc, x, y, text, 17, RGB(232, 235, 240));
}

static void draw_scene(HDC hdc) {
    RECT bg = {0, 0, WINDOW_W, WINDOW_H};
    char text[128];
    HPEN grid_pen;
    HPEN old_pen;

    fill_rect(hdc, bg, RGB(14, 16, 20));
    draw_text(hdc, 24, 20, "Pixel Cell War", 30, RGB(245, 247, 250));
    draw_text(hdc, 24, 52, "Click the grid to grow red cells. Space toggles the simulation.", 17, RGB(176, 183, 194));

    grid_pen = CreatePen(PS_SOLID, 1, RGB(35, 39, 46));
    old_pen = (HPEN)SelectObject(hdc, grid_pen);

    for (int y = 0; y < GRID_H; y++) {
        for (int x = 0; x < GRID_W; x++) {
            RECT rect = {
                GRID_LEFT + x * CELL_SIZE,
                GRID_TOP + y * CELL_SIZE,
                GRID_LEFT + (x + 1) * CELL_SIZE,
                GRID_TOP + (y + 1) * CELL_SIZE
            };
            COLORREF color = faction_color(grid[y][x].faction);
            if (grid[y][x].faction != FACTION_EMPTY) {
                int shade = grid[y][x].strength * 4;
                if (shade > 36) shade = 36;
                color = RGB(GetRValue(color) + (255 - GetRValue(color)) * shade / 100,
                            GetGValue(color) + (255 - GetGValue(color)) * shade / 100,
                            GetBValue(color) + (255 - GetBValue(color)) * shade / 100);
            }
            fill_rect(hdc, rect, color);
            MoveToEx(hdc, rect.left, rect.top, NULL);
            LineTo(hdc, rect.right, rect.top);
            LineTo(hdc, rect.right, rect.bottom);
        }
    }

    SelectObject(hdc, old_pen);
    DeleteObject(grid_pen);

    draw_text(hdc, PANEL_LEFT, 24, "Controls", 25, RGB(245, 247, 250));
    draw_text(hdc, PANEL_LEFT, 55, "Mouse + buttons or keys", 16, RGB(176, 183, 194));

    for (unsigned int i = 0; i < sizeof(buttons) / sizeof(buttons[0]); i++) {
        draw_button(hdc, &buttons[i]);
    }

    snprintf(text, sizeof(text), "Turn: %d / %d", turn_count, MAX_TURNS);
    draw_text(hdc, PANEL_LEFT, 328, text, 19, RGB(245, 247, 250));
    snprintf(text, sizeof(text), "State: %s", winner_text());
    draw_text(hdc, PANEL_LEFT, 354, text, 18, RGB(210, 216, 224));
    snprintf(text, sizeof(text), "CSV log: %s", logging_enabled ? "on" : "off");
    draw_text(hdc, PANEL_LEFT, 380, text, 18, RGB(210, 216, 224));

    draw_bar(hdc, PANEL_LEFT, 424, 170, red_count, RGB(214, 54, 54), "Red");
    draw_bar(hdc, PANEL_LEFT, 474, 170, blue_count, RGB(47, 107, 255), "Blue");
    draw_bar(hdc, PANEL_LEFT, 524, 170, green_count, RGB(37, 165, 90), "Green");
    draw_bar(hdc, PANEL_LEFT, 574, 170, empty_count, RGB(117, 117, 117), "Empty");
}

static void click_grid(int px, int py) {
    int x = (px - GRID_LEFT) / CELL_SIZE;
    int y = (py - GRID_TOP) / CELL_SIZE;
    if (x < 0 || x >= GRID_W || y < 0 || y >= GRID_H) {
        return;
    }
    seed_cluster(x, y, FACTION_RED);
    count_cells();
    append_log();
    InvalidateRect(main_window, NULL, FALSE);
}

static void handle_button(int id) {
    if (id == 1) {
        running = !running;
    } else if (id == 2) {
        simulate_turn();
    } else if (id == 3) {
        reset_board();
    } else if (id == 4) {
        seed_red_center();
    } else if (id == 5) {
        logging_enabled = !logging_enabled;
    }
    InvalidateRect(main_window, NULL, FALSE);
}

static int button_at(int x, int y) {
    POINT point = {x, y};
    for (unsigned int i = 0; i < sizeof(buttons) / sizeof(buttons[0]); i++) {
        if (PtInRect(&buttons[i].rect, point)) {
            return buttons[i].id;
        }
    }
    return 0;
}

static LRESULT CALLBACK window_proc(HWND hwnd, UINT message, WPARAM w_param, LPARAM l_param) {
    switch (message) {
        case WM_CREATE:
            main_window = hwnd;
            reset_board();
            SetTimer(hwnd, TIMER_ID, TIMER_MS, NULL);
            return 0;
        case WM_TIMER:
            if (running) {
                simulate_turn();
                InvalidateRect(hwnd, NULL, FALSE);
            }
            return 0;
        case WM_LBUTTONDOWN: {
            int x = LOWORD(l_param);
            int y = HIWORD(l_param);
            int button = button_at(x, y);
            if (button != 0) {
                handle_button(button);
            } else {
                click_grid(x, y);
            }
            return 0;
        }
        case WM_KEYDOWN:
            if (w_param == VK_SPACE) running = !running;
            else if (w_param == 'N') simulate_turn();
            else if (w_param == 'R') reset_board();
            else if (w_param == 'S') seed_red_center();
            else if (w_param == 'L') logging_enabled = !logging_enabled;
            else if (w_param == VK_ESCAPE) DestroyWindow(hwnd);
            InvalidateRect(hwnd, NULL, FALSE);
            return 0;
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);
            HDC buffer_dc = CreateCompatibleDC(hdc);
            HBITMAP buffer = CreateCompatibleBitmap(hdc, WINDOW_W, WINDOW_H);
            HBITMAP old_bitmap = (HBITMAP)SelectObject(buffer_dc, buffer);
            draw_scene(buffer_dc);
            BitBlt(hdc, 0, 0, WINDOW_W, WINDOW_H, buffer_dc, 0, 0, SRCCOPY);
            SelectObject(buffer_dc, old_bitmap);
            DeleteObject(buffer);
            DeleteDC(buffer_dc);
            EndPaint(hwnd, &ps);
            return 0;
        }
        case WM_DESTROY:
            KillTimer(hwnd, TIMER_ID);
            PostQuitMessage(0);
            return 0;
        default:
            return DefWindowProc(hwnd, message, w_param, l_param);
    }
}

static int run_self_test(void) {
    srand(12345);
    reset_board();
    running = 0;
    for (int i = 0; i < MAX_TURNS; i++) {
        simulate_turn();
    }
    return (red_count + blue_count + green_count + empty_count == GRID_W * GRID_H) ? 0 : 1;
}

int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev_instance, LPSTR cmd_line, int show_cmd) {
    WNDCLASSA wc;
    HWND hwnd;
    MSG msg;

    (void)prev_instance;

    if (strstr(cmd_line, "--self-test") != NULL) {
        return run_self_test();
    }

    srand((unsigned int)time(NULL));

    memset(&wc, 0, sizeof(wc));
    wc.lpfnWndProc = window_proc;
    wc.hInstance = instance;
    wc.lpszClassName = "PixelCellWarWindow";
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);

    if (!RegisterClassA(&wc)) {
        MessageBoxA(NULL, "Could not register Pixel Cell War window.", "Pixel Cell War", MB_ICONERROR);
        return 1;
    }

    hwnd = CreateWindowExA(0,
                           wc.lpszClassName,
                           "Pixel Cell War",
                           WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX,
                           CW_USEDEFAULT,
                           CW_USEDEFAULT,
                           WINDOW_W,
                           WINDOW_H,
                           NULL,
                           NULL,
                           instance,
                           NULL);
    if (hwnd == NULL) {
        MessageBoxA(NULL, "Could not create Pixel Cell War window.", "Pixel Cell War", MB_ICONERROR);
        return 1;
    }

    ShowWindow(hwnd, show_cmd);
    UpdateWindow(hwnd);

    while (GetMessage(&msg, NULL, 0, 0) > 0) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}
