            ;; head.s
            ;; 
            ;; page 0 for tha partos
            ;;
            ;; MIT License (see: LICENSE)
            ;; copyright (c) 2023 tomaz stih
            ;;
            ;; 2023-09-13   tstih
            .module head

            .globl  cout_init

            .area   _CODE
page0::
            di                              ; disable interrupts (just in case)
            ld      sp,#0xffff              ; initialize stack.
            call    cout_init               ; initialize output (tty)