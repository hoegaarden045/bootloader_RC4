	BITS 16

	mov ax, 0x7e0
	mov ds, ax
	mov ax, 0xb800
	mov es, ax

	mov ax, 3
	int 0x10

	xor di, di
	mov si, msg
	mov ah, 0x5f

next:
	lodsb
	test al, al
	jz end
	stosw
	jmp next

end: jmp $
msg:
	db "Wow! It works", 0 

