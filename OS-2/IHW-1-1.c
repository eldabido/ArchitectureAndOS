#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <semaphore.h>
#include <sys/wait.h>
#include <time.h>

// Здесь можно задать размер территории. Для простоты возьмем 5.
#define SIZE 5

// Структура для территории одного государства
typedef struct {
    // Стоимость целей и оставшаяся стоимость.
    int amount_of_purps;
    int remain_purps;
    // Кол-во потраченных снарядов.
    int used_shells;
    // Данные о территории в виде двумерного массива.
    int territory[SIZE][SIZE];
} Country;

// Структура для общих данных войны
typedef struct {
    // Маркер конца для сигнала.
    int end;
    sem_t sem;       // Неименованный семафор.
    Country country1;  // Тарантерия.
    Country country2;   // Анчуария.
} War;

// Для удобства сделаем эти переменные глобальными.
War *war;  // Разделяемая память.

void handle_signal(int sig) {
    war->end = 1;
    sem_destroy(&war->sem);
    munmap(war, sizeof(War));
    shm_unlink("shm");
    exit(0);
}

// Создаем территорию для страны
void init_country(Country *country) {
    country->amount_of_purps = 0;
    country->remain_purps = 0;
    country->used_shells = 0;

    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (rand() % 2 == 0) { // 50/50, что здесь цель.
                // Рандом стоимость, которую надо потратить.
                country->territory[i][j] = (rand() % 10) + 1;
                // В общую стоимость добавляем цену.
                country->amount_of_purps += country->territory[i][j];
            } else {
                // Иначе территория ничего не стоит.
                country->territory[i][j] = 0;
            }
        }
    }
    // Сколько осталось ценности.
    country->remain_purps = country->amount_of_purps;
}

// Здесь вывод текущего состояния войны
void print_war() {
    printf("\nТекущее состояние войны:\n");
    printf("Тарантерия - Общая стоимость: %d, Осталось: %d, Снарядов: %d\n",
           war->country1.amount_of_purps, war->country1.remain_purps, war->country1.used_shells);
    printf("Анчуария - Общая стоимость: %d, Осталось: %d, Снарядов: %d\n",
           war->country2.amount_of_purps, war->country2.remain_purps, war->country2.used_shells);

    printf("\nТерритория Тарантерии:\n");
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (war->country1.territory[i][j] > 0) {
                printf("[%d] ", war->country1.territory[i][j]);
            } else if (war->country1.territory[i][j] == 0) {
                printf("[ ] ");
            } else {
                printf("[X] ");
            }
        }
        printf("\n");
    }

    printf("\nТерритория Анчуарии:\n");
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (war->country2.territory[i][j] > 0) {
                printf("[%d] ", war->country2.territory[i][j]);
            } else if (war->country2.territory[i][j] == 0) {
                printf("[ ] ");
            } else {
                printf("[X] ");
            }
        }
        printf("\n");
    }
    printf("\n");
}

// Атака на территорию противника.
void attack(int attacker) {
    srand(time(NULL));
    Country *defender = (attacker == 1) ? &war->country2 : &war->country1;

    while (1) {
        // Если пришел сигнал.
        if (war->end)
            break;
        sem_wait(&war->sem);

        // Если все цели уничтожены или припасов не хватает, то конец.
        if (defender->remain_purps == 0 || defender->used_shells >= defender->amount_of_purps) {
            sem_post(&war->sem);
            break;
        }

        // Рандомно генерируем цель.
        int x = rand() % SIZE;
        int y = rand() % SIZE;

        // Начало боевых действий.
        if (attacker == 1) {
            printf("Тарантерия атакует Анчуарию по координатам (%d,%d)", x, y);
        } else {
            printf("Анчуария атакует Тарантерию по координатам (%d,%d)", x, y);
        }

        if (defender->territory[x][y] > 0) {
            printf(" - Попал! Кол-во снарядов: %d\n", defender->territory[x][y]);
            defender->used_shells += defender->territory[x][y];
            defender->remain_purps -= defender->territory[x][y];
            defender->territory[x][y] = -1;
        } else {
            defender->used_shells++;
            printf(" - НЕ ПОПАЛ!!!\n");
        }

        // Как выглядит поле боя после обстрела.
        print_war();
        sem_post(&war->sem);
        usleep(600000);
    }
}

int main() {
    signal(SIGINT, handle_signal);
    srand(time(NULL));

    // Разделяемая память (Для войны).
    int fd = shm_open("shm", O_CREAT | O_RDWR, 0666);
    ftruncate(fd, sizeof(War));
    war = mmap(NULL, sizeof(War), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    // Неименованный семафор.
    if (sem_init(&war->sem, 1, 1) == -1) {
        perror("Error with sem_init");
        exit(EXIT_FAILURE);
    }

    // Инициализируем войну.
    war->end = 0;
    init_country(&war->country1);  // Тарантерия.
    init_country(&war->country2);  // Анчуария.

    // Печатаем начальное состояние.
    print_war();

    // Создаем процессы для стран.
    if (fork() == 0) {
        attack(1);  // Тарантерия атакует.
        exit(0);
    } else if (fork() == 0) {
        attack(0);  // Анчуария атакует.
        exit(0);
    } else {
        wait(NULL);
        wait(NULL);

        printf("\nКонец войны!\n");
        printf("Итоговые результаты:\n");
        printf("Тарантерия - Уничтожено целей на сумму: %d, Потрачено снарядов: %d\n",
               war->country1.amount_of_purps - war->country1.remain_purps, war->country1.used_shells);
        printf("Анчуария - Уничтожено целей на сумму: %d, Потрачено снарядов: %d\n",
               war->country2.amount_of_purps - war->country2.remain_purps, war->country2.used_shells);

        // Завершение работы.
        sem_destroy(&war->sem);
        munmap(war, sizeof(War));
        shm_unlink("shm");
    }
    return 0;
}
