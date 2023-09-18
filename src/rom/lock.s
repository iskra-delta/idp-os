            ;; lock.s
            ;; 
            ;; locking mechanism for Z80
            ;; idea picked from: Brian Ruthven's blog 
            ;; 
            ;; 2023-09-18   tstih
            .module lock

            .area   _CODE


            ;; ----------------------------------------------------------------
            ;; <z flag> result <= lock_acquire(<hl> *lock)
            ;; ----------------------------------------------------------------
            ;; tries to acquire a lock using atomic sra (hl) instruction. if
            ;; successfull it sets the z flag.
            ;; 
            ;; input(s):    
            ;;  hl  ... pointer to memory location holding the lock
            ;; output(s)
            ;;  flags   Z is set on success
            ;; destroys: 
            ;;  a   ... 0
            ;; ----------------------------------------------------------------
lock_acquire::
            xor     a
            sra     (hl)
            jr      nc,la_fail$
            or      a
            ret
la_fail$:   cp      #0xff               ; this will reset Z flag
            ret


            ;; ----------------------------------------------------------------
            ;; lock_release(<hl> *lock)
            ;; ----------------------------------------------------------------
            ;; releases the lock
            ;; 
            ;; input(s):    
            ;;  hl  ... pointer to memory location holding the lock
            ;; ----------------------------------------------------------------
lock_release::
            ld (hl),#0xfe
            ret