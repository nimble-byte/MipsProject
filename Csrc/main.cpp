#include <iostream>
#include <cmath>

#define PI 3.141592653

/**
 * Approximates the value of sin for values in the interval [-PI/2,PI/2]
 * @param x input value
 * @return approximation of sin(x)
 */
double csin0(double x) {
  int32_t iter = 3;
  const int MAX = 5;

  double valueI = x;
  double interResult = x;

  /*
   * loop calculates the iterative values based on the previous value, beginning with the second value with i = 3
   * this limits the possible precision of the result to the limits of the double data format
   */
  for (iter; iter < (MAX * 2 + 3); iter += 2) {
    valueI = valueI * x * -x;         // multiply the last x^(2i+1) by -x^2 (therefore includes also the factor -1^i)
    valueI = valueI / (iter - 1);     // divide the result of valueI by 2i and (2* + 1) to avoid using the factorial
    valueI = valueI / iter;           // of (2i + 1), that limits the number of executions

    interResult += valueI;
  }

  return interResult;
}

/**
 * Approximates the sin of the input with the Taylor approximation with a precision of T5
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

  return csin0(n);
}

/**
 * Approximates the cos of the input with the Taylor approximation of sin and a precision of T5
 * @param x input value
 * @return approximation of cos(x)
 */
double ccos(double x) {
  double n = PI / 2;
  csin(n - x);
}

/**
 * Approximates the cos of the input with the Taylor approximation of sin and cos and a precision of T5
 * @param x input
 * @return approximation of tan(x)
 */
double ctan(double x) {
  double sinX = csin(x);
  double cosX = ccos(x);
  return sinX/cosX;
}

int main() {
  std::cout << "\tx\t|\tsin(x)\t  |\tcos(x)\t  |\ttan(x)" << std::endl;
  std::cout << "---------|----------------|----------------|---------------" << std::endl;
  for (int i = 0; 8 > i; i++) {
    std::cout << "\t" << i << "\t|\t" << csin(i) << "\t|\t" << ccos(i) << "\t|\t" << ctan(i) << std::endl;
  }
  return 0;
}