.data
	one: .double 1

	ten: .double 10

	ask: .asciz "Input the number of exact digits (Please enter the number between 2 and 12 for required accuracy):\n"

	repeat: .asciz "\nDo you want to repeat? Then enter 0, otherwise enter the another number:\n"

	test1: .asciz "Test 1: "
	test2: .asciz "Test 2: "
	test3: .asciz "Test 3: "
	test4: .asciz "Test 4: "
	test5: .asciz "Test 5: "
	enter: .asciz "\n"

.text
testing1:
	la a0, test1
	li a7, 4
	ecall

    	li a0, 2
    	# Checking the entered number.
    	li a1, 12
    	li a2, 2
    	bgt a0, a1, testing1
    	blt a0, a2, testing1

    	# Going to subprogram.
    	jal count_e	# Only one number in register a0 is transferred to the subprogram - entered by the user.
    			# We don't need the result, because the answer is printed during the subprogram.
    			# So we return 0 in a0.
	la a0, enter
	li a7, 4
	ecall

testing2:
	la a0, test2
	li a7, 4
	ecall

	li a0, 3
    	# Checking the entered number.
    	li a1, 12
    	li a2, 3
    	bgt a0, a1, testing2
    	blt a0, a2, testing2

    	# Going to subprogram.
    	jal count_e	# Only one number in register a0 is transferred to the subprogram - entered by the user.
    			# We don't need the result, because the answer is printed during the subprogram.
    			# So we return 0 in a0.
	la a0, enter
	li a7, 4
	ecall

testing3:
	la a0, test3
	li a7, 4
	ecall

	li a0, 5
    	# Checking the entered number.
    	li a1, 12
    	li a2, 3
    	bgt a0, a1, testing3
    	blt a0, a2, testing3

    	# Going to subprogram.
    	jal count_e	# Only one number in register a0 is transferred to the subprogram - entered by the user.
    			# We don't need the result, because the answer is printed during the subprogram.
    			# So we return 0 in a0.
	la a0, enter
	li a7, 4
	ecall

testing4:
	la a0, test4
	li a7, 4
	ecall

	li a0, 9
    	# Checking the entered number.
    	li a1, 12
    	li a2, 3
    	bgt a0, a1, testing4
    	blt a0, a2, testing4

    	# Going to subprogram.
    	jal count_e	# Only one number in register a0 is transferred to the subprogram - entered by the user.
    			# We don't need the result, because the answer is printed during the subprogram.
    			# So we return 0 in a0.
	la a0, enter
	li a7, 4
	ecall

testing5:
	la a0, test5
	li a7, 4
	ecall

	li a0, 12
    	# Checking the entered number.
    	li a1, 12
    	li a2, 3
    	bgt a0, a1, testing5
    	blt a0, a2, testing5

    	# Going to subprogram.
    	jal count_e	# Only one number in register a0 is transferred to the subprogram - entered by the user.
    			# We don't need the result, because the answer is printed during the subprogram.
    			# So we return 0 in a0.
	la a0, enter
	li a7, 4
	ecall

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
