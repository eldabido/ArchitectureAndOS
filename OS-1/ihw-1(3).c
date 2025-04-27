#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <ctype.h>

// Буфер размера 5000 байт.
#define BUFFER_SIZE 5000

// Функция преобразования строчных гласных букв заглавными.
void convert_to_upper(char *str) {
    while (*str) {
        if (*str == 'a' || *str == 'e' || *str == 'i' || *str == 'o' || *str == 'u') {
            *str = toupper(*str);
        }
        ++str;
    }
}

int main(int argc, char *argv[]) {
    // Проверка на правильный формат запуска программы.
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <входной файл> <выходной файл>\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    // Дескрипторы для каналов.
    int pipefd1[2], pipefd2[2];
    // Создаем каналы и, если ошибка, то сообщаем.
    if (pipe(pipefd1) == -1 || pipe(pipefd2) == -1) {
        perror("Error with pipe");
        exit(EXIT_FAILURE);
    }
    // Для хранения id процессов.
    pid_t pid;
    // Создание второго процесса.
    pid = fork();
    if (pid < 0) {
        perror("Error with fork");
        exit(EXIT_FAILURE);
    }
    // Второй процесс.
    if (pid == 0) {
        // Закрытие первого дескриптора на запись, а второго на чтение.
        close(pipefd1[1]);
        close(pipefd2[0]);
        // Считывание.
        char buffer[BUFFER_SIZE];
        int res = read(pipefd1[0], buffer, BUFFER_SIZE);
        if (res == -1) {
            perror("Error with read");
            exit(EXIT_FAILURE);
        }
        // Преобразование, запись в обратный канал.
        convert_to_upper(buffer);
        if (write(pipefd2[1], buffer, res) == -1) {
            perror("Error with write");
            exit(EXIT_FAILURE);
        }
        // Закрытие.
        close(pipefd1[0]);
        close(pipefd2[1]);
        exit(EXIT_SUCCESS);
    } else {
        // Первый процесс.
        close(pipefd1[0]);
        close(pipefd2[1]);

        // Чтение.
        int fd = open(argv[1], O_RDONLY);
        if (fd == -1) {
            perror("Error with open");
            exit(EXIT_FAILURE);
        }
        // Считывание данных.
        char buffer[BUFFER_SIZE];
        int res = read(fd, buffer, BUFFER_SIZE);
        if (res == -1) {
            perror("Error with read");
            exit(EXIT_FAILURE);
        }
        // Запись в канал.
        if (write(pipefd1[1], buffer, res) == -1) {
            perror("Error with write");
            exit(EXIT_FAILURE);
        }
        // Закрытие на запись.
        close(pipefd1[1]);
        // Считывание обработанных данных из обратного канала.
        res = read(pipefd2[0], buffer, BUFFER_SIZE);
        if (res == -1) {
            perror("Error with read");
            exit(EXIT_FAILURE);
        }
        // Открытие на запись в выходной файл.
        int fd2 = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (fd2 == -1) {
            perror("Error with open");
            exit(EXIT_FAILURE);
        }
        // Запись.
        if (write(fd2, buffer, res) == -1) {
            perror("Error with write");
            exit(EXIT_FAILURE);
        }
        // Закрытие.
        close(pipefd2[0]);
        close(fd2);
        // Ожидание дочернего процесса.
        wait(NULL);
    }
    return 0;
}
