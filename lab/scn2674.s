            ;; scn2674.s
            ;; 
            ;; scn2674  
            ;;
            ;; 2023-09-16   tstih
            .module scn2674

            .include "scn2674.inc"
            .include "dev.inc"

            ;; ----------------------------------------------------------------
            ;; global routines
            ;; ----------------------------------------------------------------
            .globl  delay_1ms
            .globl  lock_acquire
            .globl  lock_release
            .globl  lock_test


            .area   _CODE
            ;; ----------------------------------------------------------------
            ;; <hl> *next_dev_s_addr <- scn2674_probe(<hl> *dev_s_addr);
            ;; ----------------------------------------------------------------
            ;; this routine initializes (and detects) the SCN2674 chip. 
            ;; if detected it creates a device entry for it (see: struct 
            ;; dev_s) in space pointed by the HL register and increases the
            ;; register to point to the first free byte after the structure.
            ;; 
            ;; input(s):    
            ;;  hl  ... pointer to space for device structure if detected.
            ;; output(s):   
            ;;  hl  ... points to next slot for dev_s, same as input if no
            ;;          device has been detected
            ;;  f   ... z if detected, nz if not detected
            ;; destroys:
            ;;  a. bc
            ;; ----------------------------------------------------------------
scn2674_probe::
            ;; master reset 
            ;; must be called twice upon power up.
            ;; no delay is required (should we have one?)
            ld      a,#SCN2674_CMD_RESET
            out     (#SCN2674_CMD),a
            call    delay_1ms
            out     (#SCN2674_CMD),a
            call    delay_1ms

            ;; now detect it by writing to register and reading from it
            ld      a,#0xbe             ; write dummy value
            out     (SCN2674_SS1_LO),a  ; to register
            call    delay_1ms           ; give it time
            in      a,(SCN2674_SS1_LO)  ; read it out
            cp      #0xbe               ; should return the same value
            ret     nz                  ; not detected
            
            ;; sent init sequence
            ld      hl,#_scn2674_init_seq
            ld      c,#SCN2674_INIT
            ld      b,#_escn2674_init_seq-#_scn2674_init_seq
            otir

            ;; initialize row table


            ;; prepare device for locking
            ld      hl,#_scn2674_lock
            call    lock_release

            ;; display on
            
            
            ret


            ;; ----------------------------------------------------------------
            ;; <hl> fd <- _scn2674_open();
            ;; ----------------------------------------------------------------
            ;; this routine opens the device. if the device requires exclusive
            ;; access it locks it for other usages.
            ;; 
            ;; output(s):   
            ;;  hl  ... points to the device lock (=fd)
            ;;  f   ... z if success, nz otherwise
            ;; destroys:
            ;;  a. bc
            ;; ----------------------------------------------------------------
_scn2674_open:
            ;; acquire lock over device
            ld      hl,#_scn2674_lock
            call    lock_acquire
            ret


            ;; ----------------------------------------------------------------
            ;; _scn2674_close();
            ;; ----------------------------------------------------------------
            ;; this routine closes the device by releasing the exclusive lock.
            ;; ----------------------------------------------------------------
_scn2674_close:
            call    lock_release
            ret

    
_scn2674_read:
            ret


_scn2674_write:
            ret


            ;; ----------------------------------------------------------------
            ;; _scn2674_ioctl();
            ;; ----------------------------------------------------------------
            ;; this routine allows tests of device capatibilites beyond rd/wr
            ;;
            ;; output(s):
            ;;  flags   Z ... success/yes, NZ ... fail/no
            ;; destroys:
            ;;  a, hl
            ;; ----------------------------------------------------------------
_scn2674_ioctl:
            ;; is device locked?
            cp      #DEV_LOCKED
            jr      nz,sctl_done$
            ld      hl,#_scn2674_lock
            call    lock_test
            ret                         ; Z locked, NZ not locked
sctl_done$:
            ;; set zero flag (we failed!)
            xor     a
            cp      #0xff
            ret

            


            ;; ----------------------------------------------------------------
            ;; _scn2674_wait_ready()
            ;; ----------------------------------------------------------------
            ;; wait until the SCN2674 is ready.
            ;;
            ;; destroys:
            ;;  a. flags
            ;; ----------------------------------------------------------------
_scn2674_wait_rdy:
            in      a,(#SCN2674_STS)
            and     #SCN2674_STS_RDY
            jr      z,_scn2674_wait_rdy
            ret


            ;; ----------------------------------------------------------------
            ;; <hl> *row <- _scn2674_get_row_ptr(<a> rowno)
            ;; ----------------------------------------------------------------
            ;; return row table entry for row in a
            ;;
            ;; input(s):
            ;;  a   ... row number (0 based)
            ;; output(s):
            ;;  hl  ... pointer to row (in AVDC memory)
            ;; destroys:
            ;;  a, de, flags
            ;; ----------------------------------------------------------------
_scn2674_get_row_ptr:
            ;; multiply row in a * 2
            ld      l,a
            ld      h,#0
            add     hl,hl
            push    hl
            ;; read it
            call    _scn2674_read_at_hl     ; read first byte
            ex      de,hl                   ; result to de
            pop     hl
            inc     hl                      ; addr+1
            call    _scn2674_read_at_hl     ; and read to de
            ld      l,e                     ; hl holds the result
            ret    


            ;; ----------------------------------------------------------------
            ;; <hl> char_and_attr <- _scn2674_read_at_hl(<hl> *addr)
            ;; ----------------------------------------------------------------
            ;; read char and attr. at address, pointed by hl
            ;;
            ;; input(s):
            ;;  hl  ... pointer to address in AVDC memory
            ;; output(s):
            ;;  hl  ... character (low) and attribute (high)
            ;; destroys:
            ;;  flags
            ;;  a   ... the attribute value
            ;; ----------------------------------------------------------------
_scn2674_read_at_hl:
            call    _scn2674_hl2pointer    
            ;; read char into a
            ld      a,#SCN2674_CMD_RDPTR    ; read at pointer
            out     (SCN2674_CMD), a        ; read into char reg.    
            call    _scn2674_wait_rdy       ; makes sure we're done
            in      a,(SCN2674_CHR)         ; get char
            ld      l,a                     ; char into l
            in      a,(SCN2674_AT)          ; get attr
            ld      h,a                     ; into h
            ret


            ;; ----------------------------------------------------------------
            ;; _scn2674_hl2cursor()
            ;; ----------------------------------------------------------------
            ;; write hl to cursor (write cursor)
            ;;
            ;; destroys:
            ;;  a. flags
            ;; ----------------------------------------------------------------
_scn2674_hl2cursor:
            call    _scn2674_wait_rdy
            ;; set cursor
            ld      a,l
            out     (#SCN2674_CUR_LO),a
            ld      a,h
            out     (#SCN2674_CUR_HI),a
            ret


            ;; ----------------------------------------------------------------
            ;; <hl> cursor_addr <- _scn2674_cursor2hl()
            ;; ----------------------------------------------------------------
            ;; write cursor to hl (read cursor)
            ;;
            ;; output(s):
            ;;  hl  ... cursor address (in video memory)
            ;; destroys:
            ;;  a, flags
            ;; ----------------------------------------------------------------
_scn2674_cursor2hl:
            call    _scn2674_wait_rdy
            ;; get cursor
            in      a,(#SCN2674_CUR_LO)
            ld      l,a
            in      a,(#SCN2674_CUR_HI)
            ld      h,a
            ret


            ;; ----------------------------------------------------------------
            ;; _scn2674_hl2pointer()
            ;; ----------------------------------------------------------------
            ;; write hl to cursor (write cursor)
            ;;
            ;; destroys:
            ;;  a. flags
            ;; ----------------------------------------------------------------
_scn2674_hl2pointer:
            call    _scn2674_wait_rdy
            ;; set pointer to correct row ptr address.
            ld      a,#0x1A                 ; set IR to A (10)
            out     (#SCN2674_CMD), a       ; command!
            ld      a,l
            out     (#SCN2674_INIT),a       ; pointer low
            ld      a,h
            out     (#SCN2674_INIT),a       ; pointer high
            ret


            ;; ----------------------------------------------------------------
            ;; _scn2674_cursor_on()
            ;; ----------------------------------------------------------------
            ;; show cursor on screen
            ;;
            ;; destroys:
            ;;  a. flags
            ;; ----------------------------------------------------------------
_scn2674_cursor_on:
            call    _scn2674_wait_rdy
            ld      a, #SCN2674_CMD_CURS_ON
            out     (SCN2674_CMD), a
            ret


            ;; ----------------------------------------------------------------
            ;; _scn2674_cursor_off()
            ;; ----------------------------------------------------------------
            ;; hide cursor
            ;;
            ;; destroys:
            ;;  a. flags
            ;; ----------------------------------------------------------------
_scn2674_cursor_off:
            call    _scn2674_wait_rdy
            ld      a, #SCN2674_CMD_CURS_OFF
            out     (SCN2674_CMD), a
            ret


            ;; ----------------------------------------------------------------
            ;; device driver
            ;; ----------------------------------------------------------------
scn2674_dev_drv::
            .dw     _scn2674_open
            .dw     _scn2674_close
            .dw     _scn2674_read
            .dw     _scn2674_write
            .dw     _scn2674_ioctl


            ;; ----------------------------------------------------------------
            ;; chip initialization string
            ;; ----------------------------------------------------------------
_scn2674_init_seq:
            ;; IR0: 1 1010 0 00 
            ;;  1       enable double height/width on  
            ;;  1010    11 scan lines per char row 
            ;;  0       sync = vsync
            ;;  00      buffer mode = independent
            .db     0b11010000

            ;; IR1: 0 0111110
            ;;  0       intercale off
            ;;  0111110 equalizing const. 63 cclk
            .db     0b00111110          
            
            ;; IR2: 1 0111 111
            ;;  1       row table on
            ;;  0111    horiz. sync width 16 cclk
            ;;  111     horiz. back porch 27 cclk
            .db     0b10111111
            
            ;; IR3: 000 00101
            ;;  000     vertical front porch 4 scan lines
            ;;  00101   vertical back porch 24 scan lines
            .db     0b00000101
            
            ;; IR4: 1 0011001
            ;;  1       char. blink rate 1/128 vsync
            ;;  0011001 26 active char. rows per screen
            .db     0b10011001
            
            ;; IR5: 10000011
            ;; 131(10)  132 active characters per row
            .db     0b10000011
            
            ;; IR6: 0000 1011
            ;;  0000    first scan line of cursor is 0
            ;;  1011    last scan line of cursor is 11 (height:12)
            .db     0b00001011
            
            ;; IR7: 11 1 0 1010
            ;;  11      vsync width = 7 scan lines
            ;;  1       cursor blink on
            ;;  0       cursor rate 1/32
            ;;  1010    underline position is 10
            .db     0b11101010
            
            ;; IR8: 00000000
            ;;  0(10)   display buffer's first address LSB
            .db     0b00000000
            
            ;; IR9: 0011 0000
            ;;  0011    display buffer last address (8191)
            ;;  0000    display buffer's first address MSB
            .db     0b00110000

            ;; IR10: 00000000
            ;;  0(10)   display pointer address lower
            .db     0b00000000

            ;; IR11: 00000000
            ;;  0(10)   display pointer address upper
            .db     0b00000000

            ;; IR12: 0 0000000
            ;;  0       scroll start off
            ;;  0000000 split register 1 = row 1
            .db     0b00000000

            ;; IR13: 0 0000000
            ;;  0       scroll end off
            ;;  0000000 split register 2 = row 1
            .db     0b00000000

            ;; IR14: 00 00 0000
            ;;  00      double 1 is normal
            ;;  00      double 2 is normal
            ;;  0000    smooth scroll is on for soft scroll
            .db     0b00000000
_escn2674_init_seq:


            .area   _OS_SYSINFO
            ;; device fd (when opened!)
_scn2674_lock::
            .ds     1