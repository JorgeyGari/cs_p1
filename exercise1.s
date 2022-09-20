.text
arraycompare: 
# First, we move the arguments a0-a3 to registers t0-t3
	move $t0 $a0 # int A[]
    move $t1 $a1 # int N
    move $t2 $a2 # int x
    move $t3 $a3 # int i
    
    ble $t1 $zero error # If N is not positive, an error occurs
    ble $t3 $zero error # If i is not positive, an error occurs
        
	li $t4 0 # Position of the array we are currently looking at
	
    loop:
        beq $t4 $t1 result # If we have reached the end of the vector, we stop the loop and get the results
        
        sub $t5 $t7 $s2 # Value of i in the formula "init_address + (i * n + j) * p" for finding the element a_ij
        mul $t5 $t1 $t5 # Value of (i*n) in the formula
        add $t5 $t5 $t4 # Value of (i*n+j) in the formula
        mul $t5 $t5 4 # Value of (i * n + j) * p in the formula, 4 is the size of an integer (a word), we store the address in t5
        
		lw $t6 A($t5) # We load the integer in position t5 of the array in t6
        addi $t4 $t4 1 # Next position
        
        move $a0 $t6 # We load t6 into the first argument register a0
        move $a1 $t2 # We load t2 (x) into the second argument register a1
        jal cmp # We invoke the function cmp and feed it the two arguments
        move $a1 $t1 # To pass the argument correctly
        
        beq $v0 1 match # If there is a match, cmp will return a 1, we jump to branch match
        beqz $v0 mismatch # If there is no match, cmp will return a 0, we jump to branch mismatch
    
    match:
    	addi $t8 $t8 1 # t8 will count the number of match instances
        beq $t8 $t3 sequence # If t8 reaches t3 (i), it is considered a sequence (a success)
        jal loop # Go back to the loop
        
    sequence:
    	addi $t9 $t9 1 # t9 counts the number of sequences (successes)
        jal loop  # Go back to the loop
        
    mismatch:
    	li $t8 0 # If there is no match, we can reset the counter
        jal loop # Go back to the loop
    
    error:
    	li $v0 -1 # Load error code -1 into the first value the function returns
        li $ra -1 # Ends the function
        
		jr $ra
	
	result:
    	li $v0 0 # Load success code 0 into the first value the function returns
        move $v1 $t9 # Load the value of t9 (number of sequences) into the second value the function returns
        
        beqz $s2 end # In arraycompare, s2 is not declared, so it is zero and will end after one iteration.
		beq $s2 1 end # If we are calling arraycompare as a part of matrixcompare, s2 is not 1 unless we are in the last row...
        
		jal row #...and we have to go back to the row loop.
    
    end:       
        li $ra -1 # Ends the function
    	jr $ra
        
matrixcompare: 
# First, we move the arguments a0-a3 to registers t0-t3
    move $t7 $a1 # int M
    ble $t7 $zero error # If M is not positive, an error occurs

    lw $s0 4($sp) # int i, drawn from the stack
    
    move $t3 $s0 # Move the value drawn from the stack to t3 for the sake of simplicity
    
# Move the arguments that arraycompare needs to the argument registers
	move $a1 $a2
    move $a2 $a3
    move $a3 $s0 # int i
    
    addi $s2 $t7 1 # s2 will count the ammount of times we invoke arraycompare (i.e.: the number of rows of the matrix)
    # One is added to adjust for the counting, so the program does all of the rows
    
    row:
    	beq $s2 1 result # If we have done this M times, we are finished
        sub $s2 $s2 1 # We have finished one of the rows, one less to go
		li $t8 0 # Resets the counter of occurrences
    	jal arraycompare # Invoke the function arraycompare and feed it the four arguments it needs