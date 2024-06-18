global Infile 
global Outfile 

section .data                   ; Initialize static/global variables               
    Infile dd 0                 ; 0 is the standard input
    Outfile dd 1                ; 1 is the standard output
    buff db 1                   ; Defines a byte-sized buffer
    newLineChar db 0x0A         ; Newline character (ASCII value)
    stderr: equ 2               ; Defines a constant stderr with a value of 2 (stdrr)
    extern strlen               ; From util.c
    error_msg db 'Error opening file', 0x0A, 0  ; Error message with newline and null terminator
     

section .text
global _start

_start:                         ; Defines the start of the program
    call main                   
    call encoder
    jmp exit

main:
    push ebp                    ; Saves the base pointer
    mov ebp, esp                ; Move the stack pointer to ebp
    mov edi, [ebp+12]           
    mov esi, 0                  ; Initializes a counter esi to 0
      
    processArguments:          ; Loop for processing arguments
        mov ecx, [ebp + 8]     ; argc
        cmp esi, ecx           ; Compare between the number of the arguments and the counter
        jne InputOutputSupport       ; If the esi register is not equal to argc - go to InputOutputSupport
        mov eax, 0             ; Successful 
        pop ebp                ; Clean up the stack before returning from a function
        ret                    ; Transfers control back to the calling function


    InputOutputSupport:
        mov edx, edi           ; edi contains a pointer to the current argument being processed
        cmp byte[edx], '-'
        jne print               

        inc edx                 ; Skip '-'
        cmp byte[edx], 'o'      
        je getOutput  
        cmp byte[edx], 'i'      ; Check for '-i' option
        je getInput             ; Jump to getInput if 'i'
        jmp print   
        ;jne checkIfInput


    ;checkIfInput:
    ;    cmp byte[edx], 'i'
    ;    je getInput

getInput:
    inc edx                 ; Skip 'i' 
    mov ebx, edx            
    mov eax, 5            
    mov ecx, 0              ; File is open for reading
    mov edx, 0644o
    int 0x80
    cmp eax, 0              ; If eax < 0 exit the program
    jl _error 
    mov [Infile], eax
    jmp print


    getOutput:
    inc edx                 ; Skip 'o'
    mov ebx, edx            ; Move the pointer to the file name to ebx
    mov eax, 5              ; Load the syscall number for open into eax
    mov ecx, 0x41           ; Set the flags for the open syscall
    mov edx, 0644o           ; Set file permissions 
    int 0x80                ; Execute the sys call with the parameters set in 'eax', 'ebx', 'ecx', 'edx'
    mov [Outfile], eax      ; Store the file descriptor (returned in eax) into the Outfile 
    jmp print


    print:                     
    mov ebx, stderr         ; Setting ebx as the file descriptor for standard error
    push edi                    ; Pushing the curreent string argument to the stack
    call strlen                 ; Calculates the length of the string (that edi points on) and stores it in eax
    mov edx, eax                ; edx will hold the count of bytes to write
    mov ecx, edi                ; ecx will hold the address of the buffer to write
    mov eax, 4                  ; sys_write
    int 0x80                    ; Execute the sys call that in eax
    pop edi                 
    mov ebx, stderr
    mov edx, 1                  ; Len of newline character
    mov ecx, newLineChar    
    mov eax, 4                  ; sys_write
    int 0x80                    ; Execute the sys call that in eax
    mov edi, [ebp+4*esi + 16]   ; Calculate next argument and move the pointer into the edi register
    inc esi                     ; Moving to the next argument
    jmp processArguments
    ;jmp main


encoder:
    encode:
        mov eax, 3                 ; sys_read 
        mov ebx, [Infile]          ; Store the file descriptor of the input file into ebx
        mov ecx, buff              
        mov edx, 1                 ; 1 byte to read each time
        int 0x80                   
        cmp eax, 0                 
        jne checkRange             ; If the value in eax is not 0 (we read a byte), jump to checkRange

    ; If eax is 0 close the file                                    
        mov eax, 6                 ; sys_close 
        mov ebx, [Infile]          
        int 0x80                   
        mov eax, 6                
        mov ebx, [Outfile]        
        int 0x80                   
        jmp exit                

    checkRange:
        cmp byte [buff], 'A'       
        jl write               ; If the byte in buff is less than 'A', jump to write (no encoding needed)
        cmp byte [buff], 'z'       
        jg write               ; If the byte in buff is greater than 'z', jump to write 
        add byte [buff], 1     ; Else - increment the byte in buff by 1 (encoding)

    write:
        mov eax, 4                 ; sys_write 
        mov ebx, [Outfile]       
        mov ecx, buff              
        mov edx, 1                 ; Number of bytes to write (1) into the edx register
        int 0x80                
        jmp encode           ; Jump back to encode to read and process the next byte


_error:
  _error:
    ; Print the error message
    mov eax, 4              ; Syscall number for sys_write
    mov ebx, stderr         ; File descriptor 2 (stderr)
    mov ecx, error_msg      ; Pointer to the error message
    mov edx, 18             ; Length of the error message (including newline)
    int 0x80                ; Invoke syscall to print the error message
    
    ; Print a newline character
    mov eax, 4              ; Syscall number for sys_write
    mov ebx, stderr         ; File descriptor 2 (stderr)
    mov ecx, newLineChar    ; Pointer to the newline character
    mov edx, 1              ; Length of the newline character (1 byte)
    int 0x80                ; Invoke syscall to print the newline character

    ; Exit the program with an error code
    mov eax, 1              ; Syscall number for exit
    mov ebx, 1              ; Exit code 1 (or appropriate error code)
    int 0x80                ; Invoke syscall to exit

exit:
    mov ebx, stderr             ; sterr
    mov edx, 1              
    mov ecx, newLineChar      
    mov eax, 4
    int 0x80
    mov eax, 1                  ; Exit sys call
    xor ebx, ebx
    int 0x80





