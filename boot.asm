[BITS 16]                       ; El modo real necesita instrucciones de 16 bits

[ORG 0x7C00]                    ; La BIOS carga el boot sector en la posición 0x7C00

_start:
        jmp word load_kernel    ; Carga el kernel

welcome         db "Primeros Pasos...",13,10,0        
readdisk        db "Leyendo diskette",13,10,0

;----------Bootsector----------;

load_kernel:
        call clear              ; rutina para borrar la pantalla

        mov si, welcome         
        call puts               ; mostramos el mensaje en pantalla

        jmp read_disk           ; leemos el kernel del diskette 
        hlt

clear:                          ; utilizamos int 0x10 para borrar la pantalla
        mov     al, 02h         ; al = 02h, para video mode (80x25)
        mov     ah, 00h         ; para cambiar el video mode
        int     10h             
        ret
                           
puts:                           ; escribe una linea de texto
        mov ah, 0Eh             ; ah = 0xeh, para escribir una línea en pantalla
	ret
.repeat:
        lodsb                   ; carga un caracter en al
        cmp al, 0               ; compara al con 0 
        je .done                ; "jump equal" a .done 
        int 10h                 
        jmp .repeat             ; seguimos en el bucle
.done:
        ret

read_disk:
        mov ah, 0               ; RESET-command
        int 13h                 
        or ah, ah               ; Miramos si hay error
        jnz read_disk           ; Probamos otra vez si ah != 0
        mov ax, 0
        mov ax, 0                               
        mov es, ax                              
        mov bx, 0x1000          ; El kernel lo vamos a cargar en 0000:1000

        mov ah, 02h             ; READ SECTOR-command
        mov al, 12h             ; número de sectores a leer (0x12 = 18 sectores)
        mov dl, 0x0             ; Load boot disk
        mov ch, 0               ; Cylinder = 0
        mov cl, 2               ; Starting Sector = 3
        mov dh, 0               ; Head = 1
        int 13h                 
        or ah, ah               ; Miramos si hay error
        jnz load_kernel         ; Probamos otra vez si ah != 0
        cli                     ; Deshabilitamos otras interrupciones

        mov si, readdisk        
        call puts               ; mostramos el mensaje en pantalla

enter_pm:
        xor ax, ax              ; Ponemos AX=0x0
        mov ds, ax              ; Ponemos DS=0x0

        lgdt [gdt_desc]         ; Cargamos la tabla GDT 
    
;----------Entramos en Modo Protegido----------;
            
        mov eax, cr0            
        or eax, 1               ; Ponemos a 1 el bit 0     (0xFE = Modo Real)
        mov cr0, eax            ;
    
        jmp 08h:kernel_segments 
    
[BITS 32]                       ; Ahora necesitamos instrucciones de 32 bits
kernel_segments:
        mov ax, 10h             
        mov ds, ax              ; DS y SS tienen que apuntar a un segmento de datos válido
        mov ss, ax              
        mov esp, 090000h        ; Ponemos el stack pointer a 090000h
    
        jmp 08h:0x1000          ; Saltamos donde hemos cargado el kernel
    
;----------Global Descriptor Table----------;

gdt:                            ; Dirección para la GDT

gdt_null:                       ; Segmento Null
        dd 0
        dd 0
    
    
KERNEL_CODE             equ $-gdt
gdt_kernel_code:
        dw 0FFFFh               ; Limit 0xFFFF
        dw 0                    ; Base 0:15
        db 0                    ; Base 16:23
        db 09Ah                 ; Present, Ring 0, Code, Non-conforming, Readable
        db 0CFh                 ; Page-granular
        db 0                    ; Base 24:31

KERNEL_DATA             equ $-gdt
gdt_kernel_data:                        
        dw 0FFFFh               ; Limit 0xFFFF
        dw 0                    ; Base 0:15
        db 0                    ; Base 16:23
        db 092h                 ; Present, Ring 0, Data, Expand-up, Writable
        db 0CFh                 ; Page-granular
        db 0                    ; Base 24:32

gdt_interrupts:
        dw 0FFFFh
        dw 01000h
        db 0
        db 10011110b
        db 11001111b
        db 0

gdt_end:                        ; Usado para calcular el tamaño de la GDT

gdt_desc:                       ; El descriptor GDT
        dw gdt_end - gdt - 1    ; Limit (size)
        dd gdt                  ; Dirección de la GDT

times 510-($-$$) db 0           ; Rellenamos con ceros

dw 0AA55h                       ; La firma necesaria 0xAA55

