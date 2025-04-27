.data
	.align 2
	arrayA:      .space 40          # Array A (10 elements by 4 bytes).
	arrayB:      .space 40		# Array B (10 elements by 4 bytes).
	elems: .asciz "Input the size of array from 1 to 10: "
	input_num: .asciz "Input number: "
	space: .asciz " "
	question: .asciz "If you want to continue the program,then input 0, otherwise input any other number: "
	enter: .asciz "\n"
.text
checking:
	la a0, elems	# Output the message for input.
	li a7, 4
	ecall
	li a7, 5	# Getting the size of array.
	ecall
	li t5, 1	# Checking the size of array. If >= 1 and <= 10, that's good.
	li t6, 10
	blt a0, t5, checking	# If not, we ask for another number.
	bgt a0, t6, checking
	mv a1, a0	# Preparing the parametres for going to subprogram of inputing the elements of array.
	la a0, arrayA	# a1 has the size of array, a0 has the pointer on the beginning of A.
	jal input	# Going to subprogram. There is essentially no return value since we are filling the array, but they should be in a0, a1.

	la a0, arrayA	# After entering the array, we are preparing to call the second subprogram to form array B.
	la a2, arrayB	# A0 contains the address for array A, a1 continues to contain the size of the array, and a2 contains the address for array B.
	li a3, 5	# In a3 we put 5 to subtract from the necessary elements.
	jal filling_b	# Go to the subprogram. There is essentially no return value since we are filling the array, but they should be in a0, a1.

	la a2, arrayB	# Preparing for the last subprogram for displaying array B. A1 contains the size, a2 contains a pointer to B.
	jal output_array # There is essentially no return value since we are outputting an array, but they should be in a0, a1.

	la a0, enter # Asking about the continuing of program.
	li a7, 4
	ecall
	la a0, question
	li a7, 4
	ecall
	li a7, 5
	ecall
	beqz a0, checking
	li a7, 10	# Ending of program.
	ecall




input:
	li t1, 0	# Counter.
	mv t0, a0	# Since a0 will take other values, we will move the address to t0.
loop:
	la a0, input_num	# Printing a message to the user.
	li a7, 4
	ecall
	li a7, 5	# Input of the number.
	ecall
	sw a0, (t0)	# Saving to the array and continuing.
	addi t0, t0, 4	# Move the address by 4.
	addi t1, t1, 1
	bltu t1, a1, loop
	li a0, 0 # Program is void, so we will return 0 at a0.
	ret


filling_b:
	li t1, 0	# Counter.
	mv t0, a0	# Since a0 will take other values, we will move the address to t0.
loop2:
	lw a0, (t0)	# Load element from A.
	bgtz a0, fill_after_pos		# If the element is positive, then we don't change anything else, just the remaining elements in B.
	sub a0, a0, a3
	sw a0, (a2)	# Load into B.
	addi t0, t0, 4		# Increase index A.
	addi a2, a2, 4		# Increase index B.
	addi t1, t1, 1
	blt t1, a1, loop2 	# If i < N, then we continue.
	ret	# If you came here, then all the elements were processed - the end.
fill_after_pos:
	sw a0, (a2)	# Load the remaining elements into B after the positive one.
	addi t0, t0, 4		# Increase index A.
	addi a2, a2, 4		# Increase index B.
	addi t1, t1, 1
	bge t1, a1, ending	# If i >= N, then we exit.
	lw a0, (t0)
	j fill_after_pos	# Move to the next element.
ending:
	li a0, 0 # Program is void, so we will return 0 at a0.
	ret



output_array:
	li t3, 0	# Counter.
output_loop:
	lw  a0, (a2)	# Load element from A.
	li a7, 1
	ecall
	la a0, space	# Output with space.
	li a7, 4
	ecall
	addi t3, t3, 1	# Increasing the counter and the address.
	addi a2, a2, 4
	blt t3, a1, output_loop
	li a0, 0 # Program is void, so we will return 0 at a0.
	ret	# The end.
	
