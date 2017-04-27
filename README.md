# Sin Implementation in MIPS Assembler

This document serves as project documentation and will give some additional explanation, to the comments in the assembler code.
The optimizations done to the algorithm will be explained briefly in the C++ Implementation section. The implementation is based on the Taylor approximation of the sin function given by:

![TaylorSeries](http://www.sciweavers.org/tex2img.php?eq=%5Csum_%7Bi%3D0%7D%5E%7B%5Cinfty%7D%28-1%29%5Ei%20%5Cfrac%7Bx%5E%7B2i%2B1%7D%7D%7B%282i%2B1%29%21%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

## C++ Implementation

### ``csin(double x)``
This method reduces the input of any value of x to the interval [-PI/2,PI/2]. Afterwards the reduced value is directed to the function
``csin0(double x)`` and the result is returned.

### ``ccos(double x)``
This method approximates the input of any value of x utilizing the ``csin(double x)`` function, as
![CosFromSin](http://www.sciweavers.org/tex2img.php?eq=%5Ccos%20%28x%29%20%3D%20%5Csin%20%28%7B%5Cfrac%7B%5Cpi%7D%7B2%7D-x%7D%29&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0).

### ``ctan(double x)``
This method approximates the tan of the input utilizing the ``csin(double x)`` and ``ccos(double x)`` functions, as
![Tan](http://www.sciweavers.org/tex2img.php?eq=%5C%20tan%20%28x%29%20%3D%20%5Cfrac%7Bsin%20%28x%29%7D%7B%5Ccos%20%28x%29%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0).

### ``csin0(double x)``
This method approximates sin(x) for an value x of the interval
![intervalPiHalf](http://www.sciweavers.org/tex2img.php?eq=%28-%5Cfrac%7B%5Cpi%7D%7B2%7D%2C%5Cfrac%7B%5Cpi%7D%7B2%7D%29&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
 by using the Taylor approximation. The loop is optimized to
remove restrictions that are created with the use of the factorial of the increasing iterator.

The loop uses the previous expression e.g.
![T1](http://www.sciweavers.org/tex2img.php?eq=T_1%20%3D%20%5Cfrac%7Bx%5E3%7D%7B3%21%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
to calculate the current expression e.g.
![T2](http://www.sciweavers.org/tex2img.php?eq=T_2%20%3D%20%5Cfrac%7Bx%5E5%7D%7B5%21%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
, by calculating
![T2fromT1](http://www.sciweavers.org/tex2img.php?eq=T_1%5Cfrac%7B-x%5E2%7D%7B4%20%5Ccdot%205%7D%20%3D%20T_1%20%5Ccdot%20%28-x%5E2%29%20%5Ccdot%20%5Cfrac%7B1%7D%7B4%7D%20%5Ccdot%20%5Cfrac%7B1%7D%7B5%7D%20%3D%20T_2&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### Optimizations
```
for (iter; iter < (MAX * 2 + 3); iter += 2) {
  valueI = valueI * x * -x;
  valueI = valueI / (iter - 1);
  valueI = valueI / iter;

  interResult += valueI;
}
```

This loop is optimized to use far less assembler instructions than a direct implementation of the Taylor approximation. It also does
not use a factorial function enabling better precision, as the precision is only limited by the possibilities of the double number format:

1. The first optimization is to avoid calculating the operand
![MinusOneOp](http://www.sciweavers.org/tex2img.php?eq=%28-1%29%5Ei&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
every iteration and instead calculating the value
![MinusX](http://www.sciweavers.org/tex2img.php?eq=-x&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
once.
2. The second optimization is to each iteration value utilizing the previous iteration value
![TiMinus1](http://www.sciweavers.org/tex2img.php?eq=T_%7Bi-1%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
 calculating the next value by multiplying
![TiMinus1](http://www.sciweavers.org/tex2img.php?eq=T_%7Bi-1%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
with
![MinusXSq](http://www.sciweavers.org/tex2img.php?eq=%28-x%5E2%29&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
(therefore including the (-1)^i factor) and afterwards
dividing
 ![TiMinus1](http://www.sciweavers.org/tex2img.php?eq=T_%7Bi-1%7D&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
by
![TwoI](http://www.sciweavers.org/tex2img.php?eq=2i&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
and
![TwoIPlus1](http://www.sciweavers.org/tex2img.php?eq=%282i%2B1%29&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
as described above.
3. The value
![TwoI](http://www.sciweavers.org/tex2img.php?eq=2i&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
is replaced by utilizing the loop iterator(
![I](http://www.sciweavers.org/tex2img.php?eq=i&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
) and increasing it by 2 instead of 1.


## Assembler Implementation
The output is required to be in a formatted table containing all values of an input containing of an interval start n, an interval end m and
an interval step i. This output will be formatted in markdown format. A rendered table will look like this:

value x | sin(x) | cos(x) | tan(x)
:-----: | :----: | :----: | :----:
0 | 0 | 1 | 0
PI/4 | 0.707106 | 0.707106 | 1
PI/2 | 1 | 0 | -/-
3PI/4 | 0.707106 | 0.707106 | -1
PI | 0 | -1 | 0

This table is displayed by the given code that will be printed out when running the program in the SPIM simulator
```
value x | sin(x) | cos(x) | tan(x)
:-----: | :----: | :----: | :----:
0 | 0 | 1 | 0
PI/4 | 0.707106 | 0.707106 | 1
PI/2 | 1 | 0 | -/-
3PI/4 | 0.707106 | 0.707106 | -1
PI | 0 | -1 | 0
```
