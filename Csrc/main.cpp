#include <iostream>
#include <cmath>

#define PI 3.141592653

double pow(double base, int32_t exponent)
{
	if (exponent == 0) return 1;
	return base * pow(base, exponent - 1);
}

int32_t factorial(int32_t number)
{
	if (number == 0) return 1;
	return number * factorial(number - 1);
}

double csin0(double x)
{
	int32_t iter = 0;
	const int MAX = 7;

	double result = 0;

	for (iter; iter < MAX; iter++) {
		double fact = pow(-1, iter);

		double up = pow(x, (2 * iter + 1));
		int32_t down = factorial(2 * iter + 1);
		up = up / down;

		result += up * fact;
	}

	return result;
}

double csin(double x)
{
	double n = x;
	while ((n > PI / 2) || (n < -PI / 2)) {
		if (n > PI / 2) {
			n -= PI;
		}
		else {
			n += PI;
		}
	}

	std::cout << n << std::endl;
	return csin0(n);
}

int main()
{
	std::cout << csin(PI / 2) << std::endl;
	std::cout << std::sin(PI / 2) << std::endl;
	return 0;
}