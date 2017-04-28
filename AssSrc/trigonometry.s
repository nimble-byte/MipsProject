.data

# CONSTANTS
pi:           .double 3.1415926535
piHalf:       .double 1.57079632675

maxIt:        .word 21 # 2 * 9 (9 iteratons) + 3 for iter start value offset

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
# TODO: Move cos and tan to own functions?
# TODO: Handle special cases for tan

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
# -1.0:       $f8
# -PI/2       $f10
# valueI:     $f16
# iter(double)$f18
#
# iter(int):  $t0

##
 # Main function handle input and checks input values. After all checks sets the constants and
 # calls calc function
 ##
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

      # initialize constants
      jal setConstants

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

##
 # Main loop. Calculates and prints all sin, cos and tan of all values between Xmin and Xmax in
 # step size n. Calls respective functions for calculation of trigonometric values.
 ##
calc:
      # reserve space for int on stack
      addi $sp, $sp, -4
      # save stack pointer
      sw $ra, 0($sp)
calcLoop:
          # all necessary variable for the loop are already set up in main
          # load and display Xmin($f26) value in the table
          li $v0, 3
          mov.d $f12, $f26
          syscall

          # load and display cell separator
          li $v0, 4
          la $a0, spacedPipe
          syscall

          # copy Xmin to argument register($f12)
          mov.d $f12, $f26

          # calculate sin(Xmin); result will be in $f0
          jal sin

          # save result($f0) to $f24 to make tan calc easier
          mov.d $f24, $f0

          # load and display result($f0) of sin calculation
          li $v0, 3
          mov.d $f12, $f0
          syscall

          # load and display cell separator
          li $v0, 4
          la $a0, spacedPipe
          syscall

          # calculate cos(Xmin); result will be in $f0


          # load and display result($f0) of cos calculation
          li $v0, 3
          mov.d $f12, $f0
          syscall

          # load and display cell separator
          li $v0, 4
          la $a0, spacedPipe
          syscall

          # calculate tan(Xmin); result will be in $f0
          # use saved result of sin(Xmin)($f24) and cos(Xmin)($f0) to calculate:
          # tan(x) = sin(x)/cos(x)
          div.d $f0, $f24, $f0

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
          bc1t calcLoop
# end calcLoop
          # else return to main function to end program
          # load stack pointer
          lw $ra, 0($sp)
          # free space on stack
          addi $sp, $sp, 4
          jr $ra

##
 # Main implementation fot calculation. Approximates sin of the input with the Taylor
 # approximation. Optimized for better performance and precision
 # @param: 'x'($f0[+$f1]) input of the function; double value to approximate sin for
 # @return: 'result'($f12[+$f13]) approximation of the sin of x
 ##
sin:
    # copy input($f12) to return($f4)
    mov.d $f2, $f12

    # reserve space for int on stack
    addi $sp, $sp, -4
    # save stack pointer
    sw $ra, 0($sp)
sinLoop:
        # copy result from return register from previous iteration($f2) to helper($f4)
        mov.d $f4, $f2

        # copy x($f4) to argument register($f12) for later jumps
        mov.d $f12, $f4

        # check if x($f4) is smaller than PI/2($f22)
        c.le.d $f4, $f22
        # if not jump to reduce function for over interval
        bc1f overInterv

        # load -1
        li.d $f8, -1.0
        # calculate -PI/2($f10) with PI/2($f22) and -1($f8)
        mul.d $f10, $f22, $f8

        # check if -PI/2($f10) is smaller than x($f4)
        c.le.d $f10, $f4
        # if true jump to reduce function for under interval
        bc1f underInterv

        # fallthrough case: x is in interval [-PI/2, PI/2]
        # start sin calculation
        jal sin0
#end sinLoop
        # return to calling function
        # load stack pointer
        lw $ra, 0($sp)
        # free space on stack
        addi $sp, $sp, 4
        jr $ra

##
 # Helper function to reduce large values to the interval [-PI/2, PI/2] to increase precision when
 # approximating sin of x. Handles the case if x is over the interval.
 ##
overInterv:
            # subtract PI($f20) from input($f12) and write to output($f2)
            sub.d $f2, $f12, $f20

            # load -1 to respective register for multiplication with -1
            li.d $f8, -1.0

            # multply result($f2) with -1($f8) (definitely already set correctly in sin)
            # to correct sign errors in later result of sin0
            mul.d $f2, $f2, $f8

            # jump back to the reduction loop of sin
            j sinLoop

##
# Helper function to reduce large values to the interval [-PI/2, PI/2] to increase precision when
# approximating sin of x. Handles the case if x is under the interval.
##
underInterv:
            # add PI($f20) to the input($f12) and write to output($f2)
            add.d $f2, $f12, $f20

            # multply result($f2) with -1($f8) (definitely already set correctly in sin)
            # to correct sign errors in later result of sin0
            mul.d $f2, $f2, $f8

            # jump back to the reduction loop of sin
            j sinLoop

##
 # Approximation function for a double x in the interval [-PI/2, PI/2]. Is called from sin after the input value is reduced to this interval.
 # @param: 'x'($f0[+$f1]) input value reduced to the said interval
 # @return: 'result'($f12[+$f13]) approximation of the sin of the input value
 ##
sin0:
      # set iter($t0) to start value
      li $t0, 2

      # set initital value of valueI($f16)
      mov.d $f16, $f12

      # set initial result($f0) to the input value
      mov.d $f0, $f12

      # copy input to register for -x($f6)
      mov.d $f6, $f0
      # load -1($f8) to calculate -x($f6)
      li.d $f8, -1.0
      # calculate -x($f6)
      mul.d $f6, $f6, $f8
sin0Loop:
          # multiply valueI($f16) with x($f12) and -x($f6)
          mul.d $f16, $f16, $f12
          mul.d $f16, $f16, $f6

          # copy iter($t0) to floating point unit and convert to double($f18)
          mtc1 $t0, $f2
          cvt.d.w $f18, $f2
          # divide valueI($f16) by iter($f18)
          div.d $f16, $f16, $f18

          # increase itwe($t0) by 1
          addi $t0, $t0, 1

          # copy iter($t0) to floating point unit and convert to double($f18)
          mtc1 $t0, $f2
          cvt.d.w $f18, $f2
          # divide valueI($f16) by iter($f18)
          div.d $f16, $f16, $f18

          # add valueI($f16) to result($f0) sum
          add.d $f0, $f0, $f16

          # increase iter($t0) by 1
          addi $t0, $t0, 1

          # jump to loop begin if iter($t0) is smaller than maxIt($s0)
          blt $t0, $s0, sin0Loop
# end sin0Loop
          # else jump back to calling function
          jr $ra

# HELPER-FUNCTIONS
# this functions are for nicer code or error handling

##
 # Sets all real constants to the needed values. After this method the registers $f20 - $f31 as
 # well as $s0 - $s7 are set according to the notes given before main
 ##
setConstants:
              # load constant PI
              l.d $f20, pi
              # load constant PI/2
              l.d $f22, piHalf

              # load iteration limit
              lw $s0, maxIt

              # jump back to calling function
              jr $ra

##
 # Handles restart of the program in case of an error
 # This function is called by all error handlers after printing some error output to jump back to
 # the beginning of the main function
 ##
restart:
        # load and display restart message
        li $v0, 4
        la $a0, restartM
        syscall

        # restart by jumping to main again
        j main

##
 # Handles error with interval size
 # Handles the case if Xmax is smaller than Xmin. In this case it prints an error message and
 # restarts the program using the restart routine
 ##
wIError:
        # load and display wrong interval error message
        li $v0, 4
        la $a0, wrongInterv
        syscall

        # restart the program
        j restart

##
 # Handles negative stepsize
 # Handles the case if step is choosen smaller than 0. In this case it prints an error message and
 # restarts the program using the restart routine
 ##
wSError:
        # load and display wrong step error message
        li $v0, 4
        la $a0, negativeStep
        syscall

        # restart the program
        j restart
