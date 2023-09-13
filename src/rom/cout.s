            ;; cout.s
            ;; 
            ;; console out functions
            ;; 
            ;; MIT License (see: LICENSE)
            ;; copyright (c) 2023 tomaz stih
            ;;
            ;; 2023-09-13   tstih
            .module cout

            .globl  cout_init
            .globl  delay_1ms

            .include "scn2674.inc"

            .area   _CODE
cout_init::
            ;; tech. doc. - master reset 
            ;; must be called twice upon power up.
            ;; no delay is required (should we have one?)
            ld      a,#SCN2674_CMD_RESET
            out     (#SCN2674_CMD),a
            out     (#SCN2674_CMD),a
            ;; set SS1 and SS2
            out     (SCN2674_SS1_LO),a
            out     (SCN2674_SS1_HI),a
            out     (SCN2674_SS2_LO),a
            out     (SCN2674_SS2_HI),a
            ;; sent init sequence
            ld      hl,#scn2674_init_seq
            ld      c,#SCN2674_INIT
            ld      b,#escn2674_init_seq-#scn2674_init_seq
            otir
            ret

scn2674_init_seq:
            .db     0x10, 0x20, 0x30
escn2674_init_seq: