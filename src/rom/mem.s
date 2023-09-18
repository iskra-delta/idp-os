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
            ;;  de  ... length
            ;;  a   ... value
            ;; destroys:
            ;;  hl  ... points to the last byte of the block
            ;;  de  ... hl + 1
            ;;  bc  ... 0
            ;;  flags
            ;; ----------------------------------------------------------------
mem_set::
            ;; length to bc
            ld      b,d
            ld      c,e
            ;; hl+1 to de
            ld      d,h               
            ld      e,l
            inc     de
            ;; initial value
            ld      (hl),a
            ldir
            ret

mem_alloc::
            ret

mem_free::
            ret