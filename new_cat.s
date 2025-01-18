global _start


%define SYSCALL_open 2
%define SYSCALL_EXIT 60
%define SYSCALL_read 0
%define SYSCALL_write 1
%define STDOUT 1
%define STDIN 0

     ;;xorl %%ebp, %%ebp //zero ebp
     ;;movq %%rsp, %[argc_argv_ptr]
    
     ;;callq %[posixCallMainAndExit:P]

section .text
_start:
    xor rbp,rbp
    pop rdi ; argc
    mov rsi, rsp
    and rsp, 0xfffffffffffffff0

    mov rbp, rsp
    call _main
    mov r8, rax; Return value of main


    mov rax, 60
    mov rdi, r8
    syscall

_main:
    push rbp; begin stack frame
    mov rbp, rsp
    sub rsp, 32

    mov [rbp-16], rsi; argv
    mov [rbp-24], rdi; argc
    mov rcx,1
    mov [rbp-8],rcx ; counter

    cmp rdi, 1 ; we need more than 1 argument
    jg args_good
    mov rax, SYSCALL_EXIT
    mov rdi, 2
    syscall
args_good:
    
arg_loop: 
    mov r11, [rbp-8] ; 
    imul r11, 8
    add r11, [rbp-16]

    mov rdi, [r11]
    call catFile

    ;mov rdi, fmtStr; first
    ;mov rsi, [r11]
    ;call printf

    mov rcx, [rbp-8]

    inc rcx
    mov [rbp-8], rcx
    cmp rcx, [rbp-24]
    jne arg_loop



    ;pop rbp;
    ;sub     esp, 4          ; Allocate space on the stack for one 4 byte parameter

    ;lea     eax, [fmtStr]
    ;mov     [esp], eax      ; Arg1: pointer to format string
    ;call    printf         ; Call printf(3):
    ;                        ;       int printf(const char *format, ...);

    pop rbp
    add rsp, 32

    mov rax, 0 ;return zero
    ret

catFile: ; filename is in rdi
    push rbp
    mov rbp, rsp

    mov rax, SYSCALL_open; open syscall
    ;rdi already contains filename
    mov rsi, 0; no flags
    mov rdx, 0; read only flag
    syscall

    cmp rax, 0 
    mov r8, 5
    jl error_end ;check error

    mov r13, rax

read_loop:
    mov rax, SYSCALL_read ; fd, buf, count
    mov rdi, r13 ;fd
    mov rsi, read_buffer
    mov rdx, 256
    syscall

    cmp rax, 0
    mov r8, 4
    jl error_end
    je printfn_end ; terminate once we reach eof rax already 0

    mov r14, read_buffer
    mov r15, rax ; Length we read 

    mov rax, SYSCALL_write
    mov rdi, STDOUT
    mov rsi, r14
    mov rdx, r15
    syscall

    jmp read_loop   

printfn_end:

    pop rbp
    ret

error_end:
    mov rax, SYSCALL_EXIT
    mov rdi, r8
    syscall

section .bss
read_buffer: resb 256
