.data
output: .asciz "This is %d\n"
sformat_p: .asciz "%s\n"
help_info: .asciz "Please specify multiplier and multiplicand. \nmultiplication A B\n"
multiplier_len: .asciz "multiplier len:%d\n"
multiplicand_len: .asciz "multiplicand len:%d\n"
byte_format: .asciz "%02X"
hex_prefix: .asciz "0x"
newline: .asciz "\n\n"

.text

/* dump_command_line - dump command line parameters
 * @argc
 * @argv
 */

.globl dump_command_line
	.type dump_command_line @function
dump_command_line:
	pushq %rbp
	movq %rsp, %rbp
	subq $128, %rsp

	movq %rdi, -56(%rbp)
	movq %rsi, -48(%rbp)

	movq $0, %r13
loop:
	movq -48(%rbp), %rax
	leaq 0(%rax, %r13, 8), %rbx
	movq (%rbx), %rax
	/* leaq 0(, %r13, 8), %rbx */
	/* addq %rbx, %rax */
	/* movq (%rax), %rax */
	movq %rax, %rsi
	movl $sformat_p, %edi
	call printf
	inc %r13
	cmpq -56(%rbp), %r13
	jl loop

	leave
	ret

.globl char_to_num
	.type char_to_num @function
char_to_num:
	pushq %rbp
	movq %rsp, %rbp

	cmpl $'a', %edi
	jae lower

	cmpl $'A', %edi
	jae uppper

	cmpl $'0', %edi
	jae digit

lower:
	subl $'a', %edi
	addl $10, %edi
	movl %edi, %eax
	leave
	ret
uppper:
	subl $'A', %edi
	addl $10, %edi
	movl %edi, %eax
	leave
	ret
digit:
	subl $'0', %edi
	movl %edi, %eax
	leave
	ret


/* dump binary buf */
.globl dump_binary_buf
	.type dump_binary_buf @function
dump_binary_buf:
	pushq %r10
	pushq %r11
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp

	movq %rdi, -64(%rbp)
	movq %rsi, -56(%rbp)
	movq %rdi, %r11
	movq %rsi, %r10

	cmpq $0, %r10
	je .L6

	movq $hex_prefix, %rdi
	movq $0, %rsi
	call printf

	jmp .L6

.L5:
	movq $byte_format, %rdi
	movl $0, %ebx
	movb (%r11), %bl
	movq $0, %rsi
	movl %ebx, %esi
	pushq %r10
	pushq %r11
	call printf
	popq %r11
	popq %r10
	inc %r11
	dec %r10
.L6:
	cmpq $0, %r10
	jne .L5

	movq $newline, %rdi
	call printf

	movq %rbp, %rsp
	popq %rbp
	popq %r11
	popq %r10
	ret

/* transfer parameter from ASCII(hex) to binary code */

/* ascii_to_hex - transfer ascii to hex
 * @ascii - soruce buf
 * @hex - dest buf
 * @len - hex buf len
 */
.globl ascii_to_hex
	.type ascii_to_hex @function
ascii_to_hex:
	pushq %r10
	pushq %r11
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp

	movq %rdi, -64(%rbp)
	movq %rsi, -56(%rbp)
	movq %rdx, -48(%rbp) /* binary len */
	movq $0, -40(%rbp) /* ascii len */
	movq $0, -32(%rbp) /* sentry */
	movq %rdi, %r10
	movq %rsi, %r11


	/* skip 0x or 0X prefix */
	addq $2, %r10
	movq %r10, %rdi
	call strlen
	movq %rax, -40(%rbp) /* len of ascii */
	addq -40(%rbp), %r10
	dec %r10 /* last char */
	addq -48(%rbp), %r11
	dec %r11 /* last byte */

	jmp .L2
.L3:
	subq $1, -40(%rbp)
	movq $0, %rbx
	movb (%r10), %bl
	movl %ebx, %edi
	call char_to_num
	jmp test_sentry

heigh_4bit:
	movq $0, -32(%rbp)
	shl $4, %al
	addb %al, (%r11)
	dec %r11
	dec %r10
	jmp .L2
test_sentry:
	cmpq $0, -32(%rbp)
	jne heigh_4bit
	movq $1, -32(%rbp)
	movb %al, (%r11)
	dec %r10

.L2:
	cmpq $1, -40(%rbp)
	jae .L3

	/* END */
	movq %rbp, %rsp
	popq %rbp
	popq %r11
	popq %r10
	ret

/* add_to_product - 
 @product
 @product_len
 @index
 @addend
 */
	.type add_to_product @function
add_to_product:
	pushq %r10
	pushq %r11
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
	movb %cl, -64(%rbp)  /* addend */

	movq 32(%rbp), %r10
	addq 24(%rbp), %r10
	dec %r10 /* last byte of product */
	subq 16(%rbp), %r10 /* index byte */

	movb -64(%rbp), %cl
	jmp .L_DO_ADD

	.L_ADDTION_OVERFLOW:
		dec %r10
		movb $1, %cl
	.L_DO_ADD:
		movb (%r10), %bl
		addb %cl, (%r10)
		addb %cl, %bl
		jc .L_ADDTION_OVERFLOW


	/* END */
	movq %rbp, %rsp
	popq %rbp
	addq $32, %rsp
	popq %r11
	popq %r10
	ret

/*
pushfq
popq %rbx
movw %ax, -56(%rbp)
movl %ebx, -64(%rbp)
andl $0x1, -64(%rbp)

subq %r15, %r8
addb %al, (%r8)
pushfq
popq %rbx
movl %ebx, -60(%rbp)
andl $0x1, -60(%rbp)
jo .L_ADDB_OVERFLOW
jmp .L_NEXT_BYTE

.L_MULB_OVERFLOW:

.L_ADDB_OVERFLOW:
/*


/* do multiplication
   @multiplier
   @multiplier_len
   @multiplicand
   @multiplicand_len
   @product
   @product_len
   */

.globl big_multiplication
	.type big_multiplication @function
big_multiplication:
	pushq %r10
	pushq %r11
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
	movl $0, -64(%rbp) /* multiplication overflow flag */
	movl $0, -60(%rbp) /* addtion overflow flag */
	movl $0, -56(%rbp) /* tmp product */
	movq $0, -48(%rbp) /* current index */

	addq %rsi, %rdi
	movq %rdi, %r10
	movq %rsi, %r11
	dec %r10 /* last byte  of multiplier*/


	jmp .L_EX_COND

.L_EX:
	movq 32(%rbp), %r12
	movq 24(%rbp), %r13
	addq %r13, %r12
	dec %r12 /* last byte of multiplicand */

	movq 16(%rbp), %r8
	movq 8(%rbp), %r9
	addq %r9, %r8
	dec %r8 /* last byte of product */

	.L_IN:
		movb (%r12), %al
		mulb (%r10)
		movw %ax, -56(%rbp)

		/* calc index */
		movq 40(%rbp), %r14
		subq %r11, %r14
		movq 24(%rbp), %r15
		subq %r13, %r15
		addq %r14, %r15
		movq %r15, -48(%rbp)

		/* add AL to product */
		pushq %r8
		pushq %r9
		pushq %r10
		pushq %r11
		pushq %r12
		pushq %r13

		movq 16(%rbp), %rdi
		movq 8(%rbp), %rsi
		movq -48(%rbp), %rdx
		movw -56(%rbp), %ax
		movq $0, %rcx
		movb %al, %cl
		call add_to_product
		/*movq 16(%rbp), %rdi
		movq 8(%rbp), %rsi
		call dump_binary_buf*/

		popq %r13
		popq %r12
		popq %r11
		popq %r10
		popq %r9
		popq %r8

		/* add AH to prodeuct */
		pushq %r8
		pushq %r9
		pushq %r10
		pushq %r11
		pushq %r12
		pushq %r13

		movq 16(%rbp), %rdi
		movq 8(%rbp), %rsi
		movq -48(%rbp), %rdx
		addq $1, %rdx
		movw -56(%rbp), %ax
		movq $0, %rcx
		movb %ah, %cl
		call add_to_product
		/*movq 16(%rbp), %rdi
		movq 8(%rbp), %rsi
		call dump_binary_buf*/

		popq %r13
		popq %r12
		popq %r11
		popq %r10
		popq %r9
		popq %r8

		.L_NEXT_BYTE:
		dec %r13
		dec %r12
	.L_IN_COND:
		cmpq $1, %r13
		jae .L_IN
subq $1, %r11
dec %r10
.L_EX_COND:
	cmpq $1, %r11
	jae .L_EX


	/* end */
	movq %rbp, %rsp
	popq %rbp
	addq $48, %rsp
	popq %r11
	popq %r10
	ret

/* transfer binary code to ASCII(hex) */
/* transfer binary code to ASCII(dec) */

/* output resutl */

.globl main
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
	movq %rdi, -56(%rbp)
	movq %rsi, -48(%rbp)
	movq $0, -40(%rbp) /* multiplier len */
	movq $0, -32(%rbp) /* multiplicand len */
	movq $0, -24(%rbp) /* binary buf for multiplier */
	movq $0, -16(%rbp) /* binary buf for multiplicand */
	movq $0, -8(%rbp)  /* binary buf for product */
	movq $0, -64(%rbp) /* product len */
	call dump_command_line
	jmp normal

invalidpamameter:
	movq $help_info, %rdi
	call printf
	leave
	ret

normal:
	cmpq  $3, -56(%rbp)
	jne invalidpamameter

	/* get multiplier length */
	movq -48(%rbp), %rax
	addq $8, %rax
	movq (%rax), %rdi
	call strlen
	shr %rax
	/* TODO: add 1 only when %rax is odd */
	/* addq $1, %rax */
	movq %rax, -40(%rbp)
	movq %rax, %rsi
	movq $multiplier_len, %rdi
	call printf
	
	/* alloc binary buff for multiplier */
	movq -40(%rbp), %rdi
	movq $1, %rsi
	call calloc
	movq %rax, -24(%rbp)
	/* TODO: check buf if NULL */

	/* transfer multiplier from ascii to binary */
	movq -48(%rbp), %rax
	addq $8, %rax
	movq (%rax), %rdi
	movq -24(%rbp), %rsi
	movq -40(%rbp), %rdx
	call ascii_to_hex
	movq -24(%rbp), %rdi
	movq -40(%rbp), %rsi
	call dump_binary_buf


	/* get multiplicand length */
	movq -48(%rbp), %rax
	addq $16, %rax
	movq (%rax), %rdi
	call strlen
	shr %rax
	/* TODO: add 1 only when %rax is odd */
	/* addq $1, %rax */
	movq %rax, -32(%rbp)
	movq %rax, %rsi
	movq $multiplicand_len, %rdi
	call printf

	/* alloc binary buf for multiplicand */
	movq -32(%rbp), %rdi
	movq $1, %rsi
	call calloc
	movq %rax, -16(%rbp)
	/* TODO: check buf if NULL */

	/* trnasfer multiplicand from ascii to binary */
	movq -48(%rbp), %rax
	addq $16, %rax
	movq (%rax), %rdi
	movq -16(%rbp), %rsi
	movq -32(%rbp), %rdx
	call ascii_to_hex
	movq -16(%rbp), %rdi
	movq -32(%rbp), %rsi
	call dump_binary_buf

	/* alloc binary buf for product */
	movq -32(%rbp), %rdi
	addq -40(%rbp), %rdi
	movq %rdi, -64(%rbp)
	movq $1, %rsi
	call calloc
	movq %rax, -8(%rbp)
	/* TODO: check alloc memory success */

	movq -24(%rbp), %rdi
	movq -40(%rbp), %rsi
	movq -16(%rbp), %rdx
	movq -32(%rbp), %rcx
	movq -8(%rbp), %r8
	movq -64(%rbp), %r9
	call big_multiplication

	/* dump binary product */
	movq -8(%rbp), %rdi
	movq -64(%rbp), %rsi
	call dump_binary_buf

exit:

	/* free multiplier buf */
	movq -24(%rbp), %rdi
	call free

	/* free multiplicand buf */
	movq -16(%rbp), %rdi
	call free

	/* free binary product buf */
	movq -8(%rbp), %rdi
	call free

	add $64, %rsp
	leave
	ret
