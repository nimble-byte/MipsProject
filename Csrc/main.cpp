#include <iostream>
#include <cmath>
#include <float.h>
#include <math.h>

#define PI 3.141592653

double getStepSize(double, double, int);

double csin(double);

double ccos(double);

double ctan(double);

double csin0(double);


int main() {

    int steps = 0;
    double min, max, stepsize = 0.0;

    // Get input
    std::cout << "Please enter a value Xmin: ";
    std::cin >> min;
    std::cout << std::endl << "Please enter a value Xmax (Xmax > Xmin): ";
    std::cin >> max;
    std::cout << std::endl << "Please enter a number of result values > 0: ";
    std::cin >> steps;
    std::cout << std::endl;

    if (min > max || steps < 1) return -1;   // Insert Error messages

    stepsize = getStepSize(min, max, steps);

    std::cout << "\tx\tc sin\t|\tsin(x)\t  |\tcos(x)\t  |\ttan(x)" << std::endl;
    std::cout << "----------------|-----------------|---------------|---------------" << std::endl;

    for (double i = min; max >= i; i += stepsize) {
        std::cout << "\t" << i << "\t|\t" << csin(i) << "\t|\t" << ccos(i) << "\t|\t"
                  << ctan(i) << std::endl;

        // Following block is for tests only.
        /*{
            std::cout << "Difference between C lib and own implementation (sin): " << (std::sin(i) - csin(i))
                      << std::endl;
            std::cout << "Difference between C lib and own implementation (cos): " << (std::cos(i) - ccos(i))
                      << std::endl;
            std::cout << "Difference between C lib and own implementation (tan): " << (std::tan(i) - ctan(i))
                      << std::endl;
        }*/
    }
    return 0;
}

/**
 * Gets the stepsize that needs to be added after each iteration based on the number of steps given.
 * @param min lower bound
 * @param max upper bound
 * @param steps number of steps to be calculated
 * @return stepsize for given range
 */
double getStepSize(double min, double max, int steps) {
    if (steps == 1) return (max - min) + 1; // Add 1, so we are definitely outside the range
    double stepsize = ((max - min) /
                       (steps - 1));// steps - 1, since we begin at min and work our way up
    return stepsize;
}

/**
 * Approximates the sin of the input with the Taylor approximation with a precision of T5
 * @param x input value
 * @return approximation of sin(x)
 */
double csin(double x) {
    if ((x <= PI / 2 && (x >= -PI / 2))) return csin0(x);

    double helper = x;

    // Shift value into [-PI/2, +PI/2]
    while ((helper > PI / 2) || (helper < -PI / 2)) {
        if (helper > PI / 2) {
            helper -= PI;
        } else {
            helper += PI;
        }
        helper *= -1;   // Adjustment needed for value to be still correct
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
    return csin(n - x);
}

/**
 * Approximates the cos of the input with the Taylor approximation of sin and cos and a precision of T5
 * @param x input
 * @return approximation of tan(x)
 */
double ctan(double x) {
    double sinX = csin(x);
    double cosX = ccos(x);
    return sinX / cosX;
}

/**
 * Approximates the value of sin for values in the interval [-PI/2,PI/2]
 * @param x input value
 * @return approximation of sin(x)
 */
double csin0(double x) {
    int32_t iter = 2;
    const int MAX = 5;

    double valueI = x;    // iteration value Ti for each iteration of the Taylor approximation
    double result = x;    // final result of the full Taylor approximation

    /*
     * loop calculates the iterative values based on the previous value, beginning with the second
     * value with i = 3 this limits the possible precision of the result to the limits of the
     * double data format
     */
    for (iter; iter < (MAX * 2 + 3); iter++) {
        valueI = valueI * x *
                 -x;         // multiply the iterative value by -x^2 (therefore includes x^2 and the factor (-1)^i for the respective iteration)
        valueI = valueI / iter;           // divide the result of valueI by 2i and (2* + 1) to avoid using the factorial
        iter++;
        valueI = valueI / iter;           // of (2i + 1), which would limit the number of iterations

        result += valueI;
    }

    return result;
}
