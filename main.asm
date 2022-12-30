

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

abs:	; abs(ax)=ret |ax|
cmp ax, 0
jl negative
jmp positive
negative:
neg ax
positive:
; value is already positive, so do nothing
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
;scan_point(di)
;di=point(di[0],di[1])

call printn

;push ascii "enter x:  "

push 2424h
mov ah,20h
add al,30h
push ax
;push 2020h
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
;ret=calcSqrt(ax)
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
call abs
mov si,dx
mul ax     ;d1^2
mov dx,si
mov di,ax ;di=ax=d1^2
sub bx,dx  ;d2=(y2-y1)
mov ax,bx
call abs
mul ax     ;d2^2
add ax,di   ;ax=d1^2 + d2^2
call calcSqrt ;ax=sqrt(ax);
ret 

detect_shape:
cmp ax,6
je square
cmp ax,2
je rectangle

jmp unknown

rectangle:
call printn
call printn
call printn
;"[+] rectangle Founded"
push 2424h
push 2464h
push 6564h
push 6e75h
push 6f46h
push 2065h
push 6c67h
push 6e61h
push 7463h
push 6552h
push 205dh
push 2b5bh
mov dx,sp
call print
add sp,24
jmp finish_detecting 

square:
call printn
call printn
call printn
;"[+] Square Founded"
push 2424h
push 6465h
push 646eh
push 756fh
push 4620h
push 6572h
push 6175h
push 7153h
push 205dh
push 2b5bh
mov dx,sp
call print
add sp,20
jmp finish_detecting 

unknown:
call printn
call printn
call printn
;"[+] Unknown Founded"
push 2464h
push 6564h
push 6e75h
push 6f46h
push 206eh
push 776fh
push 6e6bh
push 6e55h
push 205dh
push 2b5bh
mov dx,sp
call print
add sp,20
jmp finish_detecting 

finish_detecting:
ret


compare_4lengths:
;ax=length1 ,bx=length2 ,cx=length3 ,dx=length4   , ret=ax ( square : ax=6 , ax=2 rectangle )
len1_len2:
xor di,di
cmp ax,bx
jne len2_len3
inc di
len2_len3:
cmp bx,cx
jne len3_len4
inc di
len3_len4:
cmp cx,dx
jne len4_len1
inc di
len4_len1:
cmp dx,ax
jne len1_len3
inc di
len1_len3:
cmp ax,cx
jne len2_len4
inc di
len2_len4:
cmp bx,dx
jne finish_compareing_lengths
inc di
finish_compareing_lengths:
mov ax,di
ret

startup_message:
call printn
call printn
;"[+] Shape Detector Program , it take a 4 points(x,y)  to determine if it a square or triangle or rectangle or unknown shape then diagram it"
push 2474h
push 6920h
push 6d61h
push 7267h
push 6169h
push 6420h
push 6e65h
push 6874h
push 2065h
push 7061h
push 6873h
push 206eh
push 776fh
push 6e6bh
push 6e75h
push 2072h
push 6f20h
push 656ch
push 676eh
push 6174h
push 6365h
push 7220h
push 726fh
push 2065h
push 6c67h
push 6e61h
push 6972h
push 7420h
push 726fh
push 2065h
push 7261h
push 7571h
push 7320h
push 6120h
push 7469h
push 2066h
push 6920h
push 656eh
push 696dh
push 7265h
push 7465h
push 6420h
push 6f74h
push 2020h
push 2979h
push 2c78h
push 2873h
push 746eh
push 696fh
push 7020h
push 3420h
push 6120h
push 656bh
push 6174h
push 2074h
push 6920h
push 2c20h
push 6d61h
push 7267h
push 6f72h
push 5020h
push 726fh
push 7463h
push 6574h
push 6544h
push 2065h
push 7061h
push 6853h
push 205dh
push 2b5bh
mov dx,sp
call print
add sp,8ch
call printn
call printn
call printn
ret




main:
call startup_message

;[bp-4] point1 : [bp-4][0]=x1,[bp-4][1]=y1 
;[bp-8] point2 : [bp-8][0]=x2,[bp-8][1]=y2
;[bp-12] point3 : [bp-12][0]=x3,[bp-12][1]=y3
;[bp-16] point4 : [bp-16][0]=x4,[bp-16][1]=y4 
;[bp-20] length1
;[bp-24] length2
;[bp-28] length3
;[bp-32] length4

;scan point 1
mov al,01h;
lea di,[bp-4]
call scan_point

;scan point 2

lea di,[bp-8]
call scan_point

;scan point 3
lea di,[bp-12]
call scan_point

;scan point 4
lea di,[bp-16]
call scan_point


;calc and store distance for point1,point2

lea di,[bp-4]
lea si,[bp-8]
call distance_calc
mov [bp-20],ax    ;store result in length1

;calc and store distance for point2,point3

lea di,[bp-8]
lea si,[bp-12]
call distance_calc
mov [bp-24],ax    ;store result in length2

;calc and store distance for point3,point4

lea di,[bp-12]
lea si,[bp-16]
call distance_calc
mov [bp-28],ax    ;store result in length3


;calc and store distance for point4,point1

lea di,[bp-16]
lea si,[bp-4]
call distance_calc
mov [bp-32],ax    ;store result in length4



; compare lengths to detect_shape
mov ax,[bp-20]
mov bx,[bp-24]
mov cx,[bp-28]
mov dx,[bp-32]
call compare_4lengths

;shape detect useing compare result
call detect_shape

call exit

ret
