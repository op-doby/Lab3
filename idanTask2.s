
section .data
    messege: db " Hello, Infected File", 10, 0    ; Define a message string that ends with a newline

section .text
    global _start                             ; Declare _start as a global symbol
    global system_call                        ; Declare system_call as a global symbol
    global infection                          ; Declare infection as a global symbol
    global infector                           ; Declare infector as a global symbol
    extern main                               ; Declare main as an external symbol (defined elsewhere)

code_start:

_start:                                      ; Entry point of the program
    pop dword ebx                             
    mov edi, esp                              
    mov edx, ebx                              
    shl edx, 2                                ; Multiply the number of arguments by 4 (size of each argument)
    add edx, edi                              
    add edx, 4                                ; Skip the NULL pointer at the end of the arguments
    push dword edx                            
    push dword edi                            
    push dword ebx                            
    call main                                 
    xchg eax, ebx                             ; Swap the return value of main (in eax) with ebx
    mov eax, 1                                ; yscall number 1 (exit)
    int 0x80                                  ; syscall exit 
    nop                                       

;from start.s code in the moodle
system_call:                                  ; Save caller state
    push ebp                                  
    mov ebp, esp                              ; Leave space for local var on stack
    sub esp, 4                                ; Make room for local variable
    pushad                                    ; Save some more caller state
    mov eax, [ebp+8]                          ; Copy function args to registers: leftmost
    mov ebx, [ebp+12]                         ; Next argument...
    mov ecx, [ebp+16]                         ; Next argument...
    mov edx, [ebp+20]                         ; Next argument...
    int 0x80                                  ; Transfer control to operating system
    mov [ebp-4], eax                          ; Save returned value..
    popad                                     ; Restore caller state (registers)
    mov eax, [ebp-4]                          ; place returned value where caller can see it
    add esp, 4                                ; Restore caller state
    pop ebp                                   ; Restore caller state
    ret                                       ; Back to caller

infection:                                    
    push ebp                                  ; Save the old base pointer value
    mov ebp, esp                              
    pushad                                    
    mov ebx, 1                                
    mov eax, 4                                ; Syscall number 4 is write
    mov ecx, messege                          
    mov edx, 22                               
    int 0x80                                  ; system call (write)
    popad                                     
    mov esp, ebp                              ; Clean up the stack frame
    pop ebp                                   
    ret                                       

infector:                                     
    push ebp                                  
    mov ebp, esp                              
    sub esp, 4                                
    pushad                                    ; Save all general-purpose registers
    mov eax, 5                                
    mov ebx, [ebp+8]                          ; Get the filename from the argument
    lea ecx, [0x441]                          
    lea edx, [0777]                           
    int 0x80                                  
    push eax                                  
    mov ebx, eax                              
    mov eax, 4                                
    mov ecx, code_start                       ; Address of the code to write
    lea edx, [code_end - code_start]          ; Length of the code to write
    int 0x80                                  
    pop ebx                                 
    mov eax, 6                                
    int 0x80                                  
    popad                                     
    mov eax , [ebp-4]                        
    add esp, 4                                
    pop ebp                                   
    ret                                       

code_end:                                     

