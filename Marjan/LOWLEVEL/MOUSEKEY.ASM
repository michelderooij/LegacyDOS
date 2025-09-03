     public MOUSEON
     public MOUSEOFF
     extrn          __RETL:far    ; returns logical type
     extrn          __PARNI:far
     LB             equ 1C0Dh     ; set LEFT button to RETURN key
     CB             equ 3B00h     ; set CENTER button to F1 key
     RB             equ 011Bh     ; set RIGHT button to ESC key
     DELVER         equ 1
     DELHOR         equ 4
BIOS_DATA segment at 40h
     org                 1ah
     BUFFER_HEAD         dw   ?   ;pointer to the keybord
                                  ;buffer head
     BUFFER_TAIL         dw   ?   ;pointer to the keyboard
                                  ;buffer tail
     org                 80h
     BUFFER_START        dw   ? ;starting keyboard buffer address
     BUFFER_END          dw   ? ;ending keyboard buffer address
BIOS_DATA ends

CODE segment 'CODE'         ; declare code segment of class CODE
    assume cs:CODE,ds:BIOS_DATA

    VCOUNT         db   DELVER       ; vertical delay counter
    HCOUNT         db   DELHOR       ; horizontal delay counter
    HFLAG          dw   ?         ; horizontal count sign flag
    VFLAG          dw   ?         ; vertical count sign flag
    KEYCODE        db   4Dh,4Bh,50h,48h ;keycodes for cursor keys

MOUSE proc far

    test ax,2           ; left button pressed?
    jnz  LEFT           ; if yes, then go insert 'LB' into buffer
    test ax,8           ; right button pressed?
    jnz  RIGHT          ; if yes, then go insert 'RB' into buffer
    test ax,32          ; center button pressed? (PC MOUSE)
    jnz  CENTER         ; if yes, then go insert 'CB' into buffer

MOUSE0:
    mov  ax,11               ; use mouse driver's function 11
    int  51                  ; read mouse motion counters
    mov  HFLAG,0             ; initialize sign flags
    mov  VFLAG,2             ;
    xor  al,al               ; zero AL for extended keycode
    cmp  cx,0                ; horizontal count positive?
    jge  MOUSE1              ; yes, then branch
    inc  HFLAG               ; record negative condition
    neg  cx                  ; convert negative to positive

MOUSE1:
    cmp  dx,0                ; vertical count positive
    jge  MOUSE2              ; yes, then branch
    inc  VFLAG               ; record negative condition
    neg  dx                  ; convert negative to positive

MOUSE2:
    mov  bx,HFLAG            ; assume motion was horizontal
    cmp  cx,dx               ; was assumption correct?
    jae  HORIZ               ; yes, then branch
    mov  bx,VFLAG            ; no, then correct it
    dec  VCOUNT              ; decrement vertical delay count
    jz   MOUSE3              ; continue if count is zero
    jmp  GET_OUT

HORIZ:
    dec  HCOUNT
    jz   MOUSE3

GET_OUT:
    ret

MOUSE3:
    mov  HCOUNT,DELHOR
    mov  VCOUNT,DELVER          ; reset delay counter
    mov  ah,KEYCODE[bx]      ; get keycode from table
    call INSERT              ; insert it into keyboard buffer
    jmp  RETURN

LEFT:
    mov  ax,LB               ; load pre-defined 'LB' keycode 
                             ; into buffer
    call INSERT              ; insert it into buffer
    jmp  RETURN
RIGHT:
    mov  ax,RB               ; load pre-defined 'RB' keycode
                             ; into buffer
    call INSERT              ; insert it into buffer
    jmp  RETURN

CENTER:
    mov  ax,CB               ; load pre-defined 'CB' keycode
                             ; into buffer
    call INSERT              ; insert it into buffer

RETURN:
    ret

MOUSE endp

MOUSEON proc far
    push bp                  ; save everything as documented in
    mov  bp,sp               ; Aut '86 Nantucket News or you
    push ds                  ; will blow up!
    push es                  ;
    mov  ax,0                ; use function 0 of driver to see
    int  33h                 ; if mouse and driver are installed
    or   ax,ax               ; is there a mouse?
    jne  OK                  ; yes, continue
    mov  bx,0                ; return to Clipper a .F. to tell
    push bx                  ; it that MOUSEKEYON() failed to set
    call __retl              ; up the routine (extended interface)
    jmp  DONE                ; go back to Clipper

OK:
    mov  ax,15                ; use function 15 of mouse driver to
    mov  cx,4                ; set the mouses sensitivity
    mov  dx,8                ;
    int  33h                 ;
    mov  ax,seg MOUSE        ; tell function 12 where to find the
    mov  es,ax               ; the mouse routine
    mov  dx,offset MOUSE     ;
    mov  ax,12               ; use function 12
    mov  cx,0000000000101011b     ; set up the mask for buttons 
                                  ; and cursor
    int  33h               ; set it up!
    mov  bx,1              ; return a .T. to Clipper to tell it
    push bx                ; that the installation was successful
    call __retl            ; (using Clipper's extended interface)

DONE:
    pop  bx                  ; restore the stack or DIE!!!!
    pop  es                  ;
    pop  ds                  ;
    pop  bp                  ;
    ret                      ; exit and pray!!
MOUSEON endp

MOUSEOFF proc far
    push bp             ; save these registers as usual
    mov  bp,sp          ;
    push ds             ; or DIE!!!!!
    push es             ;
    mov  ax,0           ; use function 0 of the mouse driver
    int  33h            ; to reset the mouse settings which
    mov  bx,1           ; effectively turns off the mouse routine
    push bx             ; return a .T. which really has no
    call __retl         ; meaning but needs to be done to allow
    pop  bx             ; the routine to be used as a UDF without
    pop  es             ; hanging. Restore the stack or hang
    pop  ds             ; like a
    pop  bp             ; bleep, bleep !!!!
    ret                 ;
MOUSEOFF endp


;*********************************************************
;* INSERT - procedure to insert keys into keyboard buffer
;*********************************************************
INSERT proc    near
     mov       bx,BIOS_DATA     ; point DS to the BIOS data area
     mov       ds,bx            ;
     assume    ds:BIOS_DATA     ;
     cli                        ; disable interrupts
     mov       bx,BUFFER_TAIL   ; get buffer tail address
     mov       dx,bx            ; transfer it to DX
     add       dx,2             ; calculate next buffer position
     cmp       dx,BUFFER_END    ; did we overshoot the end?
     jne       INSERT1          ; no, then continue
     mov       dx,BUFFER_START  ; yes, then wrap to start 
                                ; of buffer
INSERT1:
     cmp       cx,BUFFER_HEAD   ; is the buffer full?
     je        INSERT2          ; yes, then end now
     mov       [bx],ax          ; insert the keycode
     mov       bx,dx            ; advance the tail
     mov       BUFFER_TAIL,bx   ; record its new position

INSERT2:
     sti                        ; enable interrupts
     assume    ds:nothing       ;
     ret                        ; exit user sub-routine
INSERT 	endp

CODE ends
     end
