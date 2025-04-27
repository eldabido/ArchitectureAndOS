.data
	one: .double 1

	ten: .double 10

	ask: .asciz "Input the number of exact digits (Please enter the number between 2 and 12 for required accuracy):\n"

	repeat: .asciz "\nDo you want to repeat? Then enter 0, otherwise enter the another number:\n"
.text
main:
	# Asking for accuracy.
    	la a0, ask
    	li a7, 4
    	ecall
    	li a7, 5
    	ecall

    	# Checking the entered number.
    	li a1, 12
    	li a2, 2
    	bgt a0, a1, main
    	blt a0, a2, main

    	# Going to subprogram.
    	jal count_e	# Only one number in register a0 is transferred to the subprogram - entered by the user.
    			# We don't need the result, because the answer is printed during the subprogram.
    			# So we return 0 in a0.

    	# Asking for continuing.
    	la a0, repeat
    	li a7, 4
    	ecall
    	li a7, 5
    	ecall
    	beqz a0, main

	# Exit.
    	li a7, 10
    	ecall

count_e:
	fld f1, one, t0     	# Put constant 1 to f2.
        fsub.d f2, f2, f2	# Iteration. i = 0, 1, 2, 3...
        fmv.d f3, f1		# Factorial.
        fmv.d f4, f1		# For counting e.
        fld f5, ten, t0		# Put constant 10 to f10.
    	fmv.d f0, f1		# 1/10^n - accuracy. f0 = n.
    	
count_the_accur:
    	blez a0, next 		# If n <= 0 then skip this loop.
    	fmul.d f0, f0, f5 	# counting 1 / 10^n.
	addi a0, a0, -1
	j count_the_accur
next:
    	fdiv.d f5, f1, f0   	# accuracy.
loop:
	fadd.d f2, f2, f1 	# n += 1.
    	fmul.d f3, f3, f2 	# n! = (n-1)! * n.
   	 fdiv.d f0, f1, f3 	# 1 / n!.
    	fadd.d f4, f4, f0 	# e += 1/n!.
    	flt.d t0, f0, f5 	# checking the accuracy.
    	beqz t0, loop 		# If accuracy is enough, then we end the process.

	#Output.
    	li a7, 3
    	fmv.d fa0, f4
    	ecall
    	ret
