# PURPOSE: Function for evaluating factorial of a number.
#
# VARIABLES:
#          %eax - holds the result
#          %ecx - holds the counter

.section .data

.section .text
.globl   _start

_start:
  movl $1, %eax      # result before first iteration
  movl $5, %ecx      # the number to factorial

loop_start:
  cmpl  $1, %ecx     # if the number is 1, we're done
  je    loop_end
  imull %ecx, %eax   # otherwise get product and store
                     # it in %eax
  decl  %ecx         # decrease the counter
  jmp   loop_start   # repeat

loop_end:
  movl %eax, %ebx    # we want to see result
  movl $1, %eax      # leave message for the kernel
  int  $0x80         # wake the kernel up
