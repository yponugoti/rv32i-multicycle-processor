	.file	"factorial.c"
	.option nopic
	.text
	.align	2
	.globl	int_multiply
	.type	int_multiply, @function
int_multiply:
    addi  sp,sp,-48
	sw  s0,44(sp)
	addi  s0,sp,48
	sw  a0,-36(s0)
    sw  a1, -40(s0)
	sw  zero,-20(s0)
	sw  zero,-24(s0)
    lw a5, -40(s0)
    blt a5, zero, .L4
    j .L2
.L3:
    lw  a4,-20(s0)
	lw  a5,-36(s0)
	add a5,a4,a5
	sw  a5,-20(s0)
	lw  a5,-24(s0)
	addi  a5,a5,1
	sw  a5,-24(s0)
.L2:
    lw  a4,-24(s0)
	lw  a5,-40(s0)
	blt a4,a5,.L3
    j .L6
.L5:
    lw  a4,-20(s0)
	lw  a5,-36(s0)
	sub a5,a4,a5
	sw  a5,-20(s0)
	lw  a5,-24(s0)
	addi  a5,a5,-1
	sw  a5,-24(s0)
.L4:
    lw  a4,-24(s0)
	lw  a5,-40(s0)
	blt a5,a4,.L5
.L6:
    lw  a5,-20(s0)
	mv  a0,a5
	lw  s0,44(sp)
	addi  sp,sp,48
	jr  ra
    .size	int_multiply, .-int_multiply
    .align	2
	.globl	factorial
	.type	factorial, @function
factorial:
    addi  sp,sp,-48 
    sw ra, 44(sp)
	sw  s0,40(sp)
	addi  s0,sp,48 
	sw  a0,-36(s0)  
	li a5, 1
	sw  a5, -20(s0)
.L7:
    lw a5, -36(s0)
    bge zero, a5, .L8
    lw a0, -20(s0)
    lw a1, -36(s0)
    call int_multiply
    sw a0, -20(s0)
    lw a5, -36(s0)
    addi a5, a5, -1
    sw a5, -36(s0)
    j .L7
.L8:
    lw  a5,-20(s0)
	mv  a0,a5
	lw ra, 44(sp)
    lw s0, 40(sp)
	addi  sp,sp,48
	jr  ra
    .size	factorial, .-factorial
    .align	2
	.globl	main
	.type	main, @function
main:
    addi  sp,sp,-16  
	sw  ra,12(sp) 
	sw  s0,8(sp)    
	addi  s0,sp,16 
	li  a0, 8
	call  factorial
	mv  a5,a0   
	mv  a0,a5 
	lw  ra,12(sp)  
	lw  s0,8(sp)    
	addi  sp,sp,16   
	jr  ra
	.size	main, .-main
	.ident	"GCC: (GNU) 7.2.0"