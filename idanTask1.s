global Infile ; Declare global variable 
global Outfile ; Declare global variable 

section .data                   ; Initialize static/global variables               
    Infile dd 0                 ; 0 is the standard input
    Outfile dd 1                ; 1 is the standard output
    consoleOut: equ 2           ; Defines a constant consoleOut with a value of 2 (stdrr)
    newLineChar db 0x0A         ; Newline character
    buff db 1                   ; Defines a byte-sized buffer
    extern strlen               ; From util.c
     

section .text
global _start

_start:                         ; Defines the start of the program
    call main                   
    call encoder
    jmp exitAll

main:
    push ebp                    ; Saves the base pointer
    mov ebp, esp                ; Move the stack pointer to ebp
    mov edi, [ebp+12]           
    mov esi, 0                  ; Initializes a counter esi to 0

      
    mainLoop:                  ; Loop for processing arguments
        mov ecx, [ebp + 8]     ; argc
        cmp esi, ecx           ; Compare between the number of the arguments and the counter
        jne continueLoop       ; If the esi register is not equal to argc - go to continueLoop
        mov eax, 0             ; Successful 
        pop ebp                ; Clean up the stack before returning from a function
        ret                    ; Transfers control back to the calling function

    continueLoop:
        mov edx, edi           ; edi contains a pointer to the current argument being processed
        cmp byte[edx], '-'
        jne print               

        inc edx                 ; Skip '-'
        cmp byte[edx], 'o'      
        je oFunc                
        jne checkIfInput


    checkIfInput:
        cmp byte[edx], 'i'
        je iFunc

    oFunc:
        inc edx                 ; Skip 'o'
        mov ebx, edx            ; Move the pointer to the file name to ebx
        mov eax, 5              ; Load the syscall number for open into eax
        mov ecx, 0x41           ; Set the flags for the open syscall
        mov edx, 0777           ; Set file permissions 
        int 0x80                ; Execute the sys call with the parameters set in 'eax', 'ebx', 'ecx', 'edx'
        mov [Outfile], eax      ; Store the file descriptor (returned in eax) into the Outfile 
        jmp print

    iFunc:
        inc edx                 ; Skip 'i' 
        mov ebx, edx            
        mov eax, 5              
        mov ecx, 0              ; File is open for reading
        mov edx, 0777
        int 0x80
        mov [Infile], eax
        jmp print



     print:                     ;;;;;;; stopped hereeeee
        mov ebx, consoleOut     ;make pointer to the console
        push edi                ;for saving it
        call strlen             ;strlen - the return value is in eax
        mov edx, eax
        mov ecx, edi
        mov eax, 4          
        int 0x80                ;execute the sys call that in eax.
        pop edi 
        mov ebx, consoleOut
        mov edx, 1              ;len of new line char
        mov ecx, newLineChar      
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
    mov ecx, newLineChar      
    mov eax, 4
    int 0x80
    mov eax, 1              ;exit sys call
    xor ebx, ebx
    int 0x80
