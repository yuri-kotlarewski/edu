# PURPOSE:    This program convert an input file to output file with all letters
#             converted to uppercase.
#
# PROCESSING: 1) Open the input file
#             2) Open the output file
#             3) While we're not at the end of the input file
#                a) read part of file into our memory buffer
#                b) go through each byte of memory
#                      if the byte is lower-case letter, convert it to uppercase
#                c) write the memory buffer to output file

# LOD             INSTR   OPERANDS             COMMENTS

.section .data
                                               # CONSTANTS
                                               # system call numbers
                  .equ    SYS_OPEN, 5
                  .equ    SYS_WRITE, 4
                  .equ    SYS_READ, 3
                  .equ    SYS_CLOSE, 6
                  .equ    SYS_EXIT, 1

                                               # options for open
                  .equ    O_RDONLY, 0
                  .equ    O_CREAT_WRONLY_TRUNC, 03101

                                               # standard file descriptors
                  .equ    STDIN, 0
                  .equ    STDOUT, 1
                  .equ    STDERR, 2
                                               # system call interrupts
                  .equ    LINUX_SYSCALL, 0x80
                  .equ    END_OF_FILE, 0
                  .equ    NUMBER_ARGUMENTS, 2

.section .bss
                  .equ    BUFFER_SIZE, 500
                  .lcomm  BUFFER_DATA, BUFFER_SIZE

.section .text
                                               # STACK POSITIONS
                  .equ    ST_SIZE_RESERVE, 8
                  .equ    ST_FD_IN, -4
                  .equ    ST_FD_OUT, -8
                  .equ    ST_ARGC, 0           # Number of arguments
                  .equ    ST_ARGV_0, 4         # Name of program
                  .equ    ST_ARGV_1, 8         # Input file name
                  .equ    ST_ARGV_2, 12        # Output file name

.globl _start
_start:           movl    %esp, %ebp           # Save the stack pointer
                  subl    $ST_SIZE_RESERVE, %esp # Allocate space for descriptors
open_files:
open_fd_in:       movl    $SYS_OPEN, %eax
                  movl    ST_ARGV_1(%ebp), %ebx
                  movl    $O_RDONLY, %ecx
                  movl    $0666, %edx
                  int     $LINUX_SYSCALL
store_fd_in:      movl    %eax, ST_FD_IN(%ebp)
open_fd_out:      movl    $SYS_OPEN, %eax
                  movl    ST_ARGV_2(%ebp), %ebx
                  movl    $O_CREAT_WRONLY_TRUNC, %ecx
                  movl    $0666, %edx
                  int     $LINUX_SYSCALL
store_fd_out:     movl    %eax, ST_FD_OUT(%ebp)
read_loop_begin:  movl    $SYS_READ, %eax
                  movl    ST_FD_IN(%ebp), %ebx
                  movl    $BUFFER_DATA, %ecx 
                  movl    $BUFFER_SIZE, %edx
                  int     $LINUX_SYSCALL
                  cmpl    $END_OF_FILE, %eax
                  jle     end_loop             # if eof or error, go to the end
continue_read_loop:                            # CONVERT THE BLOCK TO UPPERCASE
                  pushl   $BUFFER_DATA         # Location of the buffer
                  pushl   %eax                 # Size of the buffer
                  call    convert_to_upper
                  popl    %eax                 # Get the size back
                  addl    $4, %esp             # Restore %esp
                                               # WRITE THE BLOCK OUT TO THE OUTPUT FILE
                  movl    %eax, %edx           # Size of the buffer
                  movl    $SYS_WRITE, %eax
                  movl    ST_FD_OUT(%ebp), %ebx # File to use
                  movl    $BUFFER_DATA, %ecx   # Location of the buffer
                  int     $LINUX_SYSCALL
                  jmp     read_loop_begin      # Continue the loop
end_loop:         movl    $SYS_CLOSE, %eax     # CLOSE THE OUTPUT FILE
                  movl    ST_FD_OUT(%ebp), %ebx
                  int     $LINUX_SYSCALL
                  movl    $SYS_CLOSE, %eax     # CLOSE THE INPUT FILE
                  movl    ST_FD_IN(%ebp), %ebx
                  int     $LINUX_SYSCALL
                  movl    $SYS_EXIT, %eax      # EXIT
                  movl    $0, %ebx
                  int     $LINUX_SYSCALL


# PURPOSE:   This function actually does the conversion to upper case for a block
#
# INPUT:     The first parameter is the location of the block of memory to convert
#            The second parameter is the length of that buffer
#
# OUTPUT:    This function overwrites the current buffer with the upper-casified
#            version
#
# VARIABLES: %eax - beginning of buffer
#            %ebx - length of buffer 
#            %edi - current buffer offset
#            %cl - current byte being examined

# LOD             INSTR   OPERANDS             COMMENTS

                                               # CONSTANTS
                  .equ    LOWERCASE_A, 'a'     # The lower boundary of our search
                  .equ    LOWERCASE_Z, 'z'     # The upper boundary of our search
                  .equ    UPPER_CONVERSION, 'A' - 'a'
                                               # STACK STUFF
                  .equ    ST_BUFFER_LEN, 8     # Length of buffer
                  .equ    ST_BUFFER, 12        # Actual buffer

convert_to_upper: pushl   %ebp
                  movl    %esp, %ebp
                                               # SET UP VARIABLES
                  movl    ST_BUFFER(%ebp), %eax
                  movl    ST_BUFFER_LEN(%ebp), %ebx
                  movl    $0, %edi
                  cmpl    $0, %ebx             # If buffer length is 0 - leave
                  je      end_convert_loop
convert_loop:     movb    (%eax,%edi,1), %cl   # Get the current byte
                  cmpb    $LOWERCASE_A, %cl    # Go to the next byte unless it is
                                               # between 'a' and 'z'
                  jl      next_byte
                  cmpb    $LOWERCASE_Z, %cl
                  jg      next_byte
                  addb    $UPPER_CONVERSION, %cl # Otherwise convert the byte to
                                                 # uppercase
                  movb    %cl, (%eax,%edi,1)   # And store it back
next_byte:        incl    %edi                 
                  cmpl    %edi, %ebx           # Continue unless we've reached the end
                  jne     convert_loop
end_convert_loop: movl    %ebp, %esp           # No return value, just leave
                  popl    %ebp
                  ret
