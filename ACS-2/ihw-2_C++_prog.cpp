#include <iostream>
#include <iomanip>
#include <cmath>

double exponent(int k) {
    double e = 1.0;
    double prev_e = 0.0;
    double factorial = 1.0;
    double accur = 1 / std::pow(10, k);
    int n = 1;

    while (e - prev_e >= accur) {
        factorial *= n; // Вычисляем n! итеративно
        prev_e = e;
        e += 1.0 / factorial; // Добавляем 1/n! к e
        ++n;
    }

    return e;
}

int main() {
    int k;
    std::cin >> k;

    double e = exponent(k);
    std::cout << std::fixed << std::setprecision(12) << e << std::endl;

    return 0;
}
