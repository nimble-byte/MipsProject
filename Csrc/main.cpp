#include <iostream>
#include <cmath>

#define PI 3.141592653

/**
 * Approximates the value of sin for values in the interval [-PI/2,PI/2]
 * @param x input value
 * @return approximation of sin(x)
 */
double csin0(double x) {
  int32_t iter = 1;
  const int MAX = 42;

  double valueI = x;
  double interResult = x;

  /*
   * loop calculates the iterative values based on the previous value, beginning with the second value with i = 1
   * this limits the precision of the result to the limits of the double data format
   */
  for (iter; iter < MAX; iter++) {
    valueI = valueI * x * -x;         // multiply the last x^(2i+1) by -x^2 (therefore includes also the factor -1^i)
    valueI = valueI / (2 * iter);     // divide the result of valueI by 2i and (2* + 1) to avoid using the factorial
    valueI = valueI / (2 * iter + 1); // of (2i + 1), that limit the number of executions

    interResult += valueI;
  }

  return interResult;
}

/**
 * Approximates the sin of the input with the Taylor approximation
 * @param x input value
 * @return approximation of sin(x)
 */
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