
		# Reads 8 integers
		# Stores them in an array
		# Prints 8-times the ints with reverse order
		
	.data
	
str_in:	.asciz "Enter 8 integers:"
str_nl:	.asciz "\n"
str_tab: .asciz "	"
str_line: .asciz "----------------------------"
	.align 2	# aligns the current location within the code to a word (4-byte = 2^2) boundary
arr: 	.space 32	# Array 8(ints) x 4(bytes/int) = 32(bytes)
	
	
	.text
	.globl main

main:

        la 	x5, arr		# load address of arr to x5
        
        addi 	x6, x0, 8	# counter used for the array
        addi	x7, x0, 5	# counter used for multiplication
	#Print str_in
	addi    x17, x0, 4	# environment call code for print_string
        la      x10, str_in     # load address of str_in on x10
        ecall               	# prints str_in
        #Print new line
        la 	x10, str_nl	# load address of the str_line on x10
	addi    x17, x0, 4	# environment call code for print_string
	ecall			# prints str_line
	loopRead:			# Loop for reading the integers
	
		addi    x17, x0, 5      # environment call code for read_int
        	ecall                   # read a line containing an integer
	
		sw 	x10, 0(x5)	# stores the content of x28 to the array (x5)
		addi 	x5, x5, 4	# the pointer x5 is advanced by 4 (bytes) so that it points to the next shell of the array
		addi 	x6, x6 , -1	# reducing the counter by 1 so that the loop happens 8 times and we store 8 integers in the array
		bne	x6, x0, loopRead	# if( x6 != 0 ) goto loopRead
	
	la 	x10, str_line	# load address of the str_line on x10
	addi    x17, x0, 4	# environment call code for print_string
	ecall			# prints str_line
	
	la 	x10, str_nl	# stores the address of str_nl on x10
	ecall			# prints str_nl
	
	#Loop for printing given integers and their multiplication
	addi 	x6, x0, 8	# resets the counter used for the array so it can be used for printing it
	loopPrint:		# loop for printing the integers
		
		addi 	x5, x5, -4		# the pointer x5 is reduced by 4 (bytes) so that it points to the previous shell of the array
		
		#Print given integer
		lw	x10, (x5)		# loads the content of the array (x5) to x10
		addi 	x17, x0, 1		# environment call code for print_integer
		ecall				# print x10
		
		#Print tab
		la 	x10, str_tab	# load address of the str_tab on x10
		addi    x17, x0, 4	# environment call code for print_string
		ecall			# prints str_tab
		
		#Multiplication
		lw	x28, (x5)		# copy integer from array x5 to register x28
		add	x29, x28, x0	# copy integer from register x28 to register x29
		mult:			# Loop for multiplicating the integers

			add	x28, x28, x29	# add the number to itself one time per loop
			addi 	x7, x7, -1	# reducing the counter by 1 so that the loop happens 5 times and the number is added 5 times to itself (5+1 = 6)
			bne	x7, x0, mult	# if( x7 != 0 ) goto mult 
			
		addi	x7, x0, 5	# reset the counter used for multiplication
		
		#Print multiplied integer
		add	x10, x28, x0		# loads the multiplied integer from x28 to x10
		addi 	x17, x0, 1		# environment call code for print_integer
		ecall				# print x10
		
		#Print new line
		la	x10, str_nl		# load address of str_nl on x10
		addi 	x17, x0, 4		# environment call code for print_string
		ecall				# print x10
		
		addi 	x6, x6 , -1		# reducing the counter by 1 so that the loop happens 8 times and we print all 8 integers of the array
		bne	x6, x0, loopPrint	# if( x6 != 0 ) goto loopPrint
		
	j	main 		# unconditionally jump back to main
		

