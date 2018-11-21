###############################
#         Ilya Deryabin       #
#    Calculator V0.0	      #
###############################
	.eqv  LIMIT      80
	.macro prints
		li $v0, 4
		syscall
	.end_macro
	.macro printc
		li $v0, 11
		syscall
	.end_macro
	.macro printd
		li $v0, 3
		syscall
	.end_macro
	.data
	# Declare main as a global function
buffer:   .space LIMIT
x_double:   .double 0
y_double:   .double 0
res_double: .double 0
zero:	.double	0
ten:	.double	10
num2:	.double	2
accuracy:	.double	0.0001
msg1: 	.asciiz "Enter a number(single precision floating point) please: \n"
msg2: 	.asciiz "The Answer is: "
msg3: 	.asciiz "R^2: "
msg4: 	.asciiz "Delta: "
nl: 	.asciiz "\n"
hello:	.asciiz "Welcome to calculation programm!\n"
mess1:	.asciiz "Enter first operand: \n"
mess12:	.asciiz "Enter second operand: \n"
mess2:	.asciiz "Enter operator: \n"
mparsed: .asciiz "Parsed: \n"
mess_fail: .asciiz "INVALID INPUT\n"
error:	.asciiz "Unknown operation\n"
error_modulo: .asciiz "Second operator cannot be negative\n"
temp:	.asciiz "Temporary "
mess_res:	.asciiz "Result: "
	.globl main

	# All program code is placed after the
	# .text assembler directive
	.text 		

# The label 'main' represents the starting point
main:	la $a0, hello
	prints
	
	la $a0, mess1	#out message for first num
    	prints
	jal get_num_as_string	#get number (Double in $f0)
	mov.d $f2, $f0
	mov.d $f12, $f2
	
next: 	jal get_operator  #get operator (res in $v0)
 	bne $v0, 0, jerror   #if unknown operation
 	la  $a0, error
 	prints
 	j next
 	
jerror: move $a0, $v0	#save operation for math
 	jal math_pr	#math procedure - depend operator
 	
 	
 	bne $a0, '=', next
 	

	# Exit the program by means of a syscall.
	# There are many syscalls - pick the desired one
	# by placing its code in $v0. The code for exit is "10"
exit:	li $v0, 10 # Sets $v0 to "10" to select exit syscall
	syscall # Exit
	
	
#####################################
#Math procedure
#$f0 - first operand
#$f2 - hold temp result
#$a0 - operation ( =, +, -, *, /  - 0 - is error)
#result -> f12		
#####################################
math_pr:	addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
    		
    		bne $a0, 0, m_op
    		j math_pr_exit
m_op:  		bne $a0, '=', m_plus    # = operation - no temp res print
 		j math_pr_exit
 		
m_plus:		bne $a0, '+', m_minus
		la $a0, mess12	#out message for second num
    		prints
    		
    		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal get_num_as_string
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		
		add.d $f2, $f2, $f0
 		mov.d $f12, $f2
 		la $a0, temp    #print Temp
 		prints
		j math_pr_exit
m_minus:	bne $a0, '-', m_mul
		la $a0, mess12	#out message for second num
    		prints
    		
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal get_num_as_string	#get number (Double in $f0)
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		
		sub.d $f2, $f2, $f0
 		mov.d $f12, $f2
 		la $a0, temp	#print Temp
 		prints	
		j math_pr_exit    		
m_mul:		bne $a0, '*', m_div
		la $a0, mess12	#out message for second num
    		prints
    		
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal get_num_as_string
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		
		mul.d $f2, $f2, $f0
 		mov.d $f12, $f2
 		la $a0, temp	#print Temp
 		prints
		j math_pr_exit    		
m_div:		bne $a0, '/', m_mod
		la $a0, mess12	#out message for second num
    		prints
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal get_num_as_string
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		div.d $f2, $f2, $f0
 		mov.d $f12, $f2
 		la $a0, temp	#print Temp
 		prints
		j math_pr_exit 

m_mod:		bne $a0, '%', m_sqrt
		la $a0, mess12	#out message for second num
    		prints
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal get_num_as_string
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		
    		l.d $f30, zero
  		c.lt.d $f0, $f30
  		bc1f 	m_mod_ok
  		la $a0, error_modulo
  		prints
  		la $a0, temp	#print Temp
 		prints
  		j math_pr_exit
m_mod_ok:    		#TODO modulo operation
		
		mov.d $f4, $f0
		
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal modulo
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
 		mov.d $f2, $f12
 		la $a0, temp	#print Temp
 		prints
		j math_pr_exit 
		
m_sqrt:		bne $a0, '$', math_pr_exit
  		l.d $f0, zero
  		c.lt.d $f2, $f0
  		bc1f 	m_sqrt_ok
  		la $a0, error
  		prints
  		la $a0, temp	#print Temp
 		prints
  		j math_pr_exit
m_sqrt_ok:    		#TODO sqrt operation
		mov.d  $f0, $f2
		
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal sqrt
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		
		mov.d $f2, $f12  #save result
	
 		la $a0, temp	#print Temp
 		prints
		j math_pr_exit  		   		
 				
math_pr_exit:	la $a0, mess_res
 		prints
    		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal print_res
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra			# Return	
#####################################
#Get double number and save to memory		
#####################################
get_num:	addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
 		
    		li $v0, 7	#get firts num (double)
    		syscall
 				
    		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra			# Return

#####################################
#Get operator and save to memory
# out $v0 - operation simbol (0 - mean error)		
#####################################
get_operator:	addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
    		
    		la $a0, mess2	#out message for first num
    		prints
    		
    		li $v0, 12	#read char
    		syscall
    		
		bne $v0, '=', go_plus
 		j jo_ex    		
    		
go_plus:	bne $v0, '+', go_minus
 		j jo_ex
go_minus: 	bne $v0, '-', go_multp	 
		j jo_ex
go_multp: 	bne $v0, '*', go_divis	 
		j jo_ex
go_divis:	bne $v0, '/', go_sqrt	 
 		j jo_ex
go_sqrt:	bne $v0, '$', go_modulo	 
 		j jo_ex
go_modulo:	bne $v0, '%', go_other	 
 		j jo_ex
go_other: 	la $a0, error
		prints
		li, $v0, 1	#error code
 				
jo_ex:   	addi $sp, $sp,-4     # Moving Stack pointer
    		sw $v0, 0($sp)      # Store previous value
		li, $a0, '\n'
    		printc
    		lw $v0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra			# Return
		
						
#####################################
#Check if string number is correct
#input: buffer
# if correct - out to $v0 = 0
# if not - out to $v0 = error code (TBD)
# output - double $f0 after check and parsing
#####################################
get_num_as_string:	addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
get_num_as_string_retry:		
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
		jal get_num_sring	#get
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		
    		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
    		jal	check_string_num
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		
    		
		bne $v0, 0, gn_fail
		
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
    		jal	parse_string_num
		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		
  		
		j get_num_as_string_end
		
gn_fail:	la $a0, mess_fail
		prints
		j get_num_as_string_retry
		
		
		
get_num_as_string_end:		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra	
		
								
																				
#####################################
#Check if string number is correct
#input: buffer
# if correct - out to $v0 = 0
# if not - out to $v0 = error code (TBD)
#####################################
check_string_num: addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $t0, 0($sp)      # Store previous value
    		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $t1, 0($sp)      # Store previous value
    		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $t2, 0($sp)      # Store previous value
    		
		la $t0, buffer
		add $v0, $zero, $zero   #v0 - check to zero
		add $t1, $zero, $zero   #t1 - position counter
		add $t2, $zero, $zero   #t2 - '.' counter
csn_loop:	lbu $a0, ($t0)     #
		beq $a0, '\0', cs_ret  #return if end of string
		beq $a0, '\n', cs_ret  #return if end of string
		bne $a0, '-', csn_not_minus
		beq $t1, 0, csn_not_minus  #if not '-'
		li $v0, 2			#if '-' not in zero position - error
		j cs_ret
csn_not_minus:	bne $a0, '.', csn_not_point
		addi $t2, $t2, 1
		blt $t2, 2, csn_not_point
		li $v0, 3			#if more of 1 '.' - error
		j cs_ret
csn_not_point:	addi $sp, $sp,-4     # Moving Stack pointer
    		sw $ra, 0($sp)      # Store previous value
    		jal check_char
    		lw $ra, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		
    		bnez $v0, cs_ret	#if char is fail - exit
    		addi $t0, $t0, 1	#next char
    		addi $t1, $t0, 1
    		j csn_loop
    		
cs_ret:    	lw $t2, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer
		lw $t1, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
    		lw $t0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra	

#####################################
#Parse string to double
#input: buffer
# out: $f0
#####################################
parse_string_num:     addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $t0, 0($sp)      # Store previous value
    		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $t1, 0($sp)      # Store previous value
    		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $t2, 0($sp)      # Store previous value
		l.d $f20, zero	#load zero to $f20
		l.d $f22, ten	#load 10 to $f22
		la $t0, buffer
		lb $t1, ($t0)	#load char
		bne $t1, '-', parse_next  #if correct string should work only on first
		li $t2, 'n'	#negative sign
		addi $t0, $t0, 1  #next char
parse_next:	lb $t1, ($t0)	#load char
		beq $t1, '\n', parse_exit  #end of string
		beq $t1, '\0', parse_exit	#end of string
		beq $t1, '.', parse_fract_part
		mul.d $f20, $f20, $f22	# f20 = f20 * 10 
		subi $t1, $t1, 48	#convert char to int
		mtc1.d $t1, $f24		#move $t1 to coprocessor
  		cvt.d.w $f24, $f24
		add.d $f20, $f20, $f24	#f20 = f24 + f20
		addi $t0, $t0, 1	#next char
		j parse_next	
parse_fract_part:  	
		addi $t0, $t0, 1
		div.d $f26, $f22, $f22	#f26 = 1
parse_fract_next:
		div.d $f26, $f26, $f22 	# f26 = f26 / 10
		lb $t1, ($t0)	#load char
		beq $t1, '\n', parse_exit  #end of string
		beq $t1, '\0', parse_exit	#end of string
		subi $t1, $t1, 48	#convert char to int
		mtc1.d $t1, $f24		#move $t1 to coprocessor
		cvt.d.w $f24, $f24
		mul.d $f24, $f24, $f26 
		add.d $f20, $f20, $f24
		addi $t0, $t0, 1   #next char      		
		j   parse_fract_next		  		  		
parse_exit: 	bne $t2, 'n', parse_exit2
		neg.d $f20, $f20
parse_exit2:	mov.d $f0, $f20
		lw $t2, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		lw $t1, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		lw $t0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra	

#####################################
#Check if chars in number is correct
#input: $a0 - char
# if correct - out to $v0 = 0
# if not - out to $v0 = error code (TBD)
#####################################
check_char:     addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
		add $v0, $zero, $zero
		blt $a0, '0', cc_not_num	#check if less then '0'
		bgt $a0, '9', cc_not_num        #check if great then '9'
		j check_char_exit
cc_not_num:	beq $a0, '.', check_char_exit
		beq $a0, '-', check_char_exit
 		addi $v0, $zero, 1    		
check_char_exit: lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra	

#####################################
#Get string of number
# result saved to 'buffer'
#####################################
get_num_sring:	addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
    		addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a1, 0($sp)      # Store previous value
    		
		li $a1, LIMIT		#set max limit of chars
		la $a0, buffer		#set input buffer
		
		li $v0, 8		#get sting
		syscall
		
		lw $a1, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 		
    		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra	

#####################################
#Print results of calculation
#input: $f12 - result
#####################################
print_res:	addi $sp, $sp,-4     # Moving Stack pointer
    		sw $a0, 0($sp)      # Store previous value
    		
    		printd		#double print
    		
    		li, $a0, '\n'
    		printc
    				
    		lw $a0, 0($sp)      	# Load previous value
    		addi $sp,$sp,4      	# Moving Stack pointer 
		jr $ra	

#####################################
#Sqrt
#input: $f0
# output $f12
#####################################		
sqrt:	addi $sp, $sp,-4     # Moving Stack pointer
    	sw $a0, 0($sp)      # Store previous value
    	l.d	$f2, zero	# $f2 = LOW = 0
    	c.eq.d	$f0, $f2
    	bc1f	sqrt_cont   # branch if not zero 
    	mov.d $f12, $f0
    	lw $a0, 0($sp)      	# Load previous value
    	addi $sp,$sp,4      	# Moving Stack pointer 
    	jr $ra
    	
    	
sqrt_cont: 
	l.d $f16, accuracy
	mov.d $f4, $f0	#hold num
	l.d $f6, zero	# LOW
	mov.d $f8, $f4  # HIGH
	l.d $f12, num2
	
	#R^2 calc:
sqrt_next:
	add.d $f10, $f6, $f8     # R = L + H
	div.d $f14, $f10, $f12   # R = R / 2
	mul.d $f10, $f14, $f14  # R^2
	
	sub.d $f18, $f4, $f10  #delta = NUM - R^2
	abs.d $f18, $f18
	c.lt.d $f18, $f16     #compare with accuracy
	bc1t   sqrt_exit
	
	c.eq.d $f4, $f10	#if equel
	bc1t   sqrt_r2_less
	c.lt.d $f4, $f10	#if num less R^2 -> 
	bc1f   sqrt_r2_less
sqrt_r2_eq:	mov.d  $f8, $f14	#r^2 great or eq from NUM -> H = R; L = 0
	b 	sqrt_next
sqrt_r2_less:
	mov.d $f6, $f14	
	b 	sqrt_next
sqrt_exit:
	mov.d   $f12, $f14
	lw 	$a0, 0($sp)
	addi	$sp, $sp, 4
	jr $ra
	
#####################################
#modulo
#	input: $f2 % $f4 (should be positive)
# output $f12
#####################################		
modulo:	addi $sp, $sp,-4     # Moving Stack pointer
    	sw $a0, 0($sp)      # Store previous value
	l.d $f0, zero
	
	c.lt.d $f2, $f4
	bc1t mod_f2_ret	#if f2 great then f4 -> send f2
	
  	div.d $f14, $f2, $f4  #1. divide
  	cvt.w.d     $f16, $f14             # now f16 will have int part
  	cvt.d.w    $f16, $f16
  	sub.d $f14, $f14, $f16		# .part
  	mul.d $f12, $f14, $f4       #modulo .partof(f2 / f4) * f4
	j mod_ex
mod_f2_ret: 
	mov.d $f12, $f2
	
mod_ex:	lw 	$a0, 0($sp)
	addi	$sp, $sp, 4
	jr $ra
