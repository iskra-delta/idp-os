            ;; head.s
            ;; 
            ;; page 0 for tha partos
            ;;
            ;; 2023-09-13   tstih
            .module head

            ;;.globl  _KERNEL_ADDR

            .area   _CODE
reset::
            di                              ; disable interrupts     
            
            .area   _LOADER
loader::    
            ;; first copy micro- kernel to target location
            ld      hl,#kernel
            ;;ld      de,#_KERNEL_ADDR
            ld      bc,#2048        
            ldir                        



            .area   _KERNEL
kernel::