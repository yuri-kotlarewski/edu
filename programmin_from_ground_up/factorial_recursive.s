# PURPOSE: Given a number, this program computes the factorial.
#          
# This program shows how to call functions recursively.

.section .data                # This program has no global data

.section .text

.globl _start
.globl factorial              # This is unneeded unless we want to
                              # share this function among other
                              # programs.
_start:
  pushl $4                    # The factorial takes one argument -
                              # the number we want a factorial of.
                              # So, it get's push.
  call  factorial             # Run tha factorial function
  addl  $4, %esp              # Scrubs the parameter that we pushed
                              # on the stack
  movl  %eax, %ebx            # Factorial returns the answer in
                              # %eax, but we want it in %ebx to send
                              # it as our exit status.
  movl  $1, %eax              # Call the kernel's exit function
  int   $0x80



.type factorial, @function    # This is the actual function
                              # definitionю
factorial:
  pushl %ebp                  # Standard function stuff - we have to
                              # restore %ebp to it's prior state
                              # before returning, so we have to
                              # push it.
  movl  %esp, %ebp            # This is because we don't want to
                              # modify stack pointer, so we use 
                              # %ebp.
  movl  8(%ebp), %eax         # This moves the first argument to 
                              # %eax.
  cmpl  $1, %eax              # If the number is 1, that is our base
                              # case, and we simply return(1 is
                              # already in %eax as the return value)
  je    end_factorial
  decl  %eax                  # Otherwise decrease the value
  pushl %eax                  # Push it for our call to factorial
  call  factorial             # Call factorial
  movl  8(%ebp), %ebx         # %eax has the return value, so we
                              # reload our parameter into %ebx.
  imull %ebx, %eax            # multiply that by result of last call
                              # to factorial(in %eax) the answer is
                              # stored in %eax, which is good since
                              # that's where return values go.
  
end_factorial:
  movl  %ebp, %esp            # Standard function return stuff - we
  popl  %ebp                  # have to restore %ebp and %esp to
                              # where they were before the function
                              # started.
  ret                         # Return to the function(this pops
                              # the return value. too).
