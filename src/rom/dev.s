            ;; dev.s
            ;; 
            ;; device definitions
            ;; 
            ;; partos supports 16 devices (=320 bytes)
            ;; 
            ;;  struct device_s {
            ;;      uint8_t name[8]; /* if first byte is 0 ... not used */
            ;;      uint8_t flags[2];
            ;;      uint8_t data[8];
            ;;      struct device_driver_s *driver;
            ;;  };
            ;; 
            ;;  devices are detected at start up by
            ;;  calling probing functions on the drivers.
            ;;  
            ;;  device driver is a set of function pointers
            ;; 
            ;;  struct device_driver_s {
            ;;      open
            ;;      close
            ;;      read
            ;;      write
            ;;  };
            ;;  
            ;;  all functions are async. each driver also has a probe 
            ;;  function. this function should be called only once
            ;;  and when called the hl should point to free space where
            ;;  the device_s structures will be created. for example, the 
            ;;  probe for Xebec disk controller could return up to four
            ;;  connected hard drie entries. after the function hl should 
            ;;  point to next free slot for the device_s structure.
            ;;
            ;;  the probe function is only called at OS startup!
            ;;
            ;; MIT License (see: LICENSE)
            ;; copyright (c) 2023 tomaz stih
            ;;
            ;; 2023-09-14   tstih
            .module dev

            .area   _CODE