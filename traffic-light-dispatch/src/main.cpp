#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>

#define WINDOW_W 1000
#define WINDOW_H 700
#define TIMER_ID 21
#define TIMER_MS 140
#define LOG_PATH "data\\traffic_log.csv"

struct Button { RECT rect; const char *label; int id; };
struct Sim {
    int time_sec;
    int queues[4];
    int wait_sum[4];
    int ns_green;
    int ew_green;
    int phase;
    int phase_timer;
    int paused;
    int logging;
    double avg_wait;
    double score;
};

static Sim sim;
static HWND main_window = NULL;
static Button buttons[] = {
    {{760, 105, 880, 139}, "NS -", 1},
    {{890, 105, 980, 139}, "NS +", 2},
    {{760, 155, 880, 189}, "EW -", 3},
    {{890, 155, 980, 189}, "EW +", 4},
    {{760, 220, 880, 254}, "Pause", 5},
    {{890, 220, 980, 254}, "Reset", 6},
    {{760, 270, 980, 304}, "Log On / Off", 7}
};

static int clamp_int(int v, int lo, int hi) { return std::max(lo, std::min(hi, v)); }
static double rand_unit() { return (double)rand() / (double)RAND_MAX; }

static void ensure_data_dir() { CreateDirectoryA("data", NULL); }
static const char *phase_name() { return sim.phase == 0 ? "NS_GREEN" : "EW_GREEN"; }

static void append_log() {
    if (!sim.logging) return;
    ensure_data_dir();
    FILE *f = fopen(LOG_PATH, "a+");
    if (!f) return;
    fseek(f, 0, SEEK_END);
    if (ftell(f) == 0) {
        fprintf(f, "time_sec,north_queue,south_queue,east_queue,west_queue,phase,avg_wait,ns_green,ew_green,score\n");
    }
    fprintf(f, "%d,%d,%d,%d,%d,%s,%.2f,%d,%d,%.2f\n",
            sim.time_sec, sim.queues[0], sim.queues[1], sim.queues[2], sim.queues[3],
            phase_name(), sim.avg_wait, sim.ns_green, sim.ew_green, sim.score);
    fclose(f);
}

static void reset_sim() {
    memset(&sim, 0, sizeof(sim));
    sim.ns_green = 24;
    sim.ew_green = 24;
    sim.phase = 0;
    sim.phase_timer = sim.ns_green;
    sim.logging = 1;
    ensure_data_dir();
    remove(LOG_PATH);
    append_log();
}

static void update_sim() {
    if (sim.paused) return;

    sim.time_sec++;
    double rush = (sim.time_sec % 90 > 52) ? 0.72 : 0.46;
    for (int i = 0; i < 4; ++i) {
        double bias = (i >= 2) ? 0.08 : 0.0;
        if (rand_unit() < rush + bias) {
            sim.queues[i] = clamp_int(sim.queues[i] + 1, 0, 80);
        }
        sim.wait_sum[i] += sim.queues[i];
    }

    int pass_dirs[2] = {sim.phase == 0 ? 0 : 2, sim.phase == 0 ? 1 : 3};
    for (int d : pass_dirs) {
        int leaving = std::min(sim.queues[d], 1 + (rand() % 2));
        sim.queues[d] -= leaving;
        sim.wait_sum[d] = std::max(0, sim.wait_sum[d] - leaving * 4);
    }

    sim.phase_timer--;
    if (sim.phase_timer <= 0) {
        sim.phase = 1 - sim.phase;
        sim.phase_timer = sim.phase == 0 ? sim.ns_green : sim.ew_green;
    }

    int q_total = 0;
    int w_total = 0;
    for (int i = 0; i < 4; ++i) {
        q_total += sim.queues[i];
        w_total += sim.wait_sum[i];
    }
    sim.avg_wait = q_total > 0 ? (double)w_total / (double)q_total : 0.0;
    sim.score = sim.avg_wait + q_total * 1.4;
    append_log();
}

static void fill_rect(HDC hdc, RECT r, COLORREF c) {
    HBRUSH b = CreateSolidBrush(c);
    FillRect(hdc, &r, b);
    DeleteObject(b);
}

static void draw_text(HDC hdc, int x, int y, const char *t, int size, COLORREF color, int weight = FW_SEMIBOLD) {
    HFONT f = CreateFontA(size, 0, 0, 0, weight, FALSE, FALSE, FALSE, ANSI_CHARSET,
                          OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
                          DEFAULT_PITCH | FF_SWISS, "Segoe UI");
    HFONT old = (HFONT)SelectObject(hdc, f);
    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, color);
    TextOutA(hdc, x, y, t, (int)strlen(t));
    SelectObject(hdc, old);
    DeleteObject(f);
}

static void draw_button(HDC hdc, Button b) {
    fill_rect(hdc, b.rect, RGB(45, 52, 64));
    HPEN p = CreatePen(PS_SOLID, 1, RGB(82, 92, 108));
    HPEN old = (HPEN)SelectObject(hdc, p);
    SelectObject(hdc, GetStockObject(HOLLOW_BRUSH));
    Rectangle(hdc, b.rect.left, b.rect.top, b.rect.right, b.rect.bottom);
    SelectObject(hdc, old);
    DeleteObject(p);
    draw_text(hdc, b.rect.left + 12, b.rect.top + 7, b.label, 17, RGB(239, 243, 249));
}

static void draw_queue(HDC hdc, int x, int y, int w, int h, int value, COLORREF color, const char *label) {
    char buf[64];
    RECT back = {x, y, x + w, y + h};
    RECT front = {x, y + h - std::min(h, value * 5), x + w, y + h};
    fill_rect(hdc, back, RGB(31, 36, 44));
    fill_rect(hdc, front, color);
    snprintf(buf, sizeof(buf), "%s %d", label, value);
    draw_text(hdc, x - 8, y + h + 10, buf, 17, RGB(222, 228, 238));
}

static void draw_scene(HDC hdc) {
    RECT bg = {0, 0, WINDOW_W, WINDOW_H};
    fill_rect(hdc, bg, RGB(13, 16, 21));
    draw_text(hdc, 28, 22, "Traffic Light Dispatch", 31, RGB(246, 248, 252));
    draw_text(hdc, 30, 58, "Tune signal timing to keep queues and waiting time low.", 17, RGB(172, 183, 198), FW_NORMAL);

    RECT road_ns = {310, 110, 460, 610};
    RECT road_ew = {135, 285, 635, 435};
    fill_rect(hdc, road_ns, RGB(46, 50, 58));
    fill_rect(hdc, road_ew, RGB(46, 50, 58));
    RECT center = {310, 285, 460, 435};
    fill_rect(hdc, center, RGB(61, 66, 75));

    COLORREF ns = sim.phase == 0 ? RGB(43, 190, 93) : RGB(212, 55, 55);
    COLORREF ew = sim.phase == 1 ? RGB(43, 190, 93) : RGB(212, 55, 55);
    RECT ns_light = {472, 250, 520, 280};
    RECT ew_light = {250, 445, 300, 475};
    fill_rect(hdc, ns_light, ns);
    fill_rect(hdc, ew_light, ew);
    draw_text(hdc, 526, 252, "N/S", 17, RGB(230, 236, 244));
    draw_text(hdc, 250, 480, "E/W", 17, RGB(230, 236, 244));

    draw_queue(hdc, 345, 100, 46, 150, sim.queues[0], RGB(43, 108, 176), "North");
    draw_queue(hdc, 385, 470, 46, 150, sim.queues[1], RGB(56, 161, 105), "South");
    draw_queue(hdc, 130, 330, 150, 46, sim.queues[2], RGB(221, 107, 32), "East");
    draw_queue(hdc, 490, 370, 150, 46, sim.queues[3], RGB(128, 90, 213), "West");

    char buf[128];
    draw_text(hdc, 760, 34, "Control Panel", 25, RGB(246, 248, 252));
    snprintf(buf, sizeof(buf), "Phase: %s (%ds)", phase_name(), sim.phase_timer);
    draw_text(hdc, 760, 68, buf, 18, RGB(190, 201, 215));
    for (Button b : buttons) draw_button(hdc, b);
    snprintf(buf, sizeof(buf), "NS green: %ds", sim.ns_green);
    draw_text(hdc, 760, 365, buf, 19, RGB(232, 238, 246));
    snprintf(buf, sizeof(buf), "EW green: %ds", sim.ew_green);
    draw_text(hdc, 760, 395, buf, 19, RGB(232, 238, 246));
    snprintf(buf, sizeof(buf), "Avg wait: %.1fs", sim.avg_wait);
    draw_text(hdc, 760, 435, buf, 21, RGB(232, 238, 246));
    snprintf(buf, sizeof(buf), "Congestion score: %.1f", sim.score);
    draw_text(hdc, 760, 468, buf, 21, sim.score > 120 ? RGB(255, 140, 140) : RGB(232, 238, 246));
    snprintf(buf, sizeof(buf), "Time: %ds", sim.time_sec);
    draw_text(hdc, 760, 515, buf, 18, RGB(190, 201, 215));
    draw_text(hdc, 760, 545, sim.logging ? "CSV logging: on" : "CSV logging: off", 18, RGB(190, 201, 215));
}

static int button_at(int x, int y) {
    POINT pt = {x, y};
    for (Button b : buttons) if (PtInRect(&b.rect, pt)) return b.id;
    return 0;
}

static void action(int id) {
    if (id == 1) sim.ns_green = clamp_int(sim.ns_green - 2, 8, 60);
    else if (id == 2) sim.ns_green = clamp_int(sim.ns_green + 2, 8, 60);
    else if (id == 3) sim.ew_green = clamp_int(sim.ew_green - 2, 8, 60);
    else if (id == 4) sim.ew_green = clamp_int(sim.ew_green + 2, 8, 60);
    else if (id == 5) sim.paused = !sim.paused;
    else if (id == 6) reset_sim();
    else if (id == 7) sim.logging = !sim.logging;
    InvalidateRect(main_window, NULL, FALSE);
}

static LRESULT CALLBACK wnd_proc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    switch (msg) {
        case WM_CREATE:
            main_window = hwnd;
            reset_sim();
            SetTimer(hwnd, TIMER_ID, TIMER_MS, NULL);
            return 0;
        case WM_TIMER:
            update_sim();
            InvalidateRect(hwnd, NULL, FALSE);
            return 0;
        case WM_LBUTTONDOWN: {
            int id = button_at(LOWORD(lp), HIWORD(lp));
            if (id) action(id);
            return 0;
        }
        case WM_KEYDOWN:
            if (wp == 'Q') action(1);
            else if (wp == 'W') action(2);
            else if (wp == 'A') action(3);
            else if (wp == 'S') action(4);
            else if (wp == VK_SPACE) action(5);
            else if (wp == 'R') action(6);
            else if (wp == 'L') action(7);
            else if (wp == VK_ESCAPE) DestroyWindow(hwnd);
            return 0;
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);
            HDC mem = CreateCompatibleDC(hdc);
            HBITMAP bmp = CreateCompatibleBitmap(hdc, WINDOW_W, WINDOW_H);
            HBITMAP old = (HBITMAP)SelectObject(mem, bmp);
            draw_scene(mem);
            BitBlt(hdc, 0, 0, WINDOW_W, WINDOW_H, mem, 0, 0, SRCCOPY);
            SelectObject(mem, old);
            DeleteObject(bmp);
            DeleteDC(mem);
            EndPaint(hwnd, &ps);
            return 0;
        }
        case WM_DESTROY:
            KillTimer(hwnd, TIMER_ID);
            PostQuitMessage(0);
            return 0;
        default:
            return DefWindowProc(hwnd, msg, wp, lp);
    }
}

static int self_test() {
    srand(13579);
    reset_sim();
    for (int i = 0; i < 240; ++i) update_sim();
    int total = sim.queues[0] + sim.queues[1] + sim.queues[2] + sim.queues[3];
    return total >= 0 && sim.time_sec == 240 ? 0 : 1;
}

int WINAPI WinMain(HINSTANCE inst, HINSTANCE, LPSTR cmd, int show) {
    if (strstr(cmd, "--self-test")) return self_test();
    srand((unsigned int)time(NULL));
    WNDCLASSA wc = {};
    wc.lpfnWndProc = wnd_proc;
    wc.hInstance = inst;
    wc.lpszClassName = "TrafficLightDispatchWindow";
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    if (!RegisterClassA(&wc)) return 1;
    HWND hwnd = CreateWindowExA(0, wc.lpszClassName, "Traffic Light Dispatch Challenge",
                                WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX,
                                CW_USEDEFAULT, CW_USEDEFAULT, WINDOW_W, WINDOW_H,
                                NULL, NULL, inst, NULL);
    if (!hwnd) return 1;
    ShowWindow(hwnd, show);
    UpdateWindow(hwnd);
    MSG m;
    while (GetMessage(&m, NULL, 0, 0) > 0) {
        TranslateMessage(&m);
        DispatchMessage(&m);
    }
    return (int)m.wParam;
}
