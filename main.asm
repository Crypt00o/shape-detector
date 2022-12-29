.CODE

start:

push bp
mov bp,sp
sub sp,80h

jmp main

zero_all_regs:
xor ax,ax  
xor bx,bx
xor dx,dx
xor cx,cx 
xor di,si
ret


print:
mov ah,9h
int 21h 
ret


exit:
xor ax,ax
mov ah,4ch
int 21h        
ret
 
 
main:
call exit
