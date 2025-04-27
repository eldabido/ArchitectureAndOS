#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
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
    // Создаем именованные каналы.
    char* fifo1 = "ipc1.fifo";
    char* fifo2 = "ipc2.fifo";
    if (mknod(fifo1, S_IFIFO | 0666, 0) == -1) {
        perror("Error with mknod");
        exit(EXIT_FAILURE);
    }
    if (mknod(fifo2, S_IFIFO | 0666, 0) == -1) {
        perror("Error with mknod");
        exit(EXIT_FAILURE);
    }
    // Создание второго процесса и обработка ошибки.
    pid_t pid1 = fork();
    if (pid1 < 0) {
        perror("Error with fork");
        exit(EXIT_FAILURE);
    }
    // Второй процесс.
    if (pid1 == 0) {
        // Открываем fifo1 для чтения, читаем данные и обрабатываем ошибки.
        int fd1 = open(fifo1, O_RDONLY);
        if (fd1 == -1) {
            perror("Error with fifo1");
            exit(EXIT_FAILURE);
        }
        char buffer[BUFFER_SIZE];
        int res = read(fd1, buffer, BUFFER_SIZE);
        if (res == -1) {
            perror("Error with read");
            exit(EXIT_FAILURE);
        }
        // Преобразуем.
        convert_to_upper(buffer);
        // Открываем канал для записи и записываем.
        int fd2 = open(fifo2, O_WRONLY);
        if (fd2 == -1) {
            perror("Error with open");
            exit(EXIT_FAILURE);
        }
        if (write(fd2, buffer, res) == -1) {
            perror("Error with write");
            exit(EXIT_FAILURE);
        }
        // Закрытие.
        close(fd1);
        close(fd2);
        exit(EXIT_SUCCESS);
    } else {
        // Создание третьего процесса.
        pid_t pid2 = fork();
        if (pid2 < 0) {
            perror("Error with fork");
            exit(EXIT_FAILURE);
        }
        // Третий процесс.
        if (pid2 == 0) {
            // Открытие и считывание.
            int fd2 = open(fifo2, O_RDONLY);
            if (fd2 == -1) {
                perror("Error with open");
                exit(EXIT_FAILURE);
            }
            char buffer[BUFFER_SIZE];
            int res = read(fd2, buffer, BUFFER_SIZE);
            if (res == -1) {
                perror("Error with read");
                exit(EXIT_FAILURE);
            }
            // Открытие и запись.
            int fd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (fd == -1) {
                perror("Error with open");
                exit(EXIT_FAILURE);
            }
            if (write(fd, buffer, res) == -1) {
                perror("Error with write");
                exit(EXIT_FAILURE);
            }
            // Закрытие каналов.
            close(fd2);
            close(fd);
            exit(EXIT_SUCCESS);
        } else {
            //Процесс 1.
            int fd = open(argv[1], O_RDONLY);
            if (fd == -1) {
                perror("Error with open");
                exit(EXIT_FAILURE);
            }
            // Считывание, открытие и запись в fifo1.
            char buffer[BUFFER_SIZE];
            int res = read(fd, buffer, BUFFER_SIZE);
            if (res == -1) {
                perror("Error with read");
                exit(EXIT_FAILURE);
            }
            int fd1 = open(fifo1, O_WRONLY);
            if (fd1 == -1) {
                perror("Error with open");
                exit(EXIT_FAILURE);
            }
            if (write(fd1, buffer, res) == -1) {
                perror("Error with write");
                exit(EXIT_FAILURE);
            }
            // Ожидание и закрытие.
            close(fd);
            close(fd1);
            wait(NULL);
            wait(NULL);
        }
    }
    return 0;
}
