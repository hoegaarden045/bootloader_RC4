	BITS 16
	ORG 0x7c00

launch:
	mov ax, 0x7e0
	mov bx, 0
	mov es, ax 

	mov ah, 2
	mov al, 1
	mov cl, 2
	xor ch, ch
	mov dh, 0
	int 0x13
	
;clear display 
	xor ax, ax 
	mov ax, 3
	int 0x10 
		
	call print_mess		;print mess1  

	mov cx, 256
	mov si, 0x6300
	xor ax, ax

;0 - 255 buffer 
mass: 
	mov [si], ax  
	inc ax
	inc si 
	loop mass  

	xor si, si 
	mov cx, 8 
	mov si, 0x6800  

read_key:
	mov ax, 0
	int 0x16 
	mov [si], al 
	inc si 
	mov ah, 0x0e 
	int 0x10 
	loop read_key
	
	call print_mess2		;print mess2 

ksa:
	xor cx, cx 
	xor bx, bx 
	xor ax, ax

	mov dl, 0			;j 
	mov dh, 0			;i 

ksa_cycle:
	mov si, 0x6800
	mov di, 0x6300 
	
	xor ax, ax 
	mov al, dh			;al = i 
	mov bl, 0x8 		;key len l = 8 
	div bl				;i mod 8 -> ah 

	xor cx, cx 
	xor bx, bx 
	mov cl, ah			;store (i mod 8) в cl 
	add si, cx		

	mov bl, [si]		;T[i] store to bl (t[i mod 8]) 
	
	mov cl, dh			;cl = i 
	add di, cx			
	mov bh, [di]		;store S[i] to bh 
						
	add dl, bl			;
	add dl, bh			;get j in (dl)!!!

	;dl = j, dh = 0, bh = S[i] 

	mov di, 0x6300
	mov cl, dl			;j(dl) to cl 
	add di, cx			;get S[j]
	mov bl, 0 
	mov bl, [di]		;bl = S[j]
	mov [di], bh		;S[j] = S[i]

	mov di, 0x6300
	mov cl, dh
	add di, cx	
	mov [di], bl 

	cmp dh, 0xff
	jz prga  
	inc dh 
	jmp ksa_cycle 

prga:
	mov dl, 0			;j
	mov dh, 0			;i 
	xor bx, bx
	xor cx, cx
	xor ax, ax
	mov di, 0x7e00

prga_cycle:
	mov si, 0x6300

	add dh, 0x1			;i = (i + 1)mod(N)
	mov al, dh			;store i
	add si, ax			;get S[i] 
	mov bh, [si]		;store S[i]				fix:bl to bh
	add dl, [si]		;j = (j + S[i])mod(N)

	mov bl, [si]		;store S[j]
	mov si, 0x6300
	xor ax, ax 
	mov al, dl
	add si, ax			;get S[j]

	mov bh, [si]		;store S[j] 
	mov [si], bl		;S[j] = S[i] 

	mov si, 0x6300
	xor ax, ax
	mov al, dh
	add si, ax
	mov [si], bh 

	;t = cl
	xor cx, cx
	add cl, bh
	add cl, bl

	xor ax, ax 
	mov si, 0x6300
	mov al, cl 
	add si, ax 			;get S[t] 

	xor ax, ax  
	mov al, [si]		;store S[t] 

	xor [di], al 

	inc di
	cmp di, 0x8000
	jz end 

	jmp prga_cycle 


print_mess2:
	mov si, msg2 
	mov ah, 0x0e
l2: 
	lodsb
	test al, al 
	jz q2
	int 10h
	jmp l2 
q2:
	ret 


print_mess: 
	mov si, msg1 
	mov ah, 0x0e
l:  
	lodsb
	test al, al 
	jz q
	int 10h 
	jmp l
q: 
	xor di, di 
	ret 


end:
	jmp 0x7e0:0 

msg2:
	db 10, 13, "nothing happens(", 0 

msg1:
	db "GALERKA INC.", 10, 13, "Enter password:", 10, 13, 0 
	times 510-($-$$) db 0
	dw 0xaa55
