.text
modifymatrix:
	li.s $f16 0 # We will use this later on
    
# First, we will move the arguments to temporal registers:
	move $t0 $a0 # Moves the first argument (A[][]) to register t0
    move $t1 $a1 # Moves the second argument (M) to register t1
    move $t2 $a2 # Moves the third argument (N) to register t2
    move $t3 $a3 # Moves the fourth argument (i) to register t3
    lw $s0 4($sp) # int j, drawn from the stack
    move $t4 $s0 # Moves the fifth argument (j) to register t4
    
# Checking for errors:
	blez $t1 error # If M is less than or equal to zero, an error occurs
    blez $t2 error # If N is less than or equal to zero, an error occurs
    bltz $t3 error # If i is less than zero, an error occurs (i is out of the matrix range)
    bge $t3 $t1 error # If i is greater than M-1, an error occurs (i is out of the matrix range)
	bltz $t4 error # If j is less than zero, an error occurs (j is out of the matrix range)
    bge $t4 $t2 error # If j is greater than N-1, an error occurs (j is out of the matrix range)
    
# Searching for the element A_ij:
	# We will use the formula "init_address + (i * n + j) * p"
    mul $t5 $t3 $t2 # i * n
    add $t5 $t5 $t4 # i * n + j
    mul $t5 $t5 4 # (i * n + j) * p, p is the size of a float (4)
    l.s $f4 A($t5) # Loads A_ij in the float register f4
    
    sub $t1 $t1 1 # The indexes start at (0,0)
    
 	jal loop
    
    row:
    	beq $t6 $t1 result # If we have finished the last row we go to the results
    	addi $t6 $t6 1 # Since we have finished a row, we go to the next one...
    	li $t7 0 # ...and reset j
    
    	jal loop # Let's go back to the loop
    
    loop:
    # We will use the formula "init_address + (i * n + j) * p"
    	mul $t5 $t6 $t2 # i * n
    	add $t5 $t5 $t7 # i * n + j
    	mul $t5 $t5 4 # (i * n + j) * p, p is the size of a float (4 bytes, 32 bits)
    	l.s $f5 A($t5) # Loads A_ij in the float register f4
        
    	addi $t7 $t7 1 # Next position
        
        mfc1 $t8 $f5 # We move the float we are currently looking at to t8
        
        li $s0, 0x7F800000 # Magic number to get the exponent
		and $t9, $t8, $s0
		srl $t9, $t9, 23 # Save the exponent in t9
        
        li $s0, 0x007FFFFF # Magic number to get the mantissa
		and $s1, $t8, $s0 # Save the mantissa in s1
        
        bnez $s1 exponent # If the mantissa is different from zero, we are interested in this number
        
    	bne $t7 $t2 loop # If we are not at the end of the row, we start the loop again
    	jal row # If we have finished the row, we go to the next one
    
    exponent:
    	beqz $t9 notnormalized
        beq $t9 255 setzero                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
        
    notnormalized:
    	s.s $f4 A($t5) # Changes the value of the memory address of this cell to A_ij
        
        bne $t7 $t2 loop # If we are not at the end of the row, we start the loop again
    	jal row # If we have finished the row, we go to the next one
    
    setzero:
    	li.s $f16 0
    	s.s $f16 A($t5) # Changes the value of the memory address of this cell to 0
        
        bne $t7 $t2 loop # If we are not at the end of the row, we start the loop again
    	jal row # If we have finished the row, we go to the next one
        
    error:
    	li $v0 -1 # Returns error code -1 if an error has occured
        jal end # We stop the function from doing any other tasks
        
    result:
    	li $v0 0 # Returns success code 0
        jal end
  
    end:
    	li $ra -1
        jr $ra