# boot
The worst bootloader ever made

# Why
I was bored

# How do you run it
I used NASM to make BIN files out of the assembly so that'll probably help you. I personally just concatenated the files to run it quickly, being a windows user that would be 

Get-Content -Path boot.bin, bootstrapper.bin, kernel.bin -Encoding Byte -Raw | Set-Content -Encoding Byte raw.img

then I just ran it with QEMU

qemu-system-x86_64 -drive format=raw,file=raw.img -no-reboot -no-shutdown -d int,cpu_reset

That's all.
