	.file	"fib_r.c"
	.option nopic
	.text
	.align	2
	.globl	fib_r
	.type	fib_r, @function
fib_r:
    addi  sp,sp,-48
	sw  ra,44(sp)
    sw s0, 40(sp)
	addi  s0,sp,48
	sw  a0,-20(s0)
    li a5, 1
    bgeu a5, a0, .L2
    addi a0, a0, -1
    call fib_r
    sw a0, -24(s0)
    lw a5, -20(s0)
    addi a0, a5, -2
    call fib_r
    lw a5, -24(s0)
    add a0, a5, a0
.L2:
    lw ra, 44(sp)
    lw s0, 40(sp)
    addi sp, sp, 48
    jr ra
    .size	fib_r, .-fib_r
	.align	2
	.globl	main
	.type	main, @function
main:
    addi  sp,sp,-16  
	sw  ra,12(sp) 
	sw  s0,8(sp)    
	addi  s0,sp,16 
	
    li a0, 1
    call fib_r
    mv s2, a0

    li a0, 3
    call fib_r
    mv s3, a0

    li a0, 8
    call fib_r
    mv s4, a0

    li a0, 17
    call fib_r
    mv s5, a0

    li a0, 0
	lw  ra,12(sp)  
	lw  s0,8(sp)    
	addi  sp,sp,16   
	jr  ra
	.size	main, .-main
	.ident	"GCC: (GNU) 7.2.0"