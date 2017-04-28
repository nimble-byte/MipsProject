# Trigonometric Functions in MIPS Assembly

This repository contains the project work of implementing the trigonometric functions
*sin(x)*, *cos(x)* and *tan(x)* in MIPS assembly. The assembly code can be found in the
folder `AssSrc`, the basis made by a C++ implementation in `CSrc`. The rest of this
document will serve as a project documentation and explains the optimizations made to the
Taylor approximation that is used to calculate the function values.

## Basics
The program is supposed to take three inputs. An interval start **xMin**, and interval
end **xMax** and an interval step **n**. All three functions will be calculated for
each single step and displayed in a table in one row.

The calculations will be approximated by the Taylor approximation of the sin function
that can be found [here](https://en.wikipedia.org/wiki/Sine#Series_definition). To
improve precision of the approximation without needing too many iterations of a loop
that calculates each addend of the Taylor series, the input value will be first reduced
to the interval *[-PI/2, PI/2]*. The function `sin` will now only reduce all input values to this interval while the real approximation is done by the function `sin0`

Furthermore *cos(x)* can be calculated using *sin(PI/2 - x)*. The *tan(x)* can be
calculated from the other two results by dividing *sin(x)/cos(x)*.

## Additional Optimizations
To improve performance as well as precision further the following optimizations were
added:

1. Each single addend **Ti** of the Taylor series can be calculated using the previous
value **T(i-1)** (except for the first that is simply the input **x**). This can be
achieved by first multiplying **T(i-1)** with *x^2* and afterwards dividing it by *(2i)*
and *(2i + 1)*. This not only decreases the number of calculation but also increases the
precision as the number of iterations was strongly limited before due to the use of the
faculty of *(2i + 1)*.

2. The first iteration of the Taylor series can be skipped as the result is simply the value of the input **x**. Therefore we can start the loop with the second iteration and the iteration *i=1*.

3. The second optimization is to include the factor *(-1)^i* in the multiplication of
**Ti** with *x^2* by instead multiplying with *-(x^2)*. This reduces the number of
calculations further.

4. The regular calculation of the value *2i* is replaced by simply using the loop
invariant and increasing this invariant by 2 instead of 1 with each iteration (once
during the loop after dividing by the iterator, the second time after the loop). The
start value is also increased to *i=2*. This is due to the fact that 2 is the first value
we need to divide by.

5. The value of *sin(x)* will be saved after the calculation to enable much faster
calculations for *tan(x)*. The value of *cos(x)* will be available in the result
register **$f0**.

All named optimization lead to the following C++ implementation of the loop in the
function `csin0(double x)` that will approximate *sin(x)* on the interval *[-PI/2,
PI/2]*:

```C++
// valueI is the value Ti for each iteration; result the sum of all Ti
for (iter; iter < (MAX * 2 + 3); iter++) {
  valueI = valueI * x * -x;
  valueI = valueI / iter;
  iter++;
  valueI = valueI / iter;

  result += valueI;
}
```

## Assembly Output
As the output is required to be a formatted, we chose to use markdown like notation to
enable a nice an clean look for the table if it is rendered. A rendered example table can
e.g. look like this.

value x | sin(x) | cos(x) | tan(x)
:-----: | :----: | :----: | :----:
0 | 0 | 1 | 0
PI/4 | 0.707106 | 0.707106 | 1
PI/2 | 1 | 0 | -/-
3PI/4 | 0.707106 | 0.707106 | -1
PI | 0 | -1 | 0

This table is displayed by the given code that will be printed out when running the
program in the SPIM simulator
```
value x | sin(x) | cos(x) | tan(x)
:-----: | :----: | :----: | :----:
0 | 0 | 1 | 0
PI/4 | 0.707106 | 0.707106 | 1
PI/2 | 1 | 0 | -/-
3PI/4 | 0.707106 | 0.707106 | -1
PI | 0 | -1 | 0
```
