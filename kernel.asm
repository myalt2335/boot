[BITS 32]
[ORG 0x10000]

start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    mov esp, 0x80000

    call clear_screen

    mov esi, message
    mov edi, 0xB8000
    call print_pm

.hang:
    cli
    hlt
    jmp .hang

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

message db "Hello from Kernel!", 0 