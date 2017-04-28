.data

# CONSTANTS
pi:           .double 3.1415926535
piHalf:       .double 1.57079632675

maxIt:        .word 13 # 2 * 5 (5 iteratons) + 3 for iter start value offset

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
# -1.0:       $f8
# -PI/2       $f10
# iter(double)$f8
# valueI:     $f16
#
# iter:       $t0

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
sin0loop:
          # multiply valueI($f16) with x($f12) and -x($f6)
          mul.d $f16, $f16, $f12
          mul.d $f16, $f16, $f6

          # copy iter($t0) to floating point unit and convert to double
          mtc1 $t0, $f2
          cvt.d.w $f8, $f2
          # divide valueI($f16) by iter($f6)
          div.d $f16, $f16, $f0

          # increase itwe($t0) by 1
          addi $t0, $t0, 1

          # copy iter to floating point unit and convert to double
          mtc1 $t0, $f2
          cvt.d.w $f8, $f2
          # divide valueI($f16) by iter($f6)
          div.d $f16, $f16, $f0

          # add valueI($f16) to result($f0) sum
          add.d $f0, $f0, $f16

          # increase iter($t0) by 1
          addi $t0, $t0, 1

          # jump to loop begin if iter($t0) is smaller than maxIt($s0)
          blt $t0, $s0, sin0loop

          # else jump back to calling function
          jr $ra

overInterv:
            # subtract PI($f20) from input($f12) and write to output($f2)
            sub.d $f2, $f12, $f20

            # load -1 to respective register for multiplication with -1
            li.d $f8, -1.0

            # multply result($f2) with -1($f8) (definitely already set correctly in sin)
            # to correct sign errors in later result of sin0
            mul.d $f2, $f2, $f8

            # jump back to the reduction loop of sin
            j sinloop

underInterv:
            # add PI($f20) to the input($f12) and write to output($f2)
            add.d $f2, $f12, $f20

            # multply result($f2) with -1($f8) (definitely already set correctly in sin)
            # to correct sign errors in later result of sin0
            mul.d $f2, $f2, $f8

            # jump back to the reduction loop of sin
            j sinloop

sin:
    # copy input($f12) to return($f4)
    mov.d $f2, $f12

    # reserve space for int on stack
    addi $sp, $sp, -4
    # save stack pointer
    sw $ra, 0($sp)
sinloop:
        # copy result from return register from previous iteration($f2) to helper($f4)
        mov.d $f4, $f2

        # copy x($f4) to argument register($f12) for later jumps
        mov.d $f12, $f4

        # check if x($f4) is smaller than PI/2($f22)
        c.lt.d $f4, $f22
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

        # return to calling function
        # load stack pointer
        lw $ra, 0($sp)
        # free space on stack
        addi $sp, $sp, 4
        jr $ra

setConstants:
              # load constant PI
              l.d $f20, pi
              # load constant PI/2
              l.d $f22, piHalf

              # load iteration limit
              lw $s0, maxIt

              # jump back to calling function
              jr $ra
calc:
      # reserve space for int on stack
      addi $sp, $sp, -4
      # save stack pointer
      sw $ra, 0($sp)
calcloop:
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
      bc1t calcloop

      # else return to main function to end program
      # load stack pointer
      lw $ra, 0($sp)
      # free space on stack
      addi $sp, $sp, 4
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
