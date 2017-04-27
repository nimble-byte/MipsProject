.data

# CONSTANTS
pi:           .double 3.1415926535
piHalf:       .double 1.57079632675
two:          .double 2.0

maxIt:        .word   5

# INPUT
inputMin:       .asciiz "Please enter a value Xmin: "
inputMax:       .asciiz "Please enter a value Xmax (Xmax > Xmin): "
inputStep:      .asciiz "Please enter a step size n > 0: "

# OUTPUT
tableHeader:  .asciiz "\tx\t|\tsin(x)\t|\tcos(x)\t|\ttan(x)\n"
tableSep:     .asciiz ":-------: | :----------: | :----------: | :-----------:\n"
spacedPipe:   .asciiz " | "
endl:         .asciiz "\n"

# ERROR
restartM:     .asciiz "Restarting program\n\n"
wrongInterv:  .asciiz "Xmax must be larger than Xmin.\n"
negativeStep: .asciiz "Step must be > 0.\n"

.align 2

.text
# ----------Constants----------
# The following constants will be loaded repeadtedly into these registers
#
# pi:     $f20
# piHalf: $f22
# 2.0:    $f24
#
# maxIt:  $s0
#
# The following calculated values will be alway in the following registers
# (names according to C++ code)
#
# Xmin:       $f26
# Xmax:       $f28
# step n:     $f30
# result:     $f0
#
# Within the calculation the following values are saved in the following registers
# helper:     $f4   (for shifting if needed)
# -x:         $f6
# valueI:     $f16
#
# iter:       $t0

main:
      # load and display input request for start value Xmin
      li $v0, 4
      la $a0, inputMin
      syscall

      # read Xmin
      li $v0, 7
      syscall
      # move Xmin to register $f26 (and $f27 as Xmin is double)
      mov.d $f26, $f0

      # load and display input request for end value Xmax
      li $v0, 4
      la $a0, inputMax
      syscall

      # read Xmax
      li $v0, 7
      syscall
      # move Xmax to register $f28 (and $29 as Xmax is double)
      mov.d $f28, $f0

      # check if Xmin($f26) is smaller Xmax($28)
      c.le.d $f26, $f28
      # branch if Xmin($f26) is not smaller than Xmax($f28)
      bc1f wIError

      # load and display input request for step value n
      li $v0, 4
      la $a0, inputStep
      syscall

      # read n
      li $v0, 7
      syscall
      # move n to register $fxx (and $fxx+1 as n is double)
      mov.d $f30, $f0

      # check if step n is larger than 0
      # set up compare value 0
      li.d $f4, 0.0
      c.le.d $f30, $f4
      bc1t wSError

      # end program
      li $v0, 10
      syscall

restart:
        # load and display restart message
        li $v0, 4
        la $a0, restartM
        syscall

        # restart by jumping to main again
        j main

wIError:
        # load and display wrong interval error message
        li $v0, 4
        la $a0, wrongInterv
        syscall

        # restart the program
        j restart

wSError:
        # load and display wrong step error message
        li $v0, 4
        la $a0, negativeStep
        syscall

        # restart the program
        j restart
