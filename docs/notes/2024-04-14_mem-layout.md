# PARTOS Memory Layout

PartOS requires a custom ROM that includes the PartOS microkernel, and the PartOS OS loader. At start up the microkernel is copied to the non-banked RAM and the 
loader loads and runs the boot sector.

~~~
       +-----------------------+
0x0000 |         page 0        |    256 bytes
       +-----------------------+
0x0100 |                       | 
       |                       |
       |                       |
       |      banked heap      |    48896 bytes
       |                       |
       |                       |
       |                       |
       +-----------------------+
       |                       |
0xc000 |    non-banked heap    |    12736 bytes
       |                       |
       +-----------------------+
       |                       |
0xf1bf |       u-kernel        |    2048 bytes
       |                       |
       +-----------------------+    
0xf9bf |    sys. vars (64b)    |    64 bytes
0xf9ff +-----------------------+   
       |     1kb os stack      |    1024 bytes
       +-----------------------+   
0xfdff | interrupt vector 0x00 | \    
       +-----------------------+  | 
       |          ...          |  | 512 bytes
       +-----------------------+  |
0xfffd | interrupt vector 0xff | /
       +-----------------------+
~~~