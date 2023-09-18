            ;; head.s
            ;; 
            ;; page 0 for tha partos
            ;;
            ;; 2023-09-13   tstih
            .module head

            .globl  scn2674_probe
            .globl  sio_probe
            .globl  tty_probe
            .globl  i8782_probe
            .globl  xebec1410_probe
            .globl  pio_probe

            .globl  ir_init

            .equ    MAX_DEVS, 16
            .equ    DEV_SIZE, 20
            .equ    OSS_SIZE, 128

            .area   _CODE
rst00::
            di                              ; disable interrupts
            jp      _start
version::
            .db     'O', 'S', '1', '0'      ; use 4 free bytes for version

            ;; rst8 is system call
rst08::
            reti            
_start:
            ld      sp,#stack               ; initialize stack.
            call    ir_init                 ; initilize interrupt routines

            ;; probe all devices
            ld      hl,#devices
            call    scn2674_probe
            call    sio_probe
            call    tty_probe               ; tests scn and sio?
            call    i8782_probe
            call    xebec1410_probe
            call    pio_probe

            ;; initialize bios

            ;; load boot sector

            ;; and jump to it!



_msg_welcome:
            .asciz  "PartOS 1.0\n"

            ;; ram top free space
            .area   _OSRAM
            .area   _OSSTACK
            .ds     OSS_SIZE
stack::
            .area   _OS_SYSINFO
devices::   .ds     DEV_SIZE * MAX_DEVS
            .area   _OSHEAP
heap::