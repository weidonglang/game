#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>

#define WINDOW_W 1020
#define WINDOW_H 700
#define LOG_PATH "data\\portfolio_log.csv"
#define MAX_DAYS 60

struct Asset {
    const char *name;
    double price;
    double trend;
    double volatility;
    int shares;
    double last_change;
};

struct Button { RECT rect; const char *label; int id; };

static Asset assets[3] = {
    {"ALPHA", 100.0, 0.004, 0.035, 0, 0.0},
    {"BETA", 74.0, 0.002, 0.050, 0, 0.0},
    {"GAMMA", 132.0, -0.001, 0.028, 0, 0.0}
};
static double cash = 10000.0;
static int day_no = 1;
static int logging_enabled = 1;
static char news[128] = "Opening bell. Build a portfolio before day 60.";
static HWND main_window = NULL;

static Button buttons[] = {
    {{700, 110, 790, 144}, "Buy A", 1}, {{805, 110, 900, 144}, "Sell A", 2},
    {{700, 180, 790, 214}, "Buy B", 3}, {{805, 180, 900, 214}, "Sell B", 4},
    {{700, 250, 790, 284}, "Buy G", 5}, {{805, 250, 900, 284}, "Sell G", 6},
    {{700, 330, 900, 366}, "Next Day", 7},
    {{700, 382, 900, 418}, "Reset", 8},
    {{700, 434, 900, 470}, "Log On / Off", 9}
};

static double rand_unit() { return (double)rand() / (double)RAND_MAX; }
static double clamp_d(double v, double lo, double hi) { return std::max(lo, std::min(hi, v)); }

static double portfolio_value() {
    double value = cash;
    for (const Asset &a : assets) value += a.price * a.shares;
    return value;
}

static void ensure_data_dir() { CreateDirectoryA("data", NULL); }

static void append_log(const char *action) {
    if (!logging_enabled) return;
    ensure_data_dir();
    FILE *f = fopen(LOG_PATH, "a+");
    if (!f) return;
    fseek(f, 0, SEEK_END);
    if (ftell(f) == 0) {
        fprintf(f, "day,cash,portfolio_value,alpha_price,beta_price,gamma_price,alpha_shares,beta_shares,gamma_shares,action\n");
    }
    fprintf(f, "%d,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%d,%d,%s\n",
            day_no, cash, portfolio_value(), assets[0].price, assets[1].price, assets[2].price,
            assets[0].shares, assets[1].shares, assets[2].shares, action);
    fclose(f);
}

static void reset_game() {
    assets[0] = {"ALPHA", 100.0, 0.004, 0.035, 0, 0.0};
    assets[1] = {"BETA", 74.0, 0.002, 0.050, 0, 0.0};
    assets[2] = {"GAMMA", 132.0, -0.001, 0.028, 0, 0.0};
    cash = 10000.0;
    day_no = 1;
    logging_enabled = 1;
    strcpy(news, "Opening bell. Build a portfolio before day 60.");
    ensure_data_dir();
    remove(LOG_PATH);
    append_log("reset");
}

static void trade(int idx, int dir) {
    if (idx < 0 || idx >= 3 || day_no > MAX_DAYS) return;
    Asset &a = assets[idx];
    if (dir > 0) {
        int qty = 5;
        double cost = qty * a.price;
        if (cash >= cost) {
            cash -= cost;
            a.shares += qty;
            snprintf(news, sizeof(news), "Bought 5 shares of %s.", a.name);
            append_log("buy");
        }
    } else {
        int qty = std::min(5, a.shares);
        if (qty > 0) {
            cash += qty * a.price;
            a.shares -= qty;
            snprintf(news, sizeof(news), "Sold %d shares of %s.", qty, a.name);
            append_log("sell");
        }
    }
    InvalidateRect(main_window, NULL, FALSE);
}

static void next_day() {
    if (day_no >= MAX_DAYS) {
        snprintf(news, sizeof(news), "Season complete. Final value: %.0f.", portfolio_value());
        append_log("hold");
        return;
    }
    day_no++;
    int event_asset = rand() % 3;
    double event = (rand_unit() < 0.28) ? ((rand_unit() < 0.5) ? -0.09 : 0.11) : 0.0;
    for (int i = 0; i < 3; ++i) {
        double noise = (rand_unit() - 0.5) * 2.0 * assets[i].volatility;
        double shock = (i == event_asset) ? event : 0.0;
        double change = assets[i].trend + noise + shock;
        assets[i].price = clamp_d(assets[i].price * (1.0 + change), 8.0, 500.0);
        assets[i].last_change = change;
    }
    if (event != 0.0) {
        snprintf(news, sizeof(news), "%s news shock: %.1f%%.", assets[event_asset].name, event * 100.0);
    } else {
        snprintf(news, sizeof(news), "Quiet market day. Watch drift and volatility.");
    }
    append_log("hold");
    InvalidateRect(main_window, NULL, FALSE);
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
    fill_rect(hdc, b.rect, RGB(43, 50, 62));
    HPEN p = CreatePen(PS_SOLID, 1, RGB(78, 88, 104));
    HPEN old = (HPEN)SelectObject(hdc, p);
    SelectObject(hdc, GetStockObject(HOLLOW_BRUSH));
    Rectangle(hdc, b.rect.left, b.rect.top, b.rect.right, b.rect.bottom);
    SelectObject(hdc, old);
    DeleteObject(p);
    draw_text(hdc, b.rect.left + 11, b.rect.top + 7, b.label, 17, RGB(238, 242, 248));
}

static void draw_asset(HDC hdc, int i, int y, COLORREF color) {
    char buf[128];
    Asset &a = assets[i];
    RECT card = {28, y, 650, y + 92};
    fill_rect(hdc, card, RGB(29, 34, 43));
    snprintf(buf, sizeof(buf), "%s", a.name);
    draw_text(hdc, 48, y + 15, buf, 22, RGB(246, 248, 252));
    snprintf(buf, sizeof(buf), "Price %.2f   Change %.1f%%", a.price, a.last_change * 100.0);
    draw_text(hdc, 165, y + 17, buf, 19, a.last_change >= 0 ? RGB(88, 190, 120) : RGB(232, 90, 90));
    snprintf(buf, sizeof(buf), "Shares %d   Position %.0f", a.shares, a.shares * a.price);
    draw_text(hdc, 48, y + 52, buf, 18, RGB(190, 201, 215));
    RECT bar = {420, y + 48, 620, y + 66};
    RECT front = {420, y + 48, 420 + (int)clamp_d(a.price / 2.5, 0, 200), y + 66};
    fill_rect(hdc, bar, RGB(42, 47, 56));
    fill_rect(hdc, front, color);
}

static void draw_scene(HDC hdc) {
    RECT bg = {0, 0, WINDOW_W, WINDOW_H};
    fill_rect(hdc, bg, RGB(12, 15, 20));
    draw_text(hdc, 28, 22, "Stock Arena", 32, RGB(246, 248, 252));
    draw_text(hdc, 30, 58, "Trade three assets over 60 days. Buy dips, sell strength, survive volatility.", 17, RGB(172, 183, 198), FW_NORMAL);
    draw_asset(hdc, 0, 105, RGB(43, 108, 176));
    draw_asset(hdc, 1, 220, RGB(221, 107, 32));
    draw_asset(hdc, 2, 335, RGB(128, 90, 213));

    char buf[160];
    snprintf(buf, sizeof(buf), "Day %d / %d", day_no, MAX_DAYS);
    draw_text(hdc, 700, 34, buf, 25, RGB(246, 248, 252));
    snprintf(buf, sizeof(buf), "Cash: %.0f", cash);
    draw_text(hdc, 700, 64, buf, 20, RGB(190, 201, 215));
    snprintf(buf, sizeof(buf), "Portfolio: %.0f", portfolio_value());
    draw_text(hdc, 700, 90, buf, 20, portfolio_value() >= 10000 ? RGB(92, 210, 140) : RGB(245, 132, 132));
    for (Button b : buttons) draw_button(hdc, b);
    draw_text(hdc, 28, 485, "Market News", 23, RGB(246, 248, 252));
    draw_text(hdc, 28, 522, news, 20, RGB(220, 226, 236));
    draw_text(hdc, 28, 590, "Keys: N next day, R reset, L logging, Esc quit.", 17, RGB(172, 183, 198), FW_NORMAL);
    draw_text(hdc, 700, 495, logging_enabled ? "CSV logging: on" : "CSV logging: off", 18, RGB(190, 201, 215));
}

static int button_at(int x, int y) {
    POINT pt = {x, y};
    for (Button b : buttons) if (PtInRect(&b.rect, pt)) return b.id;
    return 0;
}

static void action(int id) {
    if (id >= 1 && id <= 6) trade((id - 1) / 2, id % 2 == 1 ? 1 : -1);
    else if (id == 7) next_day();
    else if (id == 8) reset_game();
    else if (id == 9) logging_enabled = !logging_enabled;
    InvalidateRect(main_window, NULL, FALSE);
}

static LRESULT CALLBACK wnd_proc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    switch (msg) {
        case WM_CREATE:
            main_window = hwnd;
            reset_game();
            return 0;
        case WM_LBUTTONDOWN: {
            int id = button_at(LOWORD(lp), HIWORD(lp));
            if (id) action(id);
            return 0;
        }
        case WM_KEYDOWN:
            if (wp == 'N') action(7);
            else if (wp == 'R') action(8);
            else if (wp == 'L') action(9);
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
            PostQuitMessage(0);
            return 0;
        default:
            return DefWindowProc(hwnd, msg, wp, lp);
    }
}

static int self_test() {
    srand(97531);
    reset_game();
    for (int i = 0; i < 15; ++i) trade(i % 3, 1);
    for (int d = 0; d < MAX_DAYS - 1; ++d) {
        if (d % 7 == 0) trade(d % 3, -1);
        next_day();
    }
    return day_no == MAX_DAYS && portfolio_value() > 0 ? 0 : 1;
}

int WINAPI WinMain(HINSTANCE inst, HINSTANCE, LPSTR cmd, int show) {
    if (strstr(cmd, "--self-test")) return self_test();
    srand((unsigned int)time(NULL));
    WNDCLASSA wc = {};
    wc.lpfnWndProc = wnd_proc;
    wc.hInstance = inst;
    wc.lpszClassName = "StockArenaWindow";
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    if (!RegisterClassA(&wc)) return 1;
    HWND hwnd = CreateWindowExA(0, wc.lpszClassName, "Stock Arena",
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
