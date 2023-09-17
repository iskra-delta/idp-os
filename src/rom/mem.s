            ;; mem.s
            ;; 
            ;; memory managemen functions
            ;;
            ;; 2023-09-14   tstih
            .module pio

            .area   _CODE
            ;; ----------------------------------------------------------------
            ;; mem_set(<hl> *address,<bc> len ,<a> value);
            ;; ----------------------------------------------------------------
            ;; fills the memory, pointed by hl with the value of a. 
            ;; length is in bc.
            ;; 
            ;; input(s):    
            ;;  hl  ... start address
            ;;  bc  ... length
            ;;  a   ... value
            ;; destroys:
            ;;  hl  ... points to the last byte of the block
            ;;  de  ... hl + 1
            ;;  bc  ... 0
            ;;  flags
            ;; ----------------------------------------------------------------
mem_set::
            ld      d,h                 ; target for LDIR
            ld      e,l
            inc     de
            ld      (hl),a
            ldir
            ret

mem_alloc::
            ret

mem_free::
            ret