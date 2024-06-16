section .text
global _start
extern write
extern exit
extern strlen

_start:
    ; Code to iterate through argv and print each argument to stdout
    ; Example implementation (pseudocode)

    pop    dword ecx    ; ecx = argc
    mov    esi, esp    ; esi = argv

    ; Loop through each argument (skip argv[0] which is the program name)
    xor    eax, eax    ; eax = 0, for setting syscall number later
    add    esi, 4      ; Skip argv[0] (program name)
    dec    ecx         ; Decrement argc to exclude argv[0]

print_args_loop:
    ; Load address of current argument (argv[esi]) into edi
    mov    edi, [esi]

    ; Call strlen to get length of current argument
    push   edi          ; Push argument address as parameter to strlen
    call   strlen
    add    esp, 4       ; Adjust stack after function call, pop argument address

    ; Prepare syscall parameters for write
    mov    ebx, 1       ; File descriptor 1 (stdout)
    mov    ecx, edi     ; Pointer to the current argument
    mov    edx, eax     ; Length of the current argument (from strlen)
    mov    eax, 4       ; Syscall number for write

    ; Perform write syscall
    int    0x80

    ; Write a newline character after each argument
    mov    eax, 4       ; Syscall number for write
    mov    ebx, 1       ; File descriptor 1 (stdout)
    mov    ecx, newline ; Address of newline character
    mov    edx, 1       ; Length of newline character
    int    0x80

    ; Move to the next argument
    add    esi, 4       ; Move to next argv entry
    dec    ecx          ; Decrement counter (argc)

    ; Check if there are more arguments
    jnz    print_args_loop

    ; Exit program normally
    mov    eax, 1       ; Syscall number for exit
    xor    ebx, ebx     ; Return status 0
    int    0x80

section .data
    newline db 10        ; Newline character '\n'



