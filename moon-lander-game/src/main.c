#include <ctype.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define GRAVITY 1.62
#define THRUST_ACCEL 3.20
#define ANGLE_STEP 5.0
#define DT 1.0
#define MAX_INPUT 32

typedef struct Lander {
    double altitude;
    double velocity;
    double fuel;
    double angle;
    int step;
} Lander;

static void clear_screen(void) {
    printf("\033[2J\033[H");
}

static void print_meter(const char *label, double value, double max_value) {
    int width = 20;
    int filled = 0;
    int i = 0;

    if (max_value > 0.0) {
        filled = (int)round((value / max_value) * width);
    }

    if (filled < 0) {
        filled = 0;
    }
    if (filled > width) {
        filled = width;
    }

    printf("%-8s [", label);
    for (i = 0; i < width; ++i) {
        putchar(i < filled ? '#' : '.');
    }
    printf("] %6.1f\n", value);
}

static void init_lander(Lander *lander) {
    lander->altitude = 120.0;
    lander->velocity = 0.0;
    lander->fuel = 60.0;
    lander->angle = 0.0;
    lander->step = 0;
}

static void print_status(const Lander *lander) {
    clear_screen();
    printf("Moon Lander Mini Game\n");
    printf("=====================\n\n");
    printf("Goal: land with |velocity| < 3 and |angle| < 5.\n");
    printf("Controls: [W] thrust  [A] tilt left  [D] tilt right  [Enter] coast  [Q] quit\n\n");
    printf("Step: %d\n", lander->step);
    print_meter("Altitude", lander->altitude, 120.0);
    print_meter("Fuel", lander->fuel, 60.0);
    printf("Velocity: %6.2f m/s\n", lander->velocity);
    printf("Angle:    %6.2f deg\n\n", lander->angle);
}

static bool apply_command(Lander *lander, const char *input) {
    char command = '\0';
    double thrust = 0.0;
    double net_accel = 0.0;
    double vertical_factor = 0.0;

    if (input[0] != '\0') {
        command = (char)tolower((unsigned char)input[0]);
    }

    if (command == 'q') {
        return false;
    }

    if (command == 'a') {
        lander->angle -= ANGLE_STEP;
        if (lander->angle < -45.0) {
            lander->angle = -45.0;
        }
    } else if (command == 'd') {
        lander->angle += ANGLE_STEP;
        if (lander->angle > 45.0) {
            lander->angle = 45.0;
        }
    }

    if (command == 'w' && lander->fuel > 0.0) {
        thrust = THRUST_ACCEL;
        lander->fuel -= 1.0;
        if (lander->fuel < 0.0) {
            lander->fuel = 0.0;
        }
    }

    vertical_factor = cos(lander->angle * (3.14159265358979323846 / 180.0));
    net_accel = GRAVITY - (thrust * vertical_factor);
    lander->velocity += net_accel * DT;
    lander->altitude -= lander->velocity * DT;
    lander->step += 1;

    return true;
}

static void print_outcome(const Lander *lander) {
    bool safe_velocity = fabs(lander->velocity) < 3.0;
    bool safe_angle = fabs(lander->angle) < 5.0;

    printf("\nFinal velocity: %.2f m/s\n", lander->velocity);
    printf("Final angle: %.2f deg\n", lander->angle);

    if (safe_velocity && safe_angle) {
        printf("Result: Safe landing.\n");
    } else {
        printf("Result: Crash landing.\n");
    }
}

static bool prompt_restart(void) {
    char input[MAX_INPUT];

    printf("\nPlay again? (y/n): ");
    if (fgets(input, sizeof(input), stdin) == NULL) {
        return false;
    }

    return input[0] == 'y' || input[0] == 'Y';
}

int main(void) {
    Lander lander;
    char input[MAX_INPUT];
    bool running = true;

    while (running) {
        init_lander(&lander);

        while (lander.altitude > 0.0) {
            print_status(&lander);
            printf("Command: ");

            if (fgets(input, sizeof(input), stdin) == NULL) {
                return 0;
            }

            if (!apply_command(&lander, input)) {
                printf("\nMission aborted.\n");
                return 0;
            }
        }

        if (lander.altitude < 0.0) {
            lander.altitude = 0.0;
        }

        print_status(&lander);
        print_outcome(&lander);
        running = prompt_restart();
    }

    printf("\nSession ended.\n");
    return 0;
}
