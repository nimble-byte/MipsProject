# Sin Implementation in MIPS Assembler

This document serves as project documentation and will give some additional explanation, to the comments in the assembler code.
The optimizations done to the algorithm will be explained briefly in the C++ Implementation section.

## C++ Implementation

### ``csin(double x)``
This method reduces the input of any value of x to the interval [-PI/2,PI/2]. Afterwards the reduced value is directed to the function
``csin0(double x)`` and the result is returned.

### ``csin0(double x)``
This method calculates sin(x) for an value x of the interval [-PI/2,PI/2] by using the Taylor approximation. The loop is optimized to 
remove restrictions that are created with the use of the factorial of the increasing iterator.

The loop uses the previous expression Ti-1 to calculate the current expression Ti, beginning from the 2nd iteration with the iterator
value 1.
```
/*
 * loop calculates the iterative values based on the previous value, beginning with the second value with i = 1
 * this limits the precision of the result to the limits of the double data format
 */
for (iter; iter < MAX; iter++) {
  valueI = valueI * x * -x;        // multiply the last x^(2i+1) by -x^2 (therefore includes also the factor -1^i)
  valueI = valueI / (2 * iter);    // divide the result of valueI by 2i and (2* + 1) to avoid using the factorial 
  valueI = valueI / (2 * iter + 1);// of (2i + 1), that limit the number of executions

  interResult += valueI;
}
```

## Assembler Implementation
The output is required to be in a formatted table containg all values of an input containg of an interval start n, an interval end m and 
an interval step i. This output will be formatted in markdown format. A rendered table will look like this:

vlaue x | sin(x)
:-----: | :----:
0 | 0
PI/4 | 0.707106...
PI/2 | 1
3PI/4 | 0.707106...
PI | 0

This table is diplayed by the given code that will be printed out when running the program in the SPIM simulator
```
vlaue x | sin(x)
:-----: | :----:
0 | 0
PI/4 | 0.707106...
PI/2 | 1
3PI/4 | 0.707106...
PI | 0
```
