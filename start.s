section .text
global _start
global system_call
extern main
_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller







;main
section .data
    msg_endline db 10  ; newline character '\n'
    msg_endline_len equ $ - msg_endline

section .text
global _start
extern write
extern exit
extern strlen

_start:
    ; Initialize loop counter
    mov esi, 1  ; start with argv[1]

print_args_loop:
    ; Load address of current argument (argv[esi]) into edi
    mov edi, [esp + esi * 4]  ; argv[esi]

    ; Calculate length of current argument using strlen (from util.c)
    push edi  ; push argument address as parameter to strlen
    call strlen
    add esp, 4  ; adjust stack after function call, pop argument address

    ; Store length of current argument in ebx (it's the return value of strlen)
    mov ebx, eax  ; eax holds the return value (length)

    ; Prepare parameters for write syscall
    mov eax, 4  ; syscall number for write
    mov edx, ebx  ; length of string to write
    lea ecx, [edi]  ; pointer to the string (current argument)

    ; Perform write syscall (write to stdout)
    int 0x80

    ; Write a newline after each argument
    mov eax, 4
    mov ebx, 1  ; file descriptor 1 (stdout)
    mov ecx, msg_endline  ; address of newline character
    mov edx, msg_endline_len  ; length of newline character
    int 0x80

    ; Increment loop counter and check for end of arguments (argc)
    inc esi  ; move to next argument
    cmp esi, [esp]  ; compare esi with argc (argv[0] holds argc)
    jle print_args_loop  ; jump back to loop if not end of arguments

exit_program:
    ; Exit program normally
    mov eax, 1  ; syscall number for exit
    xor ebx, ebx  ; return status 0
    int 0x80
