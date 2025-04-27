.include "macro-syscalls.m"

.eqv    NAME_SIZE 256	# Size for file name.
.eqv    TEXT_SIZE 512	# Size of buf.

.data
er_name_mes: .asciz "Incorrect file name\n"
er_read_mes: .asciz "Incorrect read operation\n"

file_name: .space NAME_SIZE # Name of file.
strbuf:	.space TEXT_SIZE # Buffer for reading text.
ans_str: .space TEXT_SIZE # Answer.

.text
	# Reading the file.
	print_str ("\nInput path to file for reading:\n")
	str_get(file_name, NAME_SIZE)
    	open(file_name, READ_ONLY)
    	li s1 -1			# Checking.
    	beq a0 s1 er_name
    	mv s0 a0       			# Saving the descryptor.
    	#Allocating memory.
    	allocate(TEXT_SIZE)		# The result in a0.
    	mv s3, a0			# Storing heap address in register.
    	mv s5, a0			# Storing changeable heap address in register.
    	li s4, TEXT_SIZE		# Saving const.
    	mv s6, zero			# String length.  	

read_loop:
    	read_addr_reg(s0, s5, TEXT_SIZE) # Reading the block of text.
    	# Checking for errors.
    	beq a0 s1 er_read
    	mv s2 a0       	# Saving the length.
    	add s6, s6, s2		# Increasing the size.
    	# Ending the process, if the length of text is less than size of buf.
    	bne s2 s4 end_loop
    	# Increasing size of buf.
    	allocate(TEXT_SIZE)
    	add s5 s5 s2 # Changing the address.
    	b read_loop # Reading the next block.
   
end_loop:
    	# Closing the file.
    	close(s0)
    	# Placing 0 at the end of str.
    	mv t0 s3		# buf address in heap
    	add t0 t0 s6		# Address of the last read symbol.
    	addi t0 t0 1		# Place for 0.
    	sb zero (t0)
	
	# Saving needed symbols.
	mv a0 s3
	la a1 ans_str
	jal num_filter
	mv s3 a0
	
	
	
    	# Saving answer in another file.
    	print_str ("Input path to file for writing: ")
    	str_get(file_name, NAME_SIZE)
    	open(file_name, WRITE_ONLY)
    	# Checking for errors.
    	li s1 -1
    	beq a0 s1 er_name
    	mv s0 a0       			# Descryptor.
	# Saving.
    	li a7, 64       		# Sys call for writing in file.
    	mv a0, s0 			# Descryptor.
    	mv a1, s3  			# Address of buf.
    	mv a2, s6    			# Size.
    	ecall

    	# End.
    	exit

num_filter:
	mv t0 a1 # Address to t0.
	li t2 0 # Counter of nums.
	li t3 '+'
	li t4 '0'
	li t5 '9'
loop:
	lb t1 (a0) 	# Getting the symbol.
	beqz t1 fin 	# Checking for the end.
	blt t1 t4 skip 	# Number or not.
	bgt t1 t5 skip
	addi t2 t2 1 	# If it is the number then we save it and increase the counter.
	sb t1 (t0)
	addi t0 t0 1 	# Next symbol.
	j next
skip:
	bnez t2 add_plus # If not a number, then we check whether they were there before in order to write a plus.
next:
	addi a0 a0 1	# Next symbol.
	b loop
add_plus:
	sb t3 (t0)	# Writing a plus.
	addi t0 t0 1
	li t2 0
	j next

fin:
	sb zero (t0)	# Zero to the end of string.
	mv a0 a1
	ret

# Errors.
er_name:
    	la a0 er_name_mes
    	li a7 4
    	ecall
    	exit
er_read:
    	la a0 er_read_mes
    	li a7 4
    	ecall
    	exit

