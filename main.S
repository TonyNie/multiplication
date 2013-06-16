.data
output: .asciz "This is %d\n"
sformat_p: .asciz "%s\n"
help_info: .asciz "Please specify multiplier and multiplicand. \nmultiplication A B\n"
multiplier_len: .asciz "multiplier len:%d\n"
multiplicand_len: .asciz "multiplicand len:%d\n"
.text

/* dump parameters */

/* get paramaeter len */

/* transfer parameter from ASCII(hex) to binary code */
/* transfer parameter from ASCII(dec) to binary code */
/* get multiplier and multiplicand*/

/* do multiplication */

/* transfer binary code to ASCII(hex) */
/* transfer binary code to ASCII(dec) */

/* output resutl */


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

.globl main
main:
	pushq %rbp
	movq %rsp, %rbp
	subq $64, %rsp
	movq %rdi, -56(%rbp)
	movq %rsi, -48(%rbp)
	movq $0, -40(%rbp)
	movq $0, -32(%rbp)
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
	movq %rax, -40(%rbp)
	movq %rax, %rsi
	movq $multiplier_len, %rdi
	call printf

	/* get multiplicand length */
	movq -48(%rbp), %rax
	addq $16, %rax
	movq (%rax), %rdi
	call strlen
	movq %rax, -40(%rbp)
	movq %rax, %rsi
	movq $multiplier_len, %rdi
	call printf



	add $64, %rsp
	pushq $0
	call exit
