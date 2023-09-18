            ;; scn2674.s
            ;; 
            ;; scn2674  
            ;;
            ;; 2023-09-16   tstih
            .module scn2674

            ;; --- 0x34 - R/W:character register ------------------------------
            .equ SCN2674_CHR,               0x34


            ;; --- 0x35 - R/W:attribute register ------------------------------
            .equ SCN2674_AT,                0x35
            .equ SCN2674_AT_NONE,           0x00    ; no attributes
            .equ SCN2674_AT_BLINK,          0x01    ; blink
            .equ SCN2674_AT_UNDERLINE,      0x02    ; underline
            .equ SCN2674_AT_SPC_CHR,        0x04    ; special character
            .equ SCN2674_AT_PROTECT,        0x08    ; protect
            .equ SCN2674_AT_HIGHLIGHT,      0x10    ; R:highlight, W:red foreground
            .equ SCN2674_AT_REVERSE,        0x20    ; R:reverse, W:green background
            .equ SCN2674_AT_GP2,            0x40    ; R:GP 2, W:blue background
            .equ SCN2674_AT_GP1,            0x80    ; R:GP 1, W:red background


            ;; --- 0x36 - W:gr.scroll (byte value=scan lines), R:common input -
            .equ SCN2674_GR_SCROLL,         0x36

            .equ SCN2674_GR_CMNI,           0x36    ; same register, different name
            .equ SCN2674_GR_CMNI_SCN2674A,  0x10    ; SCN2674 access flag
            .equ SCN2674_GR_CMNI_PIX,       0x80    ; graph. pix input


            ;; --- 0x38 - W:init (all 15 init reg. sequentially accessed) -----
            ;; R:interrupt (bits 7-6 default 0)
            .equ SCN2674_INIT,              0x38
            .equ SCN2674_IR,                0x38    ; same register, different name
            .equ SCN2674_IR_SS2,            0x01    ; split screen 2 interrupt
            .equ SCN2674_IR_RDY,            0x02    ; ready interrupt
            .equ SCN2674_IR_SS1,            0x04    ; split screen 1 interrupt
            .equ SCN2674_IR_LZ,             0x08    ; line zero interrupt
            .equ SCN2674_IR_VB,             0x10    ; vblank int


            ;; --- 0x39 - W:command (byte is command) -------------------------
            ;; R:status (bits 7-5 default 0)
            .equ SCN2674_CMD,               0x39    
            .equ SCN2674_CMD_RESET,         0x00    ; master reset
            .equ SCN2674_CMD_SET_IR,        0x10    ; set IR pointer to lower nibble
            .equ SCN2674_CMD_CURS_OFF,      0x30    ; switch off cursor
            .equ SCN2674_CMD_CURS_ON,       0x31    ; switch on cursor
            .equ SCN2674_CMD_WC2P,          0xbb    ; write from cursor to pointer
            .equ SCN2674_CMD_WAC,           0xab    ; write at cursor
            .equ SCN2674_CMD_WAC_NO_MOVE,   0xaa    ; write at cur, don't move cur
            .equ SCN2674_CMD_RAC,           0xac    ; read at cursor
            .equ SCN2674_CMD_RDPTR,         0xA4    ; read at pointer


            .equ SCN2674_STS,               0x39    ; same register, different name    
            .equ SCN2674_STS_SS2,           0x01    ; split screen 2 interrupt
            .equ SCN2674_STS_RDYI,          0x02    ; ready interrupt
            .equ SCN2674_STS_SS1,           0x04    ; split screen 1 interrupt
            .equ SCN2674_STS_LZ,            0x08    ; line zero interrupt
            .equ SCN2674_STS_VB,            0x10    ; vblank int
            .equ SCN2674_STS_RDY,           0x20    ; ready flag


            ;; --- 0x3a - R/W: screen start 1 lower register ------------------
            .equ SCN2674_SS1_LO,            0x3a
            ;; --- 0x3b - R/W: screen start 1 upper register ------------------
            .equ SCN2674_SS1_HI,            0x3b


            ;; --- 0x3c - R/W: cursor address lower register ------------------
            .equ SCN2674_CUR_LO,            0x3c
            ;; --- 0x3d - R/W: cursor address upper register ------------------
            .equ SCN2674_CUR_HI,            0x3d


            ;; --- 0x3e - R/W: screen start 2 lower register ------------------
            .equ SCN2674_SS2_LO,            0x3e
            ;; --- 0x3f - R/W: screen start 2 upper register ------------------
            .equ SCN2674_SS2_HI,            0x3f


            ;; ----------------------------------------------------------------
            ;; global routines
            ;; ----------------------------------------------------------------
            .globl  delay_1ms


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


            ;; create the device entry and fd
            xor     a
            ld      (#_scn2674_fd),a    ; not opened

            ;; display on
            
            
            ret


            ;; ----------------------------------------------------------------
            ;; <hl> fd <- scn2674_open();
            ;; ----------------------------------------------------------------
            ;; this routine opens the device. if the device requires exclusive
            ;; access it locks it for other usages.
            ;; 
            ;; output(s):   
            ;;  hl  ... points to the device context, which is always the same
            ;;  f   ... z if success, nz otherwise
            ;; destroys:
            ;;  a. bc
            ;; ----------------------------------------------------------------
_scn2674_open:
            ld      a,#1
            ld      (#_scn2674_fd),a    ; opened!
            or      a                   ; reset zero flag (all is well)
            ret


_scn2674_close:
            ret

    
_scn2674_read:
            ret


_scn2674_write:
            ret


_scn2674_ioctl:
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
_scn2674_fd::
            .ds     1