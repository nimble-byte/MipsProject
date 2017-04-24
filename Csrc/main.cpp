#include <iostream>
#include <cmath>

#define PI 3.141592653

double pow(double base, int32_t exponent) {
  if (exponent == 0) return 1;
  return base * pow(base, exponent - 1);
}

int32_t factorial(int32_t number) {
  if (number == 0) return 1;
  return number * factorial(number - 1);
}

double csin0(double x) {
  int32_t iter = 1;
  const int MAX = 11;

  double result = x;
  double interResult = x;

  for (iter; iter < MAX; iter++) {
    result = result * x * -x;
    result = result / (2 * iter);
    result = result / (2 * iter + 1);

    interResult += result;
  }

  return interResult;
}

double csin(double x) {
  if ((x <= PI / 2 && (x >= -PI / 2))) return csin0(x);

  double n = x;
  while ((n > PI / 2) || (n < -PI / 2)) {
    if (n > PI / 2) {
      n -= PI;
    } else {
      n += PI;
    }
    n *= -1;
  }

  std::cout << "Sin is calculated with the value " << n << std::endl;
  return csin0(n);
}

int main() {
  std::cout << "The sin of " << 12 << " is " << csin(12) << std::endl;
  std::cout << "C++ libs say it is " << std::sin(12) << std::endl << std::endl;

  std::cout << "The sin of " << 3.14 << " is " << csin(3.14) << std::endl;
  std::cout << "C++ libs say it is " << std::sin(3.14) << std::endl << std::endl;
  return 0;
}