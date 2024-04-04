
build: clean
	gcc -o cipher.exe cipher.c 
	nasm -f bin loader.asm
	nasm -f bin payload.asm 

run: 
	qemu-system-i386 -hda image.bin 

debug:
	./cipher.exe bootload
	qemu-system-i386 -hda image.bin -s -S 
	
gdb: 
	gdb -ex "target remote localhost:1234"\
		-ex "set arch i8086"\
		-ex "set disassembly-flavor intel"\
		-ex "b *0x7c00"\
		-ex "c"\
		-ex "b *0x7c42"\
		-ex "c"\
		-ex "b *0x7c90"\
		-ex "c"\
		-ex "x/40i $eip"\
		-ex "b *0x7c9d"
		
clean: 
	@rm -vf *exe loader payload image.bin
	
