;-----------------------------------------------------------------------------
; CPU_Type determines the CPU type in the system.
;-----------------------------------------------------------------------------
; Written by:
;   Robert Collins
;   3361 Keys Lane
;   Anaheim, CA  92804
;-----------------------------------------------------------------------------
; Altered for defining Clipper function by :
;   M.de Rooy
;-----------------------------------------------------------------------------
; c1 = CPU_Type()
;-----------------------------------------------------------------------------

include extenda.mac

.radix 16                       ; anybody that programs in base 10 is a wimp!
.386P                           ; MASM 5.1 directive

;-----------------------------------------------------------------------------
; PUBLIC statements here
;-----------------------------------------------------------------------------
        Public  CPU_Type

;-----------------------------------------------------------------------------
; Local variable definitions
;-----------------------------------------------------------------------------
        INT6    equ     [bp-4]

;-----------------------------------------------------------------------------
; Interrupt vector segment
;-----------------------------------------------------------------------------
ABS0    segment use16 at 0

        org 6*4
Orig_INT6       dd      ?

ABS0    ends


;-----------------------------------------------------------------------------
; 80486 instruction macro -- because MASM 5.1 doesn't support the 80486!
;-----------------------------------------------------------------------------
XADD    macro
        db      0fh,0C0h,0D2h           ; 80486 instruction macro
ENDM


cseg    segment para    use16 public 'code'
        assume  cs:cseg

CPU_Type        proc    far
                sav_regs
                call    cpu
                ret_int ax
                rest_regs
                ret

CPU_Type        endp

CPU             proc    near
;-----------------------------------------------------------------------------
; Determine the CPU type by testing for differences in the CPU in the system.
;-----------------------------------------------------------------------------
; To test for the 8086/8088, test the value of SP after it is placed on the
; stack.  The 8086/8088 increments this value before pushing it on the stack,
; all other CPU's increment SP after pushing it on the stack.
;-----------------------------------------------------------------------------
        xor     ax,ax                   ; clear CPU type return register
        push    sp                      ; save SP on stack to look at
        pop     bx                      ; get SP saved on stack
        cmp     bx,sp                   ; if 8086/8088, these values will differ
        jnz     CPU_8086_exit           ; yep
;-----------------------------------------------------------------------------
; When we get here, we know that we aren't a 8086/8088.  And since all
; subsequent processors will trap invalid opcodes via INT6, we will determine
; which CPU we are by trapping an invalid opcode.
;   We are an 80486 if:  XADD   DX,DX   executes correctly
;             80386 if:  MOV    EDX,CR0 executes correctly
;             80286 if:  SMSW   DX      executes correctly
;             80186 if:  SHL    DX,5    executes correctly
;-----------------------------------------------------------------------------
; Setup INT6 handler
;-----------------------------------------------------------------------------
        enter   4,0                     ; create stack frame
        mov     word ptr INT6,offset INT6_handler
        mov     INT6+2,cs
        call    set_INT6_vector         ; set pointer to our INT6 handler
        mov     ax,4                    ; initialize CPU flag=4 (80486)
        xor     cx,cx                   ; initialize semaphore

;-----------------------------------------------------------------------------
; Now, try and determine which CPU we are by executing invalid opcodes.
; The instructions I chose to invoke invalid opcodes, are themselves rather
; benign.  In each case, the chosen instruction modifies the DX register,
; and nothing else.  No system parameters are changed, e.g. protected mode,
; or other CPU dependant features.
;-----------------------------------------------------------------------------
; The 80486 instruction 'XADD' xchanges the registers, then adds them.
; The exact syntax for a '486 compiler would be:  XADD  DX,DX.
;-----------------------------------------------------------------------------
        XADD   ;DX,DX                   ; 80486
        jcxz    CPU_exit
        dec     ax                      ; set 80386 semaphore
        inc     cx                      ; CX=0

;-----------------------------------------------------------------------------
; For a description on the effects of the following instructions, look in
; the Intel Programmers Reference Manual's for the 80186, 80286, or 80386.
;-----------------------------------------------------------------------------
        mov     edx,cr0                 ; 80386
        jcxz    CPU_exit
        dec     ax                      ; set 80286 semaphore
        inc     cx                      ; CX=0

        smsw    dx                      ; 80286
        jcxz    CPU_exit
        dec     ax                      ; set 80186 semaphore
        inc     cx                      ; CX=0

        shl     dx,5                    ; 80186/80188
        jcxz    CPU_exit
        dec     ax                      ; set UNKNOWN_CPU semaphore

CPU_exit:
        call    set_INT6_vector
        leave

CPU_8086_exit:
        ret


;-----------------------------------------------------------------------------
; Set the INT6 vector by exchanging it with the one currently on the stack.
;-----------------------------------------------------------------------------
set_INT6_vector:
        push    ds
        push    ABS0                    ; save interrupt vector segment
        pop     ds                      ; make DS=INT vector segment
        mov     dx,word ptr ds:Orig_INT6;       ; get offset if INT6 handler
        xchg    INT6,dx                 ; set new INT6 offset
        mov     word ptr ds:Orig_INT6,dx
        mov     dx,word ptr ds:Orig_INT6+2      ; get segment of INT6 handler
        xchg    INT6+2,dx               ; set new INT6 segment
        mov     word ptr ds:Orig_INT6+2,dx
        pop     ds                      ; restore segment register
        ret                             ; split


;-----------------------------------------------------------------------------
; INT6 handler sets a semaphore (CX=FFFF) and adjusts the return address to
; point past the invalid opcode.
;-----------------------------------------------------------------------------
INT6_handler:
        enter   0,0                     ; create new stack frame
        dec     cx                      ; make CX=FFFF
        add     word ptr ss:[bp][2],3   ; point past invalid opcode
        leave
        iret

CPU             endp

cseg    ends
        end

