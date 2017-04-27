.data

# CONSTANTS
pi:           .double 3.1415926535
piHalf:       .double 1.57079632675

maxIt:        .word   5

# INPUT
inputMin:       .asciiz "Please enter a value Xmin: "
inputMax:       .asciiz "Please enter a value Xmax (Xmax > Xmin): "
inputStep:      .asciiz "Please enter a step size n > 0: "

# OUTPUT
tableHeader:  .asciiz "\tx\t|\tsin(x)\t|\tcos(x)\t|\ttan(x)\n"
tableSep:     .asciiz ":---------------------:|:--------------------:|:--------------------:|:-------------------:\n"
spacedPipe:   .asciiz " | "
endl:         .asciiz "\n"
finishedM:    .asciiz "\nProgram finished."

# ERROR
restartM:     .asciiz "Restarting program\n\n"
wrongInterv:  .asciiz "Xmax must be larger than Xmin.\n"
negativeStep: .asciiz "Step must be > 0.\n"

.align 2

.text
# ----------Constants----------
# The following constants will be loaded repeadtedly into these registers
#
# pi:           $f20
# piHalf:       $f22
# sinResult:    $f24 -> for faster calculation of tan
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

      # load and display table header
      li $v0, 4
      la $a0, tableHeader
      syscall

      # load and display table seperator
      li $v0, 4
      la $a0, tableSep
      syscall

      # jump to calculation subroutine
      jal calc

      # load and display finished message
      li $v0, 4
      la $a0, finishedM
      syscall

      # end program
      li $v0, 10
	    syscall

calc:
      # all necessary variable for the loop are already set up in main
      # load and display Xmin($f26) value in the table
      li $v0, 3
      mov.d $f12, $f26
      syscall

      # load and display cell separator
      li $v0, 4
      la $a0, spacedPipe
      syscall

      # calculate sin(Xmin); result will be in $f0
      #jal sin

      # load and display result($f0) of sin calculation
      li $v0, 3
      mov.d $f12, $f0
      syscall

      # load and display cell separator
      li $v0, 4
      la $a0, spacedPipe
      syscall

      # calculate cos(Xmin); result will be in $f0
      #jal cos

      # load and display result($f0) of cos calculation
      li $v0, 3
      mov.d $f12, $f0
      syscall

      # load and display cell separator
      li $v0, 4
      la $a0, spacedPipe
      syscall

      # calculate tan(Xmin); result will be in $f0
      #jal tan

      # load and display result($f0) of tan calculation
      li $v0, 3
      mov.d $f12, $f0
      syscall

      # load and display end of line
      li $v0, 4
      la $a0, endl
      syscall

      # increase Xmin($f26) by stepsize n($f30) for calculation of next row
      add.d $f26, $f26, $f30

      # conpare if Xmin($f26) is smaller/equal Xmax($f28)
      c.le.d $f26, $f28
      # if true then branch to calc for next iteration
      bc1t calc

      # else return to main function to end program
      jr $ra

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
