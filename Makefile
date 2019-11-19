
# sudo apt-get install g++ binutils libc6-dev-i386
# sudo apt-get install VirtualBox grub-legacy xorriso

GCCPARAMS = -m32 -Wall -O -fstrength-reduce -fomit-frame-pointer -finline-functions -nostdinc -fno-builtin -I./include  -nostdlib 
ASPARAMS = --32 
LDPARAMS = -melf_i386 

objects =main.o start.o 



%.o: %.c
	gcc $(GCCPARAMS) -c -o $@ $<

%.o: %.s
	as $(ASPARAMS) -o $@ $<
	
%.o: %.asm
	nasm -f elf32  -o $@ $<


basickernel.bin: link.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)
	
kernel.bin: link.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

basickernel.iso: mykernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp mykernel.bin iso/boot/mykernel.bin
	echo 'set timeout=0'                      > iso/boot/grub/grub.cfg
	echo 'set default=0'                     >> iso/boot/grub/grub.cfg
	echo ''                                  >> iso/boot/grub/grub.cfg
	echo 'menuentry "My Operating System" {' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/mykernel.bin'    >> iso/boot/grub/grub.cfg
	echo '  boot'                            >> iso/boot/grub/grub.cfg
	echo '}'                                 >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=mykernel.iso iso
	rm -rf iso

run: mykernel.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm 'My Operating System' &

install: mykernel.bin
	sudo cp $< /boot/mykernel.bin
	
clean: 
	rm *.o -rf
	rm *.bin -rf

