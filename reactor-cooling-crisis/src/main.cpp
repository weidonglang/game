#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <string>

#define WINDOW_W 1040
#define WINDOW_H 720
#define TIMER_ID 11
#define TIMER_MS 120
#define SHIFT_SECONDS 180.0
#define LOG_PATH "data\\reactor_log.csv"

struct Reactor {
    double time_sec;
    double temperature;
    double pressure;
    double cooling_flow;
    double rod_depth;
    double turbine_load;
    double power_output;
    double cooling_efficiency;
    double risk_score;
    int fault_timer;
    int running;
    int paused;
    int logging;
    int ended;
    char event[64];
};

struct Button {
    RECT rect;
    const char *label;
    int id;
};

static Reactor reactor;
static HWND main_window = NULL;

static Button buttons[] = {
    {{770, 104, 890, 138}, "Cooling -", 1},
    {{900, 104, 1020, 138}, "Cooling +", 2},
    {{770, 154, 890, 188}, "Rods Out", 3},
    {{900, 154, 1020, 188}, "Rods In", 4},
    {{770, 204, 890, 238}, "Load -", 5},
    {{900, 204, 1020, 238}, "Load +", 6},
    {{770, 270, 890, 304}, "Pause", 7},
    {{900, 270, 1020, 304}, "Reset", 8},
    {{770, 320, 1020, 354}, "Log On / Off", 9}
};

static double clamp_value(double value, double low, double high) {
    return std::max(low, std::min(high, value));
}

static double rand_unit(void) {
    return (double)rand() / (double)RAND_MAX;
}

static void ensure_data_dir(void) {
    CreateDirectoryA("data", NULL);
}

static void count_event(const char *event_name) {
    strncpy(reactor.event, event_name, sizeof(reactor.event) - 1);
    reactor.event[sizeof(reactor.event) - 1] = '\0';
}

static void append_log(void) {
    if (!reactor.logging) {
        return;
    }

    ensure_data_dir();
    FILE *file = fopen(LOG_PATH, "a+");
    if (file == NULL) {
        return;
    }

    fseek(file, 0, SEEK_END);
    if (ftell(file) == 0) {
        fprintf(file, "time_sec,temperature,cooling_flow,control_rod_depth,power_output,event,risk_score,pressure,turbine_load\n");
    }
    fprintf(file, "%.1f,%.2f,%.3f,%.3f,%.3f,%s,%.3f,%.2f,%.3f\n",
            reactor.time_sec,
            reactor.temperature,
            reactor.cooling_flow,
            reactor.rod_depth,
            reactor.power_output,
            reactor.event,
            reactor.risk_score,
            reactor.pressure,
            reactor.turbine_load);
    fclose(file);
}

static void clear_log(void) {
    ensure_data_dir();
    remove(LOG_PATH);
}

static void reset_reactor(void) {
    reactor.time_sec = 0.0;
    reactor.temperature = 620.0;
    reactor.pressure = 0.48;
    reactor.cooling_flow = 0.58;
    reactor.rod_depth = 0.34;
    reactor.turbine_load = 0.72;
    reactor.power_output = 0.72;
    reactor.cooling_efficiency = 1.0;
    reactor.risk_score = 0.18;
    reactor.fault_timer = 0;
    reactor.running = 1;
    reactor.paused = 0;
    reactor.logging = 1;
    reactor.ended = 0;
    count_event("startup");
    clear_log();
    append_log();
}

static void adjust_value(int id) {
    if (reactor.ended && id != 8) {
        return;
    }

    if (id == 1) reactor.cooling_flow = clamp_value(reactor.cooling_flow - 0.06, 0.0, 1.0);
    else if (id == 2) reactor.cooling_flow = clamp_value(reactor.cooling_flow + 0.06, 0.0, 1.0);
    else if (id == 3) reactor.rod_depth = clamp_value(reactor.rod_depth - 0.06, 0.0, 1.0);
    else if (id == 4) reactor.rod_depth = clamp_value(reactor.rod_depth + 0.06, 0.0, 1.0);
    else if (id == 5) reactor.turbine_load = clamp_value(reactor.turbine_load - 0.06, 0.2, 1.0);
    else if (id == 6) reactor.turbine_load = clamp_value(reactor.turbine_load + 0.06, 0.2, 1.0);
    else if (id == 7) reactor.paused = !reactor.paused;
    else if (id == 8) reset_reactor();
    else if (id == 9) reactor.logging = !reactor.logging;

    InvalidateRect(main_window, NULL, FALSE);
}

static void update_reactor(double dt) {
    if (reactor.paused || reactor.ended) {
        return;
    }

    count_event("normal");

    if (reactor.fault_timer > 0) {
        reactor.fault_timer--;
        reactor.cooling_efficiency = 0.58;
        count_event("cooling_fault");
    } else {
        reactor.cooling_efficiency = 1.0;
        if (rand_unit() < 0.006) {
            reactor.fault_timer = 55 + rand() % 70;
            reactor.cooling_efficiency = 0.58;
            count_event("cooling_fault");
        }
    }

    double heat = 5.0 + 18.0 * reactor.turbine_load + 8.0 * (1.0 - reactor.rod_depth);
    double cooling = 16.0 * reactor.cooling_flow * reactor.cooling_efficiency + 4.0 * reactor.rod_depth;
    double target_pressure = clamp_value((reactor.temperature - 500.0) / 330.0 + reactor.turbine_load * 0.22, 0.0, 1.35);
    double pressure_drift = (target_pressure - reactor.pressure) * 0.08;

    reactor.temperature += (heat - cooling) * dt * 2.2;
    reactor.temperature += (rand_unit() - 0.5) * 2.2;
    reactor.temperature = clamp_value(reactor.temperature, 420.0, 940.0);
    reactor.pressure = clamp_value(reactor.pressure + pressure_drift, 0.0, 1.35);
    reactor.power_output = clamp_value(reactor.turbine_load * (1.0 - reactor.rod_depth * 0.72) * (reactor.temperature / 650.0), 0.0, 1.2);

    double heat_risk = 0.0;
    if (reactor.temperature > 720.0) heat_risk += (reactor.temperature - 720.0) / 170.0;
    if (reactor.temperature < 520.0) heat_risk += (520.0 - reactor.temperature) / 150.0;
    double pressure_risk = reactor.pressure > 0.92 ? (reactor.pressure - 0.92) / 0.35 : 0.0;
    double fault_risk = reactor.fault_timer > 0 ? 0.18 : 0.0;
    reactor.risk_score = clamp_value(heat_risk + pressure_risk + fault_risk, 0.0, 1.0);

    reactor.time_sec += dt;

    if (reactor.temperature >= 875.0 || reactor.pressure >= 1.18) {
        reactor.ended = 1;
        reactor.running = 0;
        count_event("meltdown");
    } else if (reactor.temperature <= 455.0 || reactor.power_output <= 0.12) {
        reactor.ended = 1;
        reactor.running = 0;
        count_event("reactor_stall");
    } else if (reactor.time_sec >= SHIFT_SECONDS) {
        reactor.ended = 1;
        reactor.running = 0;
        count_event("shift_success");
    } else if (reactor.risk_score > 0.65 && strcmp(reactor.event, "cooling_fault") != 0) {
        count_event("risk_warning");
    }

    append_log();
}

static COLORREF blend(COLORREF a, COLORREF b, double t) {
    t = clamp_value(t, 0.0, 1.0);
    int r = (int)(GetRValue(a) + (GetRValue(b) - GetRValue(a)) * t);
    int g = (int)(GetGValue(a) + (GetGValue(b) - GetGValue(a)) * t);
    int bl = (int)(GetBValue(a) + (GetBValue(b) - GetBValue(a)) * t);
    return RGB(r, g, bl);
}

static void fill_rect(HDC hdc, RECT rect, COLORREF color) {
    HBRUSH brush = CreateSolidBrush(color);
    FillRect(hdc, &rect, brush);
    DeleteObject(brush);
}

static void draw_text(HDC hdc, int x, int y, const char *text, int size, COLORREF color, int weight = FW_SEMIBOLD) {
    HFONT font = CreateFontA(size, 0, 0, 0, weight, FALSE, FALSE, FALSE,
                             ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                             DEFAULT_QUALITY, DEFAULT_PITCH | FF_SWISS, "Segoe UI");
    HFONT old_font = (HFONT)SelectObject(hdc, font);
    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, color);
    TextOutA(hdc, x, y, text, (int)strlen(text));
    SelectObject(hdc, old_font);
    DeleteObject(font);
}

static void draw_bar(HDC hdc, int x, int y, int w, int h, double value, COLORREF color, const char *label, const char *value_text) {
    RECT back = {x, y, x + w, y + h};
    RECT front = {x, y, x + (int)(w * clamp_value(value, 0.0, 1.0)), y + h};
    RECT outline = back;
    HPEN pen = CreatePen(PS_SOLID, 1, RGB(75, 82, 95));
    HPEN old_pen = (HPEN)SelectObject(hdc, pen);
    fill_rect(hdc, back, RGB(35, 39, 47));
    fill_rect(hdc, front, color);
    SelectObject(hdc, GetStockObject(HOLLOW_BRUSH));
    Rectangle(hdc, outline.left, outline.top, outline.right, outline.bottom);
    draw_text(hdc, x, y - 26, label, 18, RGB(229, 234, 242));
    draw_text(hdc, x + w - 108, y - 26, value_text, 18, RGB(186, 195, 209));
    SelectObject(hdc, old_pen);
    DeleteObject(pen);
}

static void draw_button(HDC hdc, const Button &button) {
    HPEN pen = CreatePen(PS_SOLID, 1, RGB(78, 86, 100));
    HPEN old_pen = (HPEN)SelectObject(hdc, pen);
    fill_rect(hdc, button.rect, RGB(43, 50, 62));
    SelectObject(hdc, GetStockObject(HOLLOW_BRUSH));
    Rectangle(hdc, button.rect.left, button.rect.top, button.rect.right, button.rect.bottom);
    draw_text(hdc, button.rect.left + 12, button.rect.top + 7, button.label, 17, RGB(237, 241, 247));
    SelectObject(hdc, old_pen);
    DeleteObject(pen);
}

static void draw_core(HDC hdc) {
    int cx = 270;
    int cy = 338;
    int radius = 132;
    double heat_level = clamp_value((reactor.temperature - 500.0) / 360.0, 0.0, 1.0);
    COLORREF core_color = blend(RGB(52, 129, 246), RGB(232, 72, 54), heat_level);
    HBRUSH brush = CreateSolidBrush(core_color);
    HPEN ring = CreatePen(PS_SOLID, 8, RGB(92, 104, 122));
    HPEN old_pen = (HPEN)SelectObject(hdc, ring);
    HBRUSH old_brush = (HBRUSH)SelectObject(hdc, brush);
    Ellipse(hdc, cx - radius, cy - radius, cx + radius, cy + radius);
    SelectObject(hdc, old_brush);
    SelectObject(hdc, old_pen);
    DeleteObject(brush);
    DeleteObject(ring);

    int rod_top = cy - radius + 12;
    int rod_bottom = cy + radius - 12;
    int rod_len = (int)((rod_bottom - rod_top) * reactor.rod_depth);
    for (int i = 0; i < 5; i++) {
        int x = cx - 72 + i * 36;
        RECT slot = {x, rod_top, x + 16, rod_bottom};
        RECT rod = {x, rod_top, x + 16, rod_top + rod_len};
        fill_rect(hdc, slot, RGB(25, 28, 34));
        fill_rect(hdc, rod, RGB(132, 94, 214));
    }

    char text[96];
    snprintf(text, sizeof(text), "%.0f C", reactor.temperature);
    draw_text(hdc, cx - 42, cy - 13, text, 30, RGB(255, 255, 255));
}

static const char *status_text(void) {
    if (!reactor.ended && reactor.paused) return "Paused";
    if (!reactor.ended) return "Stabilize the reactor";
    if (strcmp(reactor.event, "shift_success") == 0) return "Shift complete";
    if (strcmp(reactor.event, "meltdown") == 0) return "Meltdown";
    return "Reactor stalled";
}

static void draw_scene(HDC hdc) {
    RECT bg = {0, 0, WINDOW_W, WINDOW_H};
    fill_rect(hdc, bg, RGB(12, 15, 20));

    draw_text(hdc, 28, 22, "Reactor Cooling Crisis", 31, RGB(246, 248, 252));
    draw_text(hdc, 30, 58, "Hold temperature and pressure steady for a 180-second shift.", 17, RGB(172, 183, 198), FW_NORMAL);

    draw_core(hdc);

    char value[80];
    snprintf(value, sizeof(value), "%.0f / 180 sec", reactor.time_sec);
    draw_bar(hdc, 560, 92, 170, 20, reactor.time_sec / SHIFT_SECONDS, RGB(49, 130, 206), "Shift Time", value);
    snprintf(value, sizeof(value), "%.0f C", reactor.temperature);
    draw_bar(hdc, 560, 154, 170, 20, (reactor.temperature - 420.0) / 520.0, blend(RGB(47, 107, 255), RGB(229, 62, 62), reactor.risk_score), "Temperature", value);
    snprintf(value, sizeof(value), "%.2f", reactor.pressure);
    draw_bar(hdc, 560, 216, 170, 20, reactor.pressure / 1.2, RGB(221, 107, 32), "Pressure", value);
    snprintf(value, sizeof(value), "%.0f%%", reactor.risk_score * 100.0);
    draw_bar(hdc, 560, 278, 170, 20, reactor.risk_score, RGB(229, 62, 62), "Risk", value);
    snprintf(value, sizeof(value), "%.0f%%", reactor.power_output * 100.0);
    draw_bar(hdc, 560, 340, 170, 20, reactor.power_output, RGB(47, 133, 90), "Power", value);
    snprintf(value, sizeof(value), "%.0f%%", reactor.cooling_flow * 100.0);
    draw_bar(hdc, 560, 402, 170, 20, reactor.cooling_flow, RGB(43, 108, 176), "Cooling", value);
    snprintf(value, sizeof(value), "%.0f%%", reactor.rod_depth * 100.0);
    draw_bar(hdc, 560, 464, 170, 20, reactor.rod_depth, RGB(128, 90, 213), "Rods", value);
    snprintf(value, sizeof(value), "%.0f%%", reactor.turbine_load * 100.0);
    draw_bar(hdc, 560, 526, 170, 20, reactor.turbine_load, RGB(214, 158, 46), "Turbine", value);

    draw_text(hdc, 770, 34, "Control Panel", 25, RGB(246, 248, 252));
    draw_text(hdc, 770, 64, "Q/W  A/S  Z/X  Space  R", 16, RGB(172, 183, 198), FW_NORMAL);
    for (const Button &button : buttons) {
        draw_button(hdc, button);
    }

    draw_text(hdc, 770, 398, "Status", 23, RGB(246, 248, 252));
    draw_text(hdc, 770, 432, status_text(), 24, reactor.risk_score > 0.7 ? RGB(255, 139, 139) : RGB(218, 226, 236));
    draw_text(hdc, 770, 472, "Last event", 18, RGB(172, 183, 198));
    draw_text(hdc, 770, 500, reactor.event, 19, RGB(232, 236, 242));
    draw_text(hdc, 770, 544, reactor.logging ? "CSV logging: on" : "CSV logging: off", 18, RGB(190, 201, 215));

    draw_text(hdc, 30, 610, "Goal: avoid meltdown, avoid stall, and finish the shift with stable output.", 17, RGB(186, 195, 209), FW_NORMAL);
}

static int button_at(int x, int y) {
    POINT point = {x, y};
    for (const Button &button : buttons) {
        if (PtInRect(&button.rect, point)) {
            return button.id;
        }
    }
    return 0;
}

static LRESULT CALLBACK window_proc(HWND hwnd, UINT message, WPARAM w_param, LPARAM l_param) {
    switch (message) {
        case WM_CREATE:
            main_window = hwnd;
            reset_reactor();
            SetTimer(hwnd, TIMER_ID, TIMER_MS, NULL);
            return 0;
        case WM_TIMER:
            update_reactor(1.0);
            InvalidateRect(hwnd, NULL, FALSE);
            return 0;
        case WM_LBUTTONDOWN: {
            int button = button_at(LOWORD(l_param), HIWORD(l_param));
            if (button != 0) {
                adjust_value(button);
            }
            return 0;
        }
        case WM_KEYDOWN:
            if (w_param == 'Q') adjust_value(1);
            else if (w_param == 'W') adjust_value(2);
            else if (w_param == 'A') adjust_value(3);
            else if (w_param == 'S') adjust_value(4);
            else if (w_param == 'Z') adjust_value(5);
            else if (w_param == 'X') adjust_value(6);
            else if (w_param == VK_SPACE) adjust_value(7);
            else if (w_param == 'R') adjust_value(8);
            else if (w_param == 'L') adjust_value(9);
            else if (w_param == VK_ESCAPE) DestroyWindow(hwnd);
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
    srand(24680);
    reset_reactor();
    reactor.logging = 1;
    for (int i = 0; i < 190 && !reactor.ended; i++) {
        if (reactor.temperature > 690.0) {
            reactor.cooling_flow = clamp_value(reactor.cooling_flow + 0.02, 0.0, 1.0);
            reactor.rod_depth = clamp_value(reactor.rod_depth + 0.01, 0.0, 1.0);
        } else if (reactor.temperature < 570.0) {
            reactor.cooling_flow = clamp_value(reactor.cooling_flow - 0.02, 0.0, 1.0);
            reactor.rod_depth = clamp_value(reactor.rod_depth - 0.01, 0.0, 1.0);
        }
        update_reactor(1.0);
    }
    return reactor.time_sec > 0.0 && reactor.temperature > 420.0 && reactor.temperature < 940.0 ? 0 : 1;
}

int WINAPI WinMain(HINSTANCE instance, HINSTANCE prev_instance, LPSTR cmd_line, int show_cmd) {
    (void)prev_instance;

    if (strstr(cmd_line, "--self-test") != NULL) {
        return run_self_test();
    }

    srand((unsigned int)time(NULL));

    WNDCLASSA wc;
    memset(&wc, 0, sizeof(wc));
    wc.lpfnWndProc = window_proc;
    wc.hInstance = instance;
    wc.lpszClassName = "ReactorCoolingCrisisWindow";
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hIcon = LoadIcon(NULL, IDI_WARNING);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);

    if (!RegisterClassA(&wc)) {
        MessageBoxA(NULL, "Could not register Reactor Cooling Crisis window.", "Reactor Cooling Crisis", MB_ICONERROR);
        return 1;
    }

    HWND hwnd = CreateWindowExA(0,
                                wc.lpszClassName,
                                "Reactor Cooling Crisis",
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
        MessageBoxA(NULL, "Could not create Reactor Cooling Crisis window.", "Reactor Cooling Crisis", MB_ICONERROR);
        return 1;
    }

    ShowWindow(hwnd, show_cmd);
    UpdateWindow(hwnd);

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0) > 0) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}
