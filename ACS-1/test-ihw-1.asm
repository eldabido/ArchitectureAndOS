.data
	.align 2
	arrayA:      .space 40          # ������ A (10 ��������� �� 4 �����).
	arrayB:      .space 40		# ������ B (10 ��������� �� 4 �����).
	elems: .asciz "������� ���������� ��������� �� 1 �� 10: "
	input_num: .asciz "������� �����: "
	space: .asciz " "
	test1: .asciz "���� 1: "
	test2: .asciz "���� 2: "
	test3: .asciz "���� 3: "
	test4: .asciz "���� 4: "
	test5: .asciz "���� 5: "
	test6: .asciz "���� 6: "
	test7: .asciz "���� 7: "
	test8: .asciz "���� 8: "
	test9: .asciz "���� 9: "
	test10: .asciz "���� 10: "
	value1: .word 1
	value2: .word 2
	value3: .word 3
	value4: .word 4
	value5: .word 5
	value6: .word 6
	value7: .word 7
	value8: .word 8
	value9: .word 9
	value10: .word 10
	enter: .asciz "\n"
.text

	# ���� 1.

	la a0, test1
	li a7, 4
	ecall
	li a1, 10
	la a0, arrayA
	li a4, -9
	jal input
	
	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall

	# ���� 2.
	
	la a0, test2
	li a7, 4
	ecall
	la a0, arrayA
	li a4, -8
	jal input
	
	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall
	
	# ���� 3.

	la a0, test3
	li a7, 4
	ecall
	la a0, arrayA
	li a4, -7
	jal input
	
	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall

	# ���� 4.
	
	la a0, test4
	li a7, 4
	ecall
	la a0, arrayA
	li a4, -4
	jal input
	
	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall

	# ���� 5.

	la a0, test5
	li a7, 4
	ecall
	la a0, arrayA
	li a4, 0
	jal input
	

	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall

	# ���� 6.

	la a0, test6
	li a7, 4
	ecall
	la a0, arrayA
	li a4, 1
	jal input
	
	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall
	
	# ���� 8 �� ������.

	la a0, test8
	li a7, 4
	ecall
	la a0, arrayA
	li a1, 1
	li a4, 1
	jal input

	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall

	# ���� 9.

	la a0, test9
	li a7, 4
	ecall
	la a0, arrayA
	li a1, 1
	li a4, -1
	jal input
	
	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall
	
	# ���� 10.

	la a0, test10
	li a7, 4
	ecall
	la a0, arrayA
	li a1, 7
	li a4, -3
	jal input
	
	la a0, arrayA
	la a2, arrayB
	li a3, 5
	jal filling_b
	
	la a2, arrayB
	jal output_array
	la a0, enter
	li a7, 4
	ecall
	
	li a7, 10
        ecall

input:
	li t1, 0	# �������.
	mv t0, a0	# ��� ��� a0 ����� ��������� ������ ��������, �� ��������� ����� � t0.
loop:
	sw a4, (t0)	# ��������� � ������ � ���� ������.
	addi t0, t0, 4	# ����� ������� �� 4.
	addi t1, t1, 1
	addi a4, a4, 1
	bltu t1, a1, loop
	ret


filling_b:
	li t1, 0	# �������.
	mv t0, a0	# ��� ��� a0 ����� ��������� ������ ��������, �� ��������� ����� � t0.
loop2:
	lw a0, (t0)	# ��������� ������� �� A.
	bgtz a0, fill_after_pos		# ���� ������� �������������, �� ������ �� ������, � ������ ��������� �������� � B.
	sub a0, a0, a3
	sw a0, (a2)	# ��������� � B.
	addi t0, t0, 4		# ����������� ������ A.
	addi a2, a2, 4		# ����������� ������ B.
	addi t1, t1, 1
	blt t1, a1, loop2 	# ���� i < N, �� ����������.
	ret	# ���� ������ ����, �� ��� �������� ���������� - �����.
fill_after_pos:
	sw a0, (a2)	# ��������� � B ��������� �������� ����� ��������������.
	addi t0, t0, 4		# ����������� ������ A.
	addi a2, a2, 4		# ����������� ������ B.
	addi t1, t1, 1
	bge t1, a1, ending	# ���� i >= N, �� �������.
	lw a0, (t0)
	j fill_after_pos	# ������� � ���������� ��������.
ending:
	ret



output_array:
	li t3, 0	# �������.
output_loop:
	lw  a0, (a2)	# ��������� �� A.
	li a7, 1
	ecall
	la a0, space	# ������� � ��������.
	li a7, 4
	ecall
	addi t3, t3, 1	# ����������� ������� � �����.
	addi a2, a2, 4
	blt t3, a1, output_loop
	ret	# �����.
	
