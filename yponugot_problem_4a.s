	.file	"fib_nr.c"
	.option nopic
	.text
	.align	2
	.globl	fib_nr
	.type	fib_nr, @function
fib_nr:
	addi  sp,sp,-48
	sw  s0,44(sp) 
	addi  s0,sp,48  
	sw  a0,-36(s0) 
	sw  zero,-20(s0)
    li a5, 1 
	sw  a5,-24(s0) 
    sw a5, -32(s0)
    j .L2
.L3:
    lw a4, -20(s0)
    lw a5, -24(s0)
    add a5, a4, a5
    sw a5, -28(s0)
    lw a5, -24(s0)
    sw a5, -20(s0)
    lw a5, -28(s0)
    sw a5, -24(s0)
    lw a5, -32(s0)
    addi a5, a5, 1
    sw a5, -32(s0)
.L2:
    lw a4, -32(s0)
    lw a5, -36(s0)
    bgeu a5, a4, .L3
    lw  a5,-20(s0)
	mv  a0,a5
	lw s0, 44(sp)
	addi  sp,sp,48
	jr  ra
    .size	fib_nr, .-fib_nr
	.align	2
	.globl	main
	.type	main, @function
main:
    addi  sp,sp,-16  
	sw  ra,12(sp) 
	sw  s0,8(sp)    
	addi  s0,sp,16 
	
    li a0, 1
    call fib_nr
    mv s2, a0

    li a0, 3
    call fib_nr
    mv s3, a0

    li a0, 8
    call fib_nr
    mv s4, a0

    li a0, 17
    call fib_nr
    mv s5, a0

    li a0, 0
	lw  ra,12(sp)  
	lw  s0,8(sp)    
	addi  sp,sp,16   
	jr  ra
	.size	main, .-main
	.ident	"GCC: (GNU) 7.2.0"