.CODE

start:

push bp
mov bp,sp
sub sp,20h

jmp main

zero_all_regs:
xor ax,ax  
xor bx,bx
xor dx,dx
xor cx,cx 
xor di,si
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

call scan_char
call ascii_to_decimal 
mov  ptr [di][0],ax ; store x 

call scan_char
call ascii_to_decimal
mov ptr [di][1],ax  ; store y
xor ax,ax
ret

main:

call exit

ret
