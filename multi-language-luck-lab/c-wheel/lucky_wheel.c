/*
 * lucky_wheel.c - Lucky Wheel Mini Game
 *
 * A simple terminal lucky wheel game where the player picks a slot
 * (1-8) and the program randomly spins the wheel to see if they win.
 *
 * Compilation: gcc -std=c99 -Wall -Wextra -pedantic lucky_wheel.c -o lucky_wheel.exe
 * Usage:       ./lucky_wheel.exe
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <string.h>

#define SLOT_COUNT 8

/* Prize names for the 8 wheel slots */
static const char *prizes[SLOT_COUNT] = {
    "Try Again",
    "Small Prize - 10 points",
    "Lose a Turn",
    "Medium Prize - 50 points",
    "Bankrupt",
    "Large Prize - 100 points",
    "Free Spin",
    "Jackpot - 500 points"
};

/*
 * Normalize player input.
 * Accepts 1-8, returns value as int, or -1 for invalid input.
 */
int normalize_slot(const char *input)
{
    int i;
    size_t len;

    if (input == NULL || input[0] == '\0')
        return -1;

    len = strlen(input);

    /* Check for leading/trailing spaces */
    while (len > 0 && isspace((unsigned char)input[0])) {
        input++;
        len--;
    }
    while (len > 0 && isspace((unsigned char)input[len - 1]))
        len--;

    if (len == 0)
        return -1;

    /* Check all characters are digits */
    for (i = 0; i < (int)len; i++) {
        if (!isdigit((unsigned char)input[i]))
            return -1;
    }

    /* Check for overflow by comparing length to max digits for int */
    if (len > 2)
        return -1;

    i = atoi(input);
    if (i < 1 || i > SLOT_COUNT)
        return -1;

    return i;
}

/*
 * Spin the wheel and return a random slot number (1 to SLOT_COUNT).
 */
int spin_wheel(void)
{
    return (rand() % SLOT_COUNT) + 1;
}

/*
 * Determine if the player's slot matches the winning slot.
 * Returns 1 for win, 0 for loss.
 */
int is_winning_slot(int player_slot, int winning_slot)
{
    return (player_slot == winning_slot) ? 1 : 0;
}

/*
 * Display the prize table.
 */
void print_prizes(void)
{
    int i;

    printf("\n--- Lucky Wheel Prize Table ---\n");
    for (i = 0; i < SLOT_COUNT; i++) {
        printf("  Slot %d: %s\n", i + 1, prizes[i]);
    }
    printf("--------------------------------\n\n");
}

/*
 * Main game loop.
 */
int main(void)
{
    char input[64];
    int player_slot, winning_slot;
    int keep_playing = 1;

    /* Seed the random number generator */
    srand((unsigned int)time(NULL));

    printf("========================================\n");
    printf("       Lucky Wheel Mini - C Edition\n");
    printf("========================================\n");
    printf("Pick a lucky slot (1-%d) and test your luck!\n", SLOT_COUNT);
    printf("Enter 'q' to quit.\n");

    print_prizes();

    while (keep_playing) {
        printf("Your lucky slot (1-%d): ", SLOT_COUNT);

        if (fgets(input, sizeof(input), stdin) == NULL) {
            printf("\n");
            break;
        }

        /* Remove trailing newline */
        {
            size_t len = strlen(input);
            if (len > 0 && input[len - 1] == '\n')
                input[len - 1] = '\0';
        }

        /* Check for quit */
        if (input[0] == 'q' || input[0] == 'Q') {
            printf("Thanks for playing! Goodbye.\n");
            break;
        }

        player_slot = normalize_slot(input);
        if (player_slot == -1) {
            printf("Invalid input. Please enter a number between 1 and %d.\n",
                   SLOT_COUNT);
            continue;
        }

        winning_slot = spin_wheel();
        printf("The wheel spins... landing on Slot %d!\n", winning_slot);
        printf("Prize: %s\n", prizes[winning_slot - 1]);

        if (is_winning_slot(player_slot, winning_slot)) {
            printf("Congratulations! You guessed correctly! You win %s!\n",
                   prizes[winning_slot - 1]);
        } else {
            printf("Not this time. You picked Slot %d, but the winner was Slot %d.\n",
                   player_slot, winning_slot);
        }

        printf("--------------------------------\n\n");
    }

    return 0;
}