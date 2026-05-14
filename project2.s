# Project 2 CMSC 313
# Author: Jacob Fruchey
# Email: ui41773@umbc.edu
# Description: Doubling a number that the user inputs

# Start of the code
.global _start

# This section is for the words we want to print out for the question and the output
.section .data

# This is the question ascii values and we also want to store the length of the ascii values
question:
    .ascii "What number do you want to double? "
question_len = . - question

# This is the answer ascii values and we also store the length of the ascii values
answer:
    .ascii "The double is: "
answer_len = . - answer

# This tells the code that the num entered should be a 4 byte number
.section .bss
.lcomm num, 4


# This is the text section of the code
# This will be where the start function is called and all the other functions will be called
.section .text

# This is the start function and calles the other functions that take in the number and double
_start:
    # Calls the printQuestion, getNumber, and doubleNumber functions
    # These functions print the question, get the users inputed number, and then convers the number to integers and doubles it
    call _printQuestion 
    call _getNumber
    call _doubleNumber

    # This moves the doubled number from the rax register to the rbx register for setting up the printOutput function
    mov %rax, %rbx

    # Calles the printOutput function
    # THis function converts the doubled number back into ascii and prints it
    call _printOutput

    # These lines exit the code
    mov $60, %rax       
    xor %rdi, %rdi      
    syscall            



# This function simply prints the question about doubling a number

_printQuestion:
    # Sets the first register and argument to 1 for printing the question
    mov $1, %rax
    mov $1, %rdi

    # Prints the question with the length stored in the third register
    lea question(%rip), %rsi
    mov $question_len, %rdx

    # Ends the function
    syscall
    ret

# This function simply grabs the number that the user entered

_getNumber:
    # rax and rdi at 0 means its looking for a user input and 
    mov $0, %rax
    mov $0, %rdi

    # This grabs the users input and the 4 means that the number will be 4 bytes big
    lea num(%rip), %rsi
    mov $4, %rdx

    # Ends the function
    syscall
    ret


# This function takes the inputed number that the user entered, converts it to an integer and then doubles it
# The convertion is done through .convert which is a loop

_doubleNumber:
    # Grabs the input that the user entered before and enters the convert loop and sets rax to 0
    lea num(%rip), %rsi
    xor %rax, %rax

.convert:

    # This section reads one byte from memory at a time and checks to see if its a new line and jumps to .done if it is
    movzbq (%rsi), %rbx
    cmp $10, %rbx
    je .done

    # This subtracts the ascii 0 to the value converting it into the integer value
    sub $'0', %rbx

    # This then rebuilds the number into the integer value
    imul $10, %rax
    add %rbx, %rax

    # This then sets the string to the next character and jumps back to the top of .convert
    inc %rsi
    jmp .convert

.done:
    # This will double the number after it has been converted into an integer and then end the function
    add %rax, %rax
    ret


# This function gets the newly converted doubled number and reconverts it back into ascii and prints it along with a message
# Just like doubleNumber, it also uses a loop to go through and convert the double number back into its ascii value

_printOutput:
    
    # This, just like in printQuestion sets the register and argument to 1
    mov $1, %rax
    mov $1, %rdi

    # And also just like printQuestion grabs the string from answer and prints it and saves its length
    lea answer(%rip), %rsi
    mov $answer_len, %rdx
    syscall

    # This leaves 32 bytes of memory open in the stack and makes the last byte point to the beginning of the newly converted number
    sub $32, %rsp
    mov %rsp, %rsi
    add $31, %rsi

    # This then adds a newline at the end and tracks the length of the string
    movb $10, (%rsi)
    mov $1, %rcx

.convertBack:

    # This sets rdx to 0 which sets the code up for base 10 division and the number is moved into rax
    xor %rdx, %rdx
    mov $10, %r8
    mov %rbx, %rax

    # This divides the number by 10
    div %r8

    # Stores the number back into rbx
    mov %rax, %rbx

    # This converts the number back into ascii by adding ascii 0 to it and then setting the pointer to the next digit
    add $'0', %dl
    dec %rsi

    # This writes the ascii into the memory and tracks how many character are outputted
    mov %dl, (%rsi)
    inc %rcx

    # This tests to see if rax is not zero and if it is then it continues the loop and jumps back to .convertBack
    test %rax, %rax
    jnz .convertBack

    # This is similar to the other print statements except this time, we are printing the number from memory
    # so setting the register and argument to 1 sets this up
    mov $1, %rax
    mov $1, %rdi

    # And then we are grabbing our newly converted number and printing it
    mov %rsi, %rsi
    mov %rcx, %rdx

    # This will end the function and clean up what is leftover in the register
    syscall
    add $32, %rsp
    ret