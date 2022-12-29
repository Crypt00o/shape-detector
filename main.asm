

.CODE

start:

push bp
mov bp,sp
sub sp,40h

jmp main

zero_general_regs:
xor ax,ax  
xor bx,bx
xor dx,dx
xor cx,cx 
ret


print:
mov ah,09h
int 21h 
ret


exit:
xor ax,ax
mov ah,4ch
int 21h        
ret

not_valid_number:
; pushing ascii value "[-] not valid number " into stack
push 2424h
push 7265h
push 626dh
push 754eh
push 2064h
push 696ch
push 6156h
push 2074h
push 6f4eh
push 205dh
push 2d5bh
mov dx,sp
call print
call exit 
ret 

printn:
push 2424h
push 0d0ah
mov dx,sp
call print
add sp,04h
ret

ascii_to_decimal:
cmp al,30h
jl not_valid_number
cmp al,39h
jg not_valid_number
sub al,30h
ret

scan_char:
mov ah,01h
int 21h
ret

scan_point:

call printn

;push ascii "enter x:  "

push 2424h
push 2020h
push 3a78h
push 2072h
push 6574h
push 6e65h
mov dx,sp
call print ;print "enter x:  "

call scan_char
call ascii_to_decimal 
mov  ptr word[di][0],ax ; store x 


call printn

;push ascii "enter y :  "

push 2424h
push 2020h
push 3a79h
push 2072h
push 6574h
push 6e65h
mov dx,sp
call print ; print "enter y:  "  

call scan_char
call ascii_to_decimal
mov ptr word[di][1],ax  ; store y

xor ax,ax
add sp,24
ret


           

calcSqrt:
    xor cx,cx
    mov cl,64h 
    mov di,cx ;precisionFactor 
    xor dx,dx
    push dx
    push dx
    push ax ; Stack = source
    
    ; aprox = (source / 200) + 2
    xor dx, dx
    mov bx,di
    add bx,bx  ; bx=200
    div bx
    add al, 02h
    mov bx, ax
    
    push ax ; Stack = aprx 
    
    
    ; BX -> aprx 
    ; CX -> source
    calcLoop:
    
        pop bx ; Stack = aprox(current)
        pop cx ; Stack = source
        
        ; If aprx == aprx(cache) it means that the squareroot of source 
        ;   is a floating point number, which is not supported by the 8068
        ;   and thus, can't be calculated precisely.
        pop ax 
        cmp bx, ax
        je fnshAvrgSqrt
        
        ; checking if aprx² == source     
        mov ax, bx ; AX = aprx
        xor dx, dx
        mul bx
        cmp ax, cx
        je fnshSqrt
        
        pop dx ; Clearing aprx(decimal) as result was not achieved
        push bx ; Store cache of aprx to be compared in the next loop iteration
        
        ; aprx(BX) = ((source(CX) / aprx) + aprx) / 2
        mov ax, cx ; AX = source
        xor dx, dx
        div bx
        add ax, bx
        inc dx
        shr ax,01h 
        mov bx, ax
        
        push cx ; Stack = source
        push bx ; Stack = aprx(current)
        
        ; Stack = aprx * 100
        mov dx, di
        mul dx
        push ax
        
        ; aprox = ((source * 100 / aprx) + aprx * 100) / 2
        mov ax, di
        mul cx ; source * 100
        
        div bx ; (source * 100 / aprx)
        mov cx, ax
        
        mov ax, di
        mul bx
        
        add ax, cx ; (source * 100 / aprx) + aprx * 100)
        xor si,si
        adc dx, si  ; (source * 100 / aprx) + aprx * 100) + Carry
         
        xor cx,cx
        mov cl, 02h 
        div cx ; AX = ((source * 100 / aprx) + aprx * 100) / 2
        
        pop bx ; BX = aprx * 100 lower
        
        sub ax, bx ; AX = (((source * 100 / aprx) + aprx * 100) / 2) - aprx * 100
        
        pop bx ; BX = aprx
        pop cx ; CX = source
        pop dx ; DX = aprx(cache)
        
        push ax ; Stack = aprx(decimal)
        push dx
        push cx
        push bx
    
    JMP calcLoop
    
    ; The result is an integer number
    fnshSqrt:
    mov ax, bx ; AX = aprox(Sqrt)
    pop bx
    xor bx, bx ; BX = Sqrt(decimal)
    ret
    
    ; The result is a floating point number
    fnshAvrgSqrt:
    mov ax, bx ; AX = aprox(Sqrt)
    pop bx ; BX = Sqrt(decimal)
    ret           

distance_calc:
;di=point(di[0],di[1]) si=anotherpoint(si[0],si[1)
call zero_general_regs
mov al,[di][0]
mov bl,[di][1]
mov cl,[si][0]
mov dl,[si][1]
sub ax,cx  ;d1=(x2-x1)
mul ax     ;d1^2
mov di,ax ;di=ax=d1^2
sub bx,dx  ;d2=(y2-y1)
mov ax,bx
mul bx     ;d2^2
add ax,di   ;ax=d1^2 + d2^2
call calcSqrt ;ax=sqrt(ax);
ret 

main:
;[bp-4] point1 : [bp-4][0]=x1,[bp-4][1]=y1 
;[bp-8] point2 : [bp-8][0]=x2,[bp-8][1]=y2
;[bp-12] point3 : [bp-12][0]=x3,[bp-12][1]=y3
;[bp-16] point4 : [bp-16][0]=x4,[bp-16][1]=y4 
;[bp-20] length1
;[bp-24] length2
;[bp-28] length3
;[bp-32] length4







call exit

ret
