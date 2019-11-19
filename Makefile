#Need to use gross compiler

GCCPARAMS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
ASPARAMS = --32 
LDPARAMS =  -ffreestanding -O2 -nostdlib -lgcc

objects = boot.o kernel.o



%.o: %.c
	i686-elf-gcc  $(GCCPARAMS) -o $@ -c $<

%.o: %.s
	i686-elf-as -o $@ $<

	
%.o: %.asm
	nasm -f elf32  -o $@ $<


basickernel.bin: linker.ld $(objects)
	i686-elf-gcc $(LDPARAMS) -T $< -o $@ $(objects)
	
kernel.bin: linker.ld $(objects)
	i686-elf-gcc $(LDPARAMS) -T $< -o $@ $(objects)

kernel.iso: kernel.bin
	mkdir -p isodir/boot/grub
	cp kernel.bin isodir/boot/kernel.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue /usr/lib/grub/i386-pc -o myos.iso isodir
	#apt-get install grub-pc

run: mykernel.iso
	(killall VirtualBox && sleep 1) || true
	VirtualBox --startvm 'My Operating System' &

install: mykernel.bin
	sudo cp $< /boot/mykernel.bin
	
clean: 
	rm *.o -rf
	rm *.bin -rf

