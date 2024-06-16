; Declare global variables
global Infile ; Declare global variable Infile
global Outfile ; Declare global variable Outfile

section .data ; initialize static/global variables               
    Infile dd 0                 ; 0 is the standard input
    Outfile dd 1                ; 1 is the standard output
    consoleOut: equ 2           ; File descriptor for console(stderr), const  
    lineChar db 0x0A   
    buff db 1
    extern strlen
     

section .text
    global _start

_start:
    call main
    call encoder
    jmp exitAll

main:
    push ebp                ;use ebp as a reference point for local variables of the current function.
    mov ebp, esp
    mov edi, [ebp+12]        
    mov esi, 0              ;counter

      
    mainLoop:
        mov ecx, [ebp + 8]     ;save argc
        cmp esi, ecx           ;condition - check if there are more arguments
        jne continueLoop
        mov eax, 0 
        pop ebp
        ret

    continueLoop:
        mov edx, edi
        cmp byte[edx], '-'
        jne print

        inc edx                 ;edx store the pointer to a string of characters, so increment it will skip the "-".
        cmp byte[edx], 'o'
        je oFunc
        jne checkIfInput


    checkIfInput:
        cmp byte[edx], 'i'
        je iFunc

    oFunc:
        inc edx                ;skip the "o".
        mov ebx, edx           ;move the file name.
        mov eax, 5              ;open sys call
        mov ecx, 0x41
        mov edx, 0777
        int 0x80                ;execute the sys call that in eax.
        mov [Outfile], eax      ;save the file descriptor from OPEN to Outfile
        jmp print

    iFunc:
        inc edx                 ;skip the "i". 
        mov ebx, edx            ;move the file name.
        mov eax, 5              ;open sys call
        mov ecx, 0              ;file is open for reading
        mov edx, 0777
        int 0x80
        mov [Infile], eax
        jmp print



     print:
        mov ebx, consoleOut    ;make pointer to the console
        push edi                ;for saving it
        call strlen             ;strlen - the return value is in eax
        mov edx, eax
        mov ecx, edi
        mov eax, 4          
        int 0x80                ;execute the sys call that in eax.
        pop edi 
        mov ebx, consoleOut
        mov edx, 1              ;len of new line char
        mov ecx, lineChar      
        mov eax, 4
        int 0x80
        ;calculate next arg
        mov edi, [ebp+4*esi + 16]  
        inc esi                         ;next argument
        jmp mainLoop

      



encoder:
    encoderStart:
        mov eax, 3
        mov ebx, [Infile]
        mov ecx, buff
        mov edx, 1
        int 0x80
        cmp eax, 0
        jne handleCode
        ;close files
        mov eax, 6
        mov ebx, [Infile]
        int 0x80
        mov eax, 6
        mov ebx, [Outfile]
        int 0x80
        jmp exitAll             ;stop the loop

    handleCode:
        cmp byte [buff], 'A'
        jl writeByte
        cmp byte [buff], 'z'
        jg writeByte
        add byte [buff], 1
    
    writeByte:
        mov eax, 4
        mov ebx, [Outfile]
        mov ecx, buff
        mov edx, 1
        int 0x80
        jmp encoderStart        ;next byte


exitAll:
    ;new line char and then exit 
    mov ebx, consoleOut
    mov edx, 1              
    mov ecx, lineChar      
    mov eax, 4
    int 0x80
    mov eax, 1              ;exit sys call
    xor ebx, ebx
    int 0x80
