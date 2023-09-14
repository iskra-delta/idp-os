            ;; head.s
            ;; 
            ;; page 0 for tha partos
            ;;
            ;; 2023-09-13   tstih
            .module head

            .globl   scn2674_probe
            .globl   sio_probe
            .globl   tty_probe
            .globl   i8782_probe
            .globl   xebec1410_probe
            .globl   pio_probe

            .equ    MAX_DEVS, 16
            .equ    DEV_SIZE, 20
            .equ    OSS_SIZE, 128

            .area   _CODE
page0::
            di                              ; disable interrupts (just in case)
            ld      sp,#os_stack            ; initialize stack.
            
            ;; probe all devices
            ld      hl,#devices
            call    scn2674_probe
            call    sio_probe
            call    tty_probe               ; tests scn and sio to find out which one to use
            call    i8782_probe
            call    xebec1410_probe
            call    pio_probe

            ;; initialize bios

            ;; load boot sector

            ;; and jump to it!

            ;; ram top free space
            .area   _MEMTOP
            .ds     OSS_SIZE
os_stack::
devices::   .ds     DEV_SIZE * MAX_DEVS