; for the love of all that is holy NEVER touch this code. one slight change, such as a different byte size in this file when built, will cause a LOT of failures.
[BITS 16]
ORG 0x1000

start:
    cli
    mov ax, 0
    mov ds, ax

    mov si, debug_real_mode
    call print_string

    call enable_a20         
    mov si, debug_a20
    call print_string

    lgdt [gdt_descriptor]
    mov si, debug_gdt_loaded
    call print_string

    call copy_kernel

    call dump_memory

    call switch_to_pm

    mov si, debug_failed_pm
    call print_string      
    jmp $

print_string:
    lodsb
    test al, al
    je .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

enable_a20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

copy_kernel:
    mov si, 0x1000 + 360 ; This is why this file is no touchy. + 360 is this file's size, if that changes this breaks. No, I am NOT dynamically doing this that's way too much effort when this works.
    
    mov ax, 0x1000
    mov es, ax            
    xor di, di
    
    mov cx, 96            
    rep movsb
    ret

dump_memory:
    mov si, debug_memory_dump
    call print_string

    mov ax, 0x1000
    mov ds, ax
    xor si, si
    
    mov cx, 16
.loop:
    lodsb
    call print_hex
    loop .loop
    ret

print_hex:
    pusha
    mov ah, 0x0E
    mov bl, al
    shr al, 4
    call print_nibble
    mov al, bl
    and al, 0x0F
    call print_nibble
    mov al, ' '  
    int 0x10
    popa
    ret

print_nibble:
    add al, '0'
    cmp al, '9'
    jbe .print
    add al, 7
.print:
    int 0x10
    ret

switch_to_pm:
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp dword CODE_SEG:init_pm

[BITS 32]
init_pm:
    call clear_screen

    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x7C00

    mov esi, pm_message
    mov edi, 0xB8000
    call print_pm

    mov esi, debug_pm_success
    call print_pm

    mov esi, debug_before_jump
    call print_pm
    
    jmp CODE_SEG:0x10000  

clear_screen:
    mov edi, 0xB8000
    mov eax, 0x07200720
    mov ecx, 2000
    rep stosd
    ret

print_pm:
.loop:
    lodsb
    test al, al
    je .done
    mov ah, 0x07
    mov [edi], ax
    add edi, 2
    jmp .loop
.done:
    ret

gdt_start:
    dq 0
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start
    align 4

CODE_SEG equ 0x08
DATA_SEG equ 0x10

pm_message         db "Hello from Protected Mode! ", 0
debug_real_mode    db "RM ", 0
debug_a20          db "A20 ", 0
debug_gdt_loaded   db "GDT ", 0
debug_pm_success   db "SUCCESS", 0
debug_before_jump  db "JUMP ", 0
debug_failed_pm    db "FAILED", 0
debug_memory_dump  db "MEM ", 0
