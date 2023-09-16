            ;; ir.s
            ;; 
            ;; interrupt routines
            ;;
            ;; 2023-09-16   tstih
            .module ir



            ;; ----------------------------------------------------------------
            ;; ir_init();
            ;; ----------------------------------------------------------------
            ;; initialize interrupt routines
            ;; destroys:
            ;;  a  ... 0
            ;; ----------------------------------------------------------------
ir_init::
            xor     a
            ld      (ir_refcnt),a
            ret

            ;; ----------------------------------------------------------------
            ;; ir_disable();
            ;; ----------------------------------------------------------------
            ;; execute di instruction with reference counting
            ;; ----------------------------------------------------------------
ir_disable::
            di
            push    hl
            ld		hl,#ir_refcnt
            inc		(hl)
            pop     hl
            ret


            ;; ----------------------------------------------------------------
            ;; ir_enable();
            ;; ----------------------------------------------------------------
            ;; execute ei instruction with reference counting
            ;; ----------------------------------------------------------------
ir_enable::
            di                              ; make sure no one bothers our logic
            push    af                      ; store af
            ld		a,(#ir_refcnt)          ; get reference counter
            or		a                       ; set flags
            jr		z,ir_enable_ei          ; if a==0 then just ei		
            dec		a                       ; if a<>0 then dec a
            ld		(#ir_refcnt),a          ; write back to counter
            or		a                       ; and check for ei
            jr		nz,ir_enable_done       ; not yet...
ir_enable_ei:		
            ei
ir_enable_done:
            pop     af
            ret


            .area   _OS_SYSINFO
ir_refcnt::
            .ds     1