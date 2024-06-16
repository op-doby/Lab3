section .data
hello db 'hello world', 0xA

section .text
global _start

_start:
    mov eax, 4          ; syscall number for sys_write
    mov ebx, 1          ; file descriptor 1 (stdout)
    mov ecx, hello      ; pointer to the hello world string
    mov edx, 12         ; length of the string
    int 0x80            ; make the syscall

    mov eax, 1          ; syscall number for sys_exit
    xor ebx, ebx        ; exit code 0
    int 0x80            ; make the syscall
