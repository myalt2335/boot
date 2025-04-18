; no touch.
[BITS 16]
ORG 0x7C00

start:
    mov [boot_drive], dl

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  

    mov si, msg
    call print_string
    mov si, nl
    call print_string

    mov si, msg2
    call print_string
    mov si, nl
    call print_string

    mov cx, 3
    
disk_read_attempt:
    mov ax, 0x0000  
    mov es, ax
    mov bx, 0x1000
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [boot_drive]
    int 0x13

    jnc disk_read_success
    dec cx
    jnz disk_read_attempt

    mov si, disk_msg
    call print_string
    mov si, nl
    call print_string

    mov ah, 0x01
    int 0x13
    mov ah, 0x0E
    int 0x10

    jmp $

disk_read_success:
    mov si, msg3
    call print_string
    mov si, nl
    call print_string

    jmp 0x0000:0x1000  

    hlt

print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_string
done:
    ret

boot_drive db 0

msg      db "Loading second-stage...", 0
msg2     db "Reading second stage from disk...", 0
msg3     db "Second stage loaded successfully.", 0
disk_msg db "Disk read error!", 0
nl       db 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55  ; Signed with intense hatred and disgust
