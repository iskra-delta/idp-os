            ;; head.s
            ;; 
            ;; page 0 for tha partos
            ;;
            ;; 2023-09-13   tstih
            .module head

            .globl  ir_init

            .area   _CODE
reset::
            di                              ; disable interrupts     
            ld      sp,#stack               ; initialize stack.

            ;; finally, initialize and enable interrupts
            call    ir_init                 ; initilize interrupts

            .area   _INTVEC
stack::