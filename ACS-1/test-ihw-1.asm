.data
	.align 2
	arrayA:      .space 40          # Массив A (10 элементов по 4 байта).
	arrayB:      .space 40		# Массив B (10 элементов по 4 байта).
	elems: .asciz "Введите количество элементов от 1 до 10: "
	input_num: .asciz "Введите число: "
	space: .asciz " "
	test1: .asciz "Тест 1: "
	test2: .asciz "Тест 2: "
	test3: .asciz "Тест 3: "
	test4: .asciz "Тест 4: "
	test5: .asciz "Тест 5: "
	test6: .asciz "Тест 6: "
	test7: .asciz "Тест 7: "
	test8: .asciz "Тест 8: "
	test9: .asciz "Тест 9: "
	test10: .asciz "Тест 10: "
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

	# Тест 1.

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

	# Тест 2.
	
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
	
	# Тест 3.

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

	# Тест 4.
	
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

	# Тест 5.

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

	# Тест 6.

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
	
	# Тест 8 из списка.

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

	# Тест 9.

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
	
	# Тест 10.

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
	li t1, 0	# Счетчик.
	mv t0, a0	# Так как a0 будет принимать другие значения, то перенесем адрес в t0.
loop:
	sw a4, (t0)	# Сохраняем в массив и идем дальше.
	addi t0, t0, 4	# Адрес двигаем на 4.
	addi t1, t1, 1
	addi a4, a4, 1
	bltu t1, a1, loop
	ret


filling_b:
	li t1, 0	# Счетчик.
	mv t0, a0	# Так как a0 будет принимать другие значения, то перенесем адрес в t0.
loop2:
	lw a0, (t0)	# Загружаем элемент из A.
	bgtz a0, fill_after_pos		# Если элемент положительный, то больше не меняем, а просто остальные элементы в B.
	sub a0, a0, a3
	sw a0, (a2)	# Загружаем в B.
	addi t0, t0, 4		# Увеличиваем индекс A.
	addi a2, a2, 4		# Увеличиваем индекс B.
	addi t1, t1, 1
	blt t1, a1, loop2 	# Если i < N, то продолжаем.
	ret	# Если пришли сюда, то все элементы обработали - конец.
fill_after_pos:
	sw a0, (a2)	# Загружаем в B остальные элементы после положительного.
	addi t0, t0, 4		# Увеличиваем индекс A.
	addi a2, a2, 4		# Увеличиваем индекс B.
	addi t1, t1, 1
	bge t1, a1, ending	# Если i >= N, то выходим.
	lw a0, (t0)
	j fill_after_pos	# Перейти к следующему элементу.
ending:
	ret



output_array:
	li t3, 0	# Счетчик.
output_loop:
	lw  a0, (a2)	# Загружаем из A.
	li a7, 1
	ecall
	la a0, space	# Выводим с пробелом.
	li a7, 4
	ecall
	addi t3, t3, 1	# Увеличиваем счктчик и адрес.
	addi a2, a2, 4
	blt t3, a1, output_loop
	ret	# Конец.
	
