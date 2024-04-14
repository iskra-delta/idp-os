# The u-kernel

The PartOS microkernel provides memory management, process and thread management, interrupt management, and interprocess communication services.

## System calls

Services are available via system calls which are implemented using the system call table. 

~~~C
uint16_t *sys_fn[] {
    reset,          /* os reset */
    set_int_vec,    /* set interrupt vec. */                
    get_int_vec,    /* get interrupt vec. */
    alloc_mem,      /* allocate memory */
    free_mem,       /* free memory */
    term_proc,      /* terminate process */
    creat_proc,     /* create process */
    get_proc_sts,   /* get process return code */
    reg_svc         /* register a service */
};
~~~

To make the call you need to obtain a pointer to this table. Since each process can register its own system services, each service has a well known name. For the partos the name is **yos**.

~~~asm
            ;; system call
            ld      hl,#svc_name
            call    #QUERY_SVC          ; get service (0xf9bf)
            ;; hl now points to the system call table
            ;; ...
svc_name:   .asciiz "yos"
~~~

### DOS codes

Compatible codes for DOS interrupt 21.

| Fn   | Desc                                |
|:----:|-------------------------------------|
| 0x00 | Reset                               |
| 0x25 | Set Interrupt Vector                |
| 0x35 | Get Interrupt Vector                |
| 0x48 | Allocate Memory Block               |
| 0x49 | Free Memory Block                   |
| 0x4c | Terminate Process                   |
| 0x4b | Start Process                       |
| 0x4d | Get Process Termination Status Code |