            ;; lst.s
            ;; 
            ;; single linked list. 
            ;;
            ;; single linked list must start with the next pointer (2 bytes)
            ;; and can be followed by any data structure.
            ;;
            ;;  struct lst_s {
            ;;      struct lst_s *next;
            ;;      uint8_t data[0]; /* you data structure here */
            ;;  }
            ;;
            ;; 2023-09-16   tstih
            .module lst

            .area   _CODE
            ;; ----------------------------------------------------------------
            ;; lst_insert(<hl> **first, <de> *record)
            ;; ----------------------------------------------------------------
            ;; inserts record pointed by de to the start of the linked list
            ;; and updates the memory location pointed by first to point to the
            ;; record.
            ;; 
            ;; input(s):    
            ;;  hl  ... pointer to memory location of the first record
            ;;  bc  ... pointer to record to add
            ;; destroys: 
            ;;  bc  ... old first record pointer
            ;;  flags
            ;; ----------------------------------------------------------------
lst_insert::
            ;; move address of the first record to bc
            ld      c,(hl)
            inc     hl
            ld      b,(hl)
            dec     hl
            ;; and to the record's next pointer
            ex      de,hl               ; hl = record
            ld      (hl),c
            inc     hl
            ld      (hl),b
            dec     hl
            ex      de,hl               ; hl=first, de=record (again)
            ;; and change the first pointer
            ld      (hl),e
            inc     hl
            ld      (hl),d
            dec     hl
            ret

lst_append::
            ret

lst_remove::
            ret

lst_find::
            ret