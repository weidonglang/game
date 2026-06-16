#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define START_HP 30
#define MAX_ROUNDS 80
#define LOG_PATH "data/duel_log.csv"

typedef enum {
    SKILL_STEADY = 1,
    SKILL_HEAVY = 2,
    SKILL_GUARD = 3,
    SKILL_CHARGE = 4
} Skill;

typedef struct {
    int hp;
    int charge;
} Fighter;

typedef struct {
    int roll;
    int damage;
    int block;
    int charge_gain;
    const char *note;
} SkillResult;

static int roll_die(int sides) {
    return (rand() % sides) + 1;
}

static int roll_many(int dice, int sides) {
    int total = 0;
    for (int i = 0; i < dice; i++) {
        total += roll_die(sides);
    }
    return total;
}

static const char *skill_name(Skill skill) {
    switch (skill) {
        case SKILL_STEADY: return "Steady Strike";
        case SKILL_HEAVY: return "Heavy Blow";
        case SKILL_GUARD: return "Guard";
        case SKILL_CHARGE: return "Charge";
        default: return "Unknown";
    }
}

static SkillResult resolve_skill(Skill skill, Fighter *actor) {
    SkillResult result = {0, 0, 0, 0, ""};
    int stored_charge = actor->charge;

    switch (skill) {
        case SKILL_STEADY:
            result.roll = roll_many(2, 6);
            result.damage = result.roll + stored_charge;
            actor->charge = 0;
            result.note = "Reliable damage";
            break;
        case SKILL_HEAVY:
            result.roll = roll_die(20);
            if (result.roll < 6) {
                result.damage = 0;
                result.note = "Miss";
            } else {
                result.damage = result.roll + stored_charge;
                result.note = result.roll >= 18 ? "Critical hit" : "Risky hit";
            }
            actor->charge = 0;
            break;
        case SKILL_GUARD:
            result.roll = roll_die(8);
            result.block = result.roll + stored_charge / 2;
            result.damage = 2;
            actor->charge = 0;
            result.note = "Block and counter";
            break;
        case SKILL_CHARGE:
            result.roll = roll_die(4);
            result.damage = 1;
            result.charge_gain = result.roll + 2;
            actor->charge += result.charge_gain;
            if (actor->charge > 18) {
                actor->charge = 18;
            }
            result.note = "Stored power";
            break;
        default:
            break;
    }

    return result;
}

static Skill choose_enemy_skill(const Fighter *enemy, const Fighter *player) {
    if (enemy->hp <= 8 && rand() % 100 < 45) {
        return SKILL_GUARD;
    }
    if (enemy->charge >= 8) {
        return (rand() % 100 < 65) ? SKILL_HEAVY : SKILL_STEADY;
    }
    if (player->hp <= 10 && rand() % 100 < 55) {
        return SKILL_HEAVY;
    }
    if (rand() % 100 < 25) {
        return SKILL_CHARGE;
    }
    return (rand() % 100 < 60) ? SKILL_STEADY : SKILL_HEAVY;
}

static Skill choose_auto_player_skill(const Fighter *player, const Fighter *enemy) {
    if (player->hp <= 9 && rand() % 100 < 55) {
        return SKILL_GUARD;
    }
    if (player->charge >= 9) {
        return SKILL_HEAVY;
    }
    if (enemy->hp <= 8) {
        return SKILL_STEADY;
    }
    if (rand() % 100 < 30) {
        return SKILL_CHARGE;
    }
    return (rand() % 100 < 70) ? SKILL_STEADY : SKILL_HEAVY;
}

static void ensure_data_dir(void) {
#ifdef _WIN32
    system("if not exist data mkdir data >nul 2>nul");
#else
    system("mkdir -p data >/dev/null 2>/dev/null");
#endif
}

static void append_log_header_if_needed(FILE *file) {
    long pos;
    fseek(file, 0, SEEK_END);
    pos = ftell(file);
    if (pos == 0) {
        fprintf(file, "game_id,round,player_skill,enemy_skill,player_roll,enemy_roll,player_damage,enemy_damage,player_block,enemy_block,player_hp,enemy_hp,result\n");
    }
}

static FILE *open_log_file(void) {
    ensure_data_dir();
    FILE *file = fopen(LOG_PATH, "a+");
    if (file != NULL) {
        append_log_header_if_needed(file);
    }
    return file;
}

static int read_skill_choice(void) {
    char buffer[32];
    int choice;

    while (1) {
        printf("\nChoose skill:\n");
        printf("1. Steady Strike 2d6\n");
        printf("2. Heavy Blow 1d20\n");
        printf("3. Guard 1d8\n");
        printf("4. Charge\n");
        printf("Q. Quit\n");
        printf("> ");

        if (fgets(buffer, sizeof(buffer), stdin) == NULL) {
            return 0;
        }
        if (buffer[0] == 'q' || buffer[0] == 'Q') {
            return 0;
        }
        choice = atoi(buffer);
        if (choice >= 1 && choice <= 4) {
            return choice;
        }
        printf("Please choose 1, 2, 3, 4, or Q.\n");
    }
}

static void print_round_state(int round, const Fighter *player, const Fighter *enemy) {
    printf("\n=== Round %d ===\n", round);
    printf("Your HP: %d  Charge: %d\n", player->hp, player->charge);
    printf("Enemy HP: %d  Charge: %d\n", enemy->hp, enemy->charge);
}

static int play_game(int automated, FILE *log_file, int game_id, int verbose) {
    Fighter player = {START_HP, 0};
    Fighter enemy = {START_HP, 0};
    int round = 1;
    const char *result = "draw";

    while (player.hp > 0 && enemy.hp > 0 && round <= MAX_ROUNDS) {
        Skill player_skill;
        Skill enemy_skill;
        SkillResult player_result;
        SkillResult enemy_result;
        int damage_to_enemy;
        int damage_to_player;

        if (verbose) {
            print_round_state(round, &player, &enemy);
        }

        player_skill = automated ? choose_auto_player_skill(&player, &enemy) : (Skill)read_skill_choice();
        if (player_skill == 0) {
            result = "quit";
            break;
        }
        enemy_skill = choose_enemy_skill(&enemy, &player);

        player_result = resolve_skill(player_skill, &player);
        enemy_result = resolve_skill(enemy_skill, &enemy);

        damage_to_enemy = player_result.damage - enemy_result.block;
        damage_to_player = enemy_result.damage - player_result.block;
        if (damage_to_enemy < 0) damage_to_enemy = 0;
        if (damage_to_player < 0) damage_to_player = 0;

        enemy.hp -= damage_to_enemy;
        player.hp -= damage_to_player;
        if (enemy.hp < 0) enemy.hp = 0;
        if (player.hp < 0) player.hp = 0;

        if (verbose) {
            printf("You used %s: roll=%d, damage=%d, block=%d, %s\n",
                   skill_name(player_skill), player_result.roll, player_result.damage,
                   player_result.block, player_result.note);
            printf("Enemy used %s: roll=%d, damage=%d, block=%d, %s\n",
                   skill_name(enemy_skill), enemy_result.roll, enemy_result.damage,
                   enemy_result.block, enemy_result.note);
            printf("Damage dealt: you -> enemy %d, enemy -> you %d\n",
                   damage_to_enemy, damage_to_player);
        }

        if (log_file != NULL) {
            const char *round_result = "ongoing";
            if (player.hp <= 0 && enemy.hp <= 0) round_result = "draw";
            else if (enemy.hp <= 0) round_result = "player_win";
            else if (player.hp <= 0) round_result = "enemy_win";

            fprintf(log_file, "%d,%d,%s,%s,%d,%d,%d,%d,%d,%d,%d,%d,%s\n",
                    game_id, round, skill_name(player_skill), skill_name(enemy_skill),
                    player_result.roll, enemy_result.roll, damage_to_enemy, damage_to_player,
                    player_result.block, enemy_result.block, player.hp, enemy.hp, round_result);
        }

        round++;
    }

    if (player.hp <= 0 && enemy.hp <= 0) result = "draw";
    else if (enemy.hp <= 0) result = "player_win";
    else if (player.hp <= 0) result = "enemy_win";
    else if (strcmp(result, "quit") != 0) result = "round_limit";

    if (verbose) {
        printf("\nResult: %s\n", result);
        printf("Final HP - You: %d, Enemy: %d\n", player.hp, enemy.hp);
    }

    return strcmp(result, "player_win") == 0;
}

static int run_self_test(void) {
    FILE *log_file = open_log_file();
    int wins = 0;
    if (log_file == NULL) {
        fprintf(stderr, "Could not open %s\n", LOG_PATH);
        return 1;
    }

    for (int i = 1; i <= 50; i++) {
        wins += play_game(1, log_file, 9000 + i, 0);
    }

    fclose(log_file);
    printf("Self-test complete: 50 automated games, player strategy wins=%d\n", wins);
    printf("CSV log updated: %s\n", LOG_PATH);
    return 0;
}

int main(int argc, char **argv) {
    FILE *log_file;
    int game_id;

    srand((unsigned int)time(NULL));

    if (argc > 1 && strcmp(argv[1], "--self-test") == 0) {
        return run_self_test();
    }

    log_file = open_log_file();
    if (log_file == NULL) {
        fprintf(stderr, "Warning: could not open %s; game will run without logging.\n", LOG_PATH);
    }

    game_id = (int)time(NULL);
    printf("Dice Duel King\n");
    printf("Defeat the enemy by combining reliable attacks, risky blows, guards, and charge turns.\n");
    play_game(0, log_file, game_id, 1);

    if (log_file != NULL) {
        fclose(log_file);
    }
    return 0;
}
