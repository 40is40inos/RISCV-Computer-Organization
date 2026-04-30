	.data

strIN: 	.asciz	"Enter an integer (negative to exit): "
strERL: .asciz	"Read loop ended, scan loop is starting \n"
strExit:.asciz	"== Program Exit ==\n"
strnl: 	.asciz "\n"
strDbg: .asciz "MASTER DEBUGGER"

	.align 2	# aligns the current location within the code to a word (4-byte = 2^2) boundary
	
	.text
	.globl main
	
	# Program Reads an integer from the console, until its 0 or less, Creates new node for the list
	# Inserts the integer to the new node, connects the node to the list
	# Each node has an integer (data) and a pointer to the next node (nxtPtr)
	# s0(x8) = pointer to start of list (first node) - root
	# s1(x9) = pointer to  end  of list (last node)  - tail
	# Then asks for a new integer, prints all nodes who have data larger than the given integer
	# Reapeats until the given integer is negative

			# 7.4
main:
				# Start with creating the "dummy" node with data = 0, and nxtPtr = 0
	jal 	ra, node_alloc		# Allocate memory for the node, will be returned at a0 register
	sw	x0, 0(a0)		# dummy.data = 0
	sw	x0, 4(a0)		# dummy.next = NULL
	addi	s1, a0, 0		# Set s1(x9) tail pointer to contain dummy node's address
	addi	s0, a0, 0		# Set s0(x8) root pointer to contain dummy node's address
	
readLoop:			# Get integers from console, add new node to list for every integer

		# Save s1 and s0 to the stack
		addi sp, sp, -8    		# Make room for two 32-bit registers
		sw s1, 4(sp)       		# Save s1 to the stack (note the offset)
		sw s0, 0(sp)       		# Save s0 to the stack
					
	jal 	read_int		# Get data
	
		# Restore s1 and s0 from the stack
		lw s0, 0(sp)       		# Restore s0 from the stack
		lw s1, 4(sp)       		# Restore s1 from the stack (note the offset)
		addi sp, sp, 8     		# Adjust the stack pointer back
		
	bge 	x0, x10, endReadLoop	# if( 0 >= int ) then end the readLoop, else
	addi 	t0, a0, 0		# t0 = data (store the data from a0 to a temp register t0)
	
		# Save s1 and s0 to the stack
		addi sp, sp, -8    		# Make room for two 32-bit registers
		sw s1, 4(sp)       		# Save s1 to the stack (note the offset)
		sw s0, 0(sp)       		# Save s0 to the stack
		
				
	jal 	node_alloc		# Allocate space for new node
		
		# Restore s1 and s0 from the stack
		lw s0, 0(sp)       		# Restore s0 from the stack
		lw s1, 4(sp)       		# Restore s1 from the stack (note the offset)
		addi sp, sp, 8     		# Adjust the stack pointer back
		
	sw 	t0, 0(a0)		# a0.data = data(t0) (store the data from the console to the new node's data)
	sw 	x0, 4(a0)		# a0.nextPtr = NULL
	sw 	a0, 4(s1)		# s1.nxtPrt = a0 (store the new node's address to the last node's nxtPtr)
	addi	s1, a0, 0		# s1 = a0 now the s1 should point at the address of the new node (new tail)
	j	readLoop
      endReadLoop:
	
				# Print a string for end Read loop
	la 	a0, strERL		# Load string address to register x10
	addi 	a7, x0, 4		# Environment call code for print_string
	ecall	

getScanInt:		# 7.5
				# Get integer from console for scan
	jal 	read_int
	addi 	s1, a0, 0		# store the int to s1 /GivenInt
	blt	s1, x0, exit		# if (s1 < 0) exit
	addi 	s2, s0, 0		# set s2 (scanning pointer) to root
	
		# Save s1 and s0 to the stack
		addi sp, sp, -12    		# Make room for two 32-bit registers
		sw s2, 8(sp)
		sw s1, 4(sp)       		# Save s1 to the stack (note the offset)
		sw s0, 0(sp)       		# Save s0 to the stack
			
	addi 	a0, s2, 0		# arguments for search_list
	addi 	a1, s1, 0
	
	jal	search_list

		# Restore s1 and s0 from the stack
		lw s0, 0(sp)       		# Restore s0 from the stack
		lw s1, 4(sp)       		# Restore s1 from the stack (note the offset)
		lw s2, 8(sp)
		addi sp, sp, 12     		# Adjust the stack pointer back
		
	j 	getScanInt		# get new int for scan
	
exit:
	la 	a0, strExit		# Load str address to register x10
	addi 	a7, x0, 4		# Environment call code for print_string
	ecall	
	
	addi	a7, x0, 10		# enviromental call for exit
	ecall
	
	
# Subroutines
	

node_alloc: 			# Allocates memory for a node, the pointer to the allocated space will be stored at register a0
	
	addi 	a7, x0, 9		# Environment call code for "sbrk" (Set Break), Space incrementation
	addi 	a0, x0, 8		# Argument for the sbrk call: 8 bytes of space to allocate
	ecall				# Allocate
	jr	ra, 0			# return 

read_int:			# Reads integer from console, will be stored at a0

	la 	a0, strIN		# Load strIN address to register a0(x10)
	addi 	a7, x0, 4		# Environment call code for print_string
	ecall	
	addi 	a7, x0, 5		# Environment call code for read_int
	ecall
	jr	ra, 0			# return

print_node:			# Checks if node.data(a0) is greater than GivenInt(a1), prints it if it is
	bge	a1, a0, skipPrint	# if( GivenInt >= nodeInt) skip the print
	addi 	a7, x0, 1		# ecall code for print_int, data is already at a0
	ecall		
	la 	a0, strnl		# load string to be printed, New Line
	addi 	a7, x0, 4		# ecall code for print str
	ecall	
      skipPrint:
	jr	ra, 0			# return			
	
search_list:			# a0 = root node, a1 = GivenInt
	
	addi s0, a0, 0			# s0 = root node
	addi s1, a1, 0			# s1 = GivenInt
	addi s2, s0, 0			# s2 = index node
	
	scannerLooper:
		# Save s1 and s0 to the stack
		addi sp, sp, -16    		# Make room for two 32-bit registers
		sw ra, 12(sp)
		sw s2, 8(sp)
		sw s1, 4(sp)       		# Save s1 to the stack (note the offset)
		sw s0, 0(sp)       		# Save s0 to the stack
					
	lw 	a0, 0(s2)		# load value of current node to a0, argument for print_node
	addi 	a1, s1, 0		# copy the GivenInt to a1(x11), 2nd argument for print_node
	jal 	print_node
	
		# Restore s1 and s0 from the stack
		lw s0, 0(sp)       		# Restore s0 from the stack
		lw s1, 4(sp)       		# Restore s1 from the stack (note the offset)
		lw s2, 8(sp)
		lw ra, 12(sp)
		addi sp, sp, 16     		# Adjust the stack pointer back

	lw 	s2, 4(s2)		# point to next node
	bne	s2, x0, scannerLooper	# if( nextNode != NULL) goto scannerLooper
	
	jr	ra, 0
	
debugger:
	la 	a0, strDbg
	addi 	a7, x0, 4		# Environment call code for print_string
	ecall	
	jr 	ra, 0