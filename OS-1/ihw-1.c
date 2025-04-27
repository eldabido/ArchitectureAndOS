#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <fcntl.h>
#include <sys/wait.h>

// Буфер размера 5000 байт.
#define BUFFER_SIZE 5000

// Функция преобразования строчных гласных букв заглавными.
void convert_to_upper(char* str) {
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
        fprintf(stderr, "Usage: %s <input file> <output file>\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    // Дескрипторы для каналов.
    int pipefd1[2];
    int pipefd2[2];
    // Создаем каналы и, если ошибка, то сообщаем.
    if (pipe(pipefd1) == -1 || pipe(pipefd2) == -1) {
        perror("Error with pipes");
        exit(EXIT_FAILURE);
    }
    // Для хранения id процессов.
    pid_t pid1;
    pid_t pid2;
    // Создание второго процесса.
    pid1 = fork();
    // Обработка ошибки.
    if (pid1 < 0) {
        perror("Error with creating second process");
        exit(EXIT_FAILURE);
    }
    // Второй процесс.
    if (pid1 == 0) {
        //Закрываем запись и чтение из каналов соответственно.
        close(pipefd1[1]);
        close(pipefd2[0]);

        // Считываем из канала данные.
        char buffer[BUFFER_SIZE];
        int res = read(pipefd1[0], buffer, BUFFER_SIZE);
        // Обработка ошибки с read.
        if (res == -1) {
            perror("Error with read");
            exit(EXIT_FAILURE);
        }
        // Вызов функции преобразования.
        convert_to_upper(buffer);
        // Запись в канал и обработка ошибки.
        if (write(pipefd2[1], buffer, res) == -1) {
            perror("Error with write");
            exit(EXIT_FAILURE);
        }
        // Закрытие каналов.
        close(pipefd1[0]);
        close(pipefd2[1]);
        exit(EXIT_SUCCESS);
    } else {
        // Создаём третий процесс.
        pid2 = fork();
        // Обработка ошибки.
        if (pid2 < 0) {
            perror("Error with fork");
            exit(EXIT_FAILURE);
        }
        // Третий процесс.
        if (pid2 == 0) {
            // Закрытие каналов на записи и чтение.
            close(pipefd1[0]);
            close(pipefd1[1]);
            close(pipefd2[1]);
            // Считываем из канала и обработка ошибки.
            char buffer[BUFFER_SIZE];
            int res = read(pipefd2[0], buffer, BUFFER_SIZE);
            if (res == -1) {
                perror("Error with read");
                exit(EXIT_FAILURE);
            }
            // Открываем выходной файл для записи.
            int fd2 = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            // Обработка ошибки.
            if (fd2 == -1) {
                perror("Error with open");
                exit(EXIT_FAILURE);
            }
            // Запись и обработка ошибки.
            if (write(fd2, buffer, res) == -1) {
                perror("Error with write");
                exit(EXIT_FAILURE);
            }
            // Закрытие канала и дескриптора, конец процесса.
            close(pipefd2[0]);
            close(fd2);
            exit(EXIT_SUCCESS);
          // Первый процесс.
        } else {
            // Закрытие каналов на чтения и запись.
            close(pipefd1[0]);
            close(pipefd2[0]);
            close(pipefd2[1]);
            // Открытие входного файла на чтение.
            int fd1 = open(argv[1], O_RDONLY);
            // Обработка ошибки.
            if (fd1 == -1) {
                perror("Error with open");
                exit(EXIT_FAILURE);
            }
            // Чтение в буфер.
            char buffer[BUFFER_SIZE];
            int res = read(fd1, buffer, BUFFER_SIZE);
            // Обработка ошибки.
            if (res == -1) {
                perror("Error with read");
                exit(EXIT_FAILURE);
            }
            // Запись в канал.
            if (write(pipefd1[1], buffer, res) == -1) {
                perror("Error with write");
                exit(EXIT_FAILURE);
            }
            // Закрытие канала и дескриптора и ожидание двух других процессов.
            close(pipefd1[1]);
            close(fd1);
            wait(NULL);
            wait(NULL);
        }
    }
    return 0;
}
