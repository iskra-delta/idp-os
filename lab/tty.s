            ;; tty.s
            ;; 
            ;; console and keyboard functions
            ;;
            ;; 2023-09-13   tstih
            .module tty

            .area   _CODE

            .globl  dev_find
tty_probe::
            ;; first test if there is gdp available?
            ld      hl,#_tty_gdp
            jr      z,tp_has_gdp$
            
tp_has_gdp$:
            ld      (tty_out),hl        ; store cout device

            ;; and return
            or      a                   ; raise z flag (device detected)
            ret


_tty_open:
            ret


_tty_close:
            ret


_tty_read:
            ret


_tty_write:
            ret


            ;; ----------------------------------------------------------------
            ;; <hl> result <- _tty_ioctl(<hl> fd, <a> cmd, <de> params)
            ;; ----------------------------------------------------------------
            ;; ioctl call on the device
            ;; ----------------------------------------------------------------
_tty_ioctl:
            ret


            ;; ----------------------------------------------------------------
            ;; device driver
            ;; ----------------------------------------------------------------
tty_dev_drv::
            .dw     _tty_open
            .dw     _tty_close
            .dw     _tty_read
            .dw     _tty_write
            .dw     _tty_ioctl


_tty_gdp:
            .asciz  "scn2674"
            
            .area   _OS_SYSINFO
tty_out::   .ds     2
tty_in::    .ds     2
tty_err::   .ds     2