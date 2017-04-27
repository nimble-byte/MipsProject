#include <iostream>
#include <cmath>

#define PI 3.141592653

double csin(double);
double ccos(double);
double ctan(double);
double csin0(double);


int main() {
  std::cout << "\tx\t|\tsin(x)\t  |\tcos(x)\t  |\ttan(x)" << std::endl;
  std::cout << "---------|----------------|----------------|---------------" << std::endl;

  for (int i = 0; 8 > i; i++) {
    std::cout << "\t" << i << "\t|\t" << csin(i) << "\t|\t" << ccos(i) << "\t|\t" << ctan(i) << std::endl;
  }
  return 0;
}

/**
 * Approximates the sin of the input with the Taylor approximation with a precision of T5
 * @param x input value
 * @return approximation of sin(x)
 */
double csin(double x) {
  if ((x <= PI / 2 && (x >= -PI / 2))) return csin0(x);

  double helper = x;
  while ((helper > PI / 2) || (helper < -PI / 2)) {
    if (helper > PI / 2) {
      helper -= PI;
    } else {
      helper += PI;
    }
    helper *= -1;
  }

  return csin0(helper);
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

/**
 * Approximates the value of sin for values in the interval [-PI/2,PI/2]
 * @param x input value
 * @return approximation of sin(x)
 */
double csin0(double x) {
  int32_t iter = 3;
  const int MAX = 5;

  double valueI = x;    // iteration value Ti for each iteration of the Taylor approximation
  double result = x;    // final result of the full Taylor approximation

  /*
   * loop calculates the iterative values based on the previous value, beginning with the second
   * value with i = 3 this limits the possible precision of the result to the limits of the
   * double data format
   */
  for (iter; iter < (MAX * 2 + 3); iter += 2) {
    valueI = valueI * x * -x;         // multiply the iterative value by -x^2 (therefore includes x^2 and the factor (-1)^i for the respective iteration)
    valueI = valueI / (iter - 1);     // divide the result of valueI by 2i and (2* + 1) to avoid using the factorial
    valueI = valueI / iter;           // of (2i + 1), which would limit the number of iterations

    result += valueI;
  }

  return result;
}
