.data
output: .asciz "This is %d\n"
.text
.globl main
main:
	pushq %rbp
	movq %rsp, %rbp
	movl $10, %esi
	movl $output, %edi
	call printf

	add $16, %rsp
	pushq $0
	call exit
