.data
output: .asciz "This is %d\n"
sformat_p: .asciz "%s\n"
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
	call dump_command_line

	add $64, %rsp
	pushq $0
	call exit
