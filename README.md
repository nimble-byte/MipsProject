# Sin Implementation in MIPS Assembler

This document serves as project documentation and will give some additional explanation, to the
comments in the assembler code.
The optimizations done to the algorithm will be explained briefly in the C++ Implementation
section. The implementation is based on the Taylor approximation of the sin function.

## C++ Implementation

### ``csin(double x)``
This method reduces the input of any value of x to the interval [-PI/2,PI/2]. Afterwards the
reduced value is directed to the function
``csin0(double x)`` and the result is returned.

### ``ccos(double x)``
This method approximates the input of any value of x utilizing the ``csin(double x)`` function, as **cos(x) = sin(PI/2 - x)**.

### ``ctan(double x)``
This method approximates the tan of the input utilizing the ``csin(double x)`` and ``ccos(double x)`` functions, as **tan(x) = sin(x)/cos(x)**.

### ``csin0(double x)``
This method approximates sin(x) for an value x of the interval by using the Taylor approximation.
The loop is optimized to remove restrictions that are created with the use of the factorial of the
increasing iterator.

The loop uses the previous expression **Ti-1** to calculate the current expression **Ti**,
beginning from the 2nd iteration with the iterator value 1.

### Optimizations
```
for (iter; iter < (MAX * 2 + 3); iter += 2) {
  valueI = valueI * x * -x;
  valueI = valueI / (iter - 1);
  valueI = valueI / iter;

  interResult += valueI;
}
```

This loop is optimized to use far less assembler instructions than a direct implementation of the
Taylor approximation. It also does not use a factorial function enabling better precision, as the
precision is only limited by the possibilities of the double number format:

1. The first optimization is to avoid calculating the operand **(-1)^i** every iteration and
instead calculating the value **-x** once.

2. The second optimization is to each iteration value utilizing the previous iteration value
(**prevVal**) calculating the next value by multiplying **prevVal** with **-(x^2) = (x^(2i+1)) -
(x^(2(i+1)+1))** *(therefore including the* **(-1)^i** *factor)* and afterwards dividing
**prevVal** by **n** and **(n + 1) = (combined faculty divisions)**.

3. The value **2i** is replaced by utilizing the loop iterator(**i**) and increasing it by 2
instead of 1.

4. The value of sin (x) is saved after the calculation as to enable a much faster calculation of
tan(x), as cos(x) will be available in the result register.

## Assembler Implementation
The output is required to be in a formatted table containing all values of an input containing of
an interval start n, an interval end m and an interval step i. This output will be formatted in
markdown format. A rendered table will look like this:

value x | sin(x) | cos(x) | tan(x)
:-----: | :----: | :----: | :----:
0 | 0 | 1 | 0
PI/4 | 0.707106 | 0.707106 | 1
PI/2 | 1 | 0 | -/-
3PI/4 | 0.707106 | 0.707106 | -1
PI | 0 | -1 | 0

This table is displayed by the given code that will be printed out when running the program in the
SPIM simulator
```
value x | sin(x) | cos(x) | tan(x)
:-----: | :----: | :----: | :----:
0 | 0 | 1 | 0
PI/4 | 0.707106 | 0.707106 | 1
PI/2 | 1 | 0 | -/-
3PI/4 | 0.707106 | 0.707106 | -1
PI | 0 | -1 | 0
```
