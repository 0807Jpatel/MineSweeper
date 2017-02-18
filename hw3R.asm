##############################################################
# Homework #3
# name: Jaykumar Patel
# sbuid: 110255934
##############################################################
.text

.macro printSmiley(%regester)
	sb $t1, (%regester)
	sb $t2, 1(%regester)
.end_macro

.macro addOneToCell()
	li $t4, 10
    	mul $t4, $a0, $t4
    	add $t4, $t4, $a1
    	add $t8, $t4, $a2
    	lb $t0, ($t8)
    	addi $t0, $t0, 1
    	sb $t0, ($t8)
.end_macro

.macro ChangeCursorColor()
    	lw $t0, cursor_row
    	lw $t1, cursor_col
    	li $t2, 10
    	mul $t2, $t2, $t0
    	add $t2, $t2, $t1
    	li $t1, 2
    	mul $t2, $t2, $t1		#positions in MMIO
    	addi $t2, $t2, 0xffff0000
    	addi $t2, $t2, 1
    	lb $t0, ($t2)
    	andi $t0, $t0, 0x0f
    	li $t1, 0xb0
    	or $t0, $t0, $t1
    	sb $t0, ($t2)  	
.end_macro

.macro addToStack()
	bltz $t0, skipToEnd
	bltz $t1, skipToEnd
	bgt $t0, 9, skipToEnd
	bgt $t1, 9, skipToEnd
	
	li $t2, 10
	mul $t2, $t2, $t0
	add $t2, $t2, $t1
	add $t2, $t2, $a0
	lb $t3, ($t2)
	andi $t3, $t3, 64
	beq $t3, 64, skipToEnd
	lb $t3, ($t2)
	andi $t3, $t3, 16
	beq $t3, 16, skipToEnd
	addi $sp, $sp, -8
	sw $t0, ($sp)
	sw $t1, 4($sp)			
	
	skipToEnd:
.end_macro



##############################
# PART 1 FUNCTIONS
##############################

smiley:
    #Define your code here
    	la $s0, 0xffff0000
    	
    	li $t0, 0	#counter
    	reset_for_loop:
    		li $t1, '\0'
    		sb $t1, ($s0)
    		addi $s0, $s0, 1
    		li $t1, 0x0f
    		sb $t1, ($s0)    		
    		addi $s0, $s0, 1
    		addi $t0, $t0, 1
    		beq $t0, 100, done
    		j reset_for_loop
    	
    	done:
    	la $s0, 0xffff0000
    	li $t1, 'B'
    	li $t2, 0xB7
    	addi $s0, $s0, 46
    	printSmiley($s0)
    	addi $s0, $s0, 6
    	printSmiley($s0)
    	addi $s0, $s0, 14
    	printSmiley($s0)
    	addi $s0, $s0, 6
    	printSmiley($s0)
    	li $t1, 'E'
    	li $t2, 0x1F
    	addi $s0, $s0, 52
    	printSmiley($s0)
    	addi $s0, $s0, 10
    	printSmiley($s0)
    	addi $s0, $s0, 12
    	printSmiley($s0)
    	addi $s0, $s0, 6
    	printSmiley($s0)
    	addi $s0, $s0, 16
    	printSmiley($s0)
    	addi $s0, $s0, 2
    	printSmiley($s0)
    	
	jr $ra


##############################
# PART 2 FUNCTIONS
##############################

open_file:
   	li $a1, 0
   	li $a2, 0
   	li $v0, 13
   	syscall
    jr $ra

close_file:
	li $v0, 16
	syscall
    jr $ra

load_map:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $ra, 4($sp)
	sw $s1, 8($sp)
	move $s0, $a1
	
	#reset everything to 0 in cells_array
	li $t0, 0
    	forloop_reset_space:
    		sb $0, ($a1)
    		addi $a1, $a1, 1
    		addi $t0, $t0, 1
    		beq $t0, 100, done_reset_space
    		j forloop_reset_space
    	done_reset_space:
    	  
    	li $t0, 0 		#counter for number of bombs  
    	la $a1, buffer
    	li $a2, 1  	
    	li $s1, '0' 	
    	while_loop_read_bomb:
    		move $t3, $s0
    		innerwhile_loop_filereading:
    			li $v0, 14
    			syscall
    			beqz $v0, endoffile 
    			lb $t7, ($a1)
    			beq $t7, ' ', fine1
    			beq $t7, '\n', fine1
    			beq $t7, '\t', fine1
    			beq $t7, '\r', fine1
    			sub $t7, $t7, $s1
    			blt $t7, $0, invalidreturn
    			bgt $t7, 9, invalidreturn 
    			j firstnumber
    			fine1:
    			j innerwhile_loop_filereading
    		firstnumber:
    		
    		for_loop_first_number_leading:
    			li $v0, 14
    			syscall
    			beqz $v0, invalidreturn 
    			lb $t4, ($a1)
    			beq $t4,' ', startnumber2
    			beq $t4,'\n', startnumber2
    			beq $t4,'\t', startnumber2
    			beq $t4,'\r', startnumber2
    			sub $t4, $t4, $s1
    			blt $t4, $0, invalidreturn
    			bgt $t4, 9, invalidreturn
    			li $t5, 10
    			mul $t7, $t7, $t5
    			add $t7, $t7, $t4
    			j for_loop_first_number_leading
   		startnumber2:
   		bgt $t7, 9, invalidreturn
   		
   		innerwhile_loop_filereading2:
    			li $v0, 14
    			syscall
    			beqz $v0, invalidreturn
    			lb $t8, ($a1)
    			beq $t8, ' ', fine2
    			beq $t8, '\n', fine2
    			beq $t8, '\t', fine2
    			beq $t8, '\r', fine2
    			sub $t8, $t8, $s1
    			blt $t8, $0, invalidreturn
    			bgt $t8, 9, invalidreturn 
    			j secondnumber
    			fine2:
    			j innerwhile_loop_filereading2   
   		secondnumber: 
   		for_loop_second_number_leading:
    			li $v0, 14
    			syscall
    			beqz $v0, startnumber3 
    			lb $t4, ($a1)
    			beq $t4,' ', startnumber3
    			beq $t4,'\n', startnumber3
    			beq $t4,'\t', startnumber3
    			beq $t4,'\r', startnumber3
    			sub $t4, $t4, $s1
    			blt $t4, $0, invalidreturn
    			bgt $t4, 9, invalidreturn
    			li $t5, 10
    			mul $t8, $t8, $t5
    			add $t8, $t8, $t4
    			j for_loop_second_number_leading
    		startnumber3:	
    		bgt $t8, 9, invalidreturn
    		#t7  is row and t8 is the col
    		#adds the bomb to the space
    		li $t6, 10
		mul $t7, $t7, $t6
		add $t8, $t8, $t7
		add $t3, $t3, $t8
		lb $t1, ($t3)
		li $t4, 32
		beq $t1, $t4, skipaddingbomb	#checks if it is repeat
			addi $t1, $0, 32
			sb $t1, ($t3)
			addi $t0, $t0, 1
		skipaddingbomb:
    		j while_loop_read_bomb
    	endoffile:
 	blez $t0, invalidreturn
 	bgt  $t0, 99, invalidreturn 
    	
    	sw $t0, num_bomb
    	
    	
    	#algorithm for counting how many bombs around the tile (+1 to all 8 tiles around the bomb)
    	li $t0, 0	# row counter    	
    	for_rowCounter:
    		beq $t0, 10, done_for_rowCounter
    		li $t1, 0		#inner Counter colums
    		for_columCounter:
    			beq $t1, 10, done_for_columCounter
    			move $t3, $s0
    			li $t4, 10
    			mul $t4, $t0, $t4
    			add $t4, $t4, $t1
    			add $t3, $t3, $t4
    			
    			lb $t4, ($t3)
    			andi $t4, $t4, 32
    			bne $t4, 32, notABomb			#its a bomb
    				addi $sp, $sp, -8
    				sw $t0, ($sp)
    				sw $t1, 4($sp)
    				
    				move $a0, $t0
    				move $a1, $t1
    				move $a2, $s0
    				jal addOneAllNeighbours
    				
    				lw $t0, ($sp)
    				lw $t1, 4($sp)
    				addi $sp, $sp, 8
    			notABomb:    		
    				addi $t1, $t1, 1
    			j for_columCounter
    		done_for_columCounter:
    		addi $t0, $t0, 1
    		j for_rowCounter
    	done_for_rowCounter: 	 	 	 	 	
    	
    	move $a1, $s0
    	li $t0, 0
    	forloop_bombnumber:
    		lb $t1, ($a1)
    		andi $t2, $t1, 32
    		bne $t2, 32, dontreset
    			andi $t1, $t1, 112
    			sb $t1, ($a1)
    		dontreset:
    		addi $a1, $a1, 1
    		addi $t0, $t0, 1
    		beq $t0, 100, done_resetbombnumber
    		j forloop_bombnumber
    	done_resetbombnumber:  
    	
    	#set cursor to 0 0 
    	la $t0, cursor_row
    	li $t1, 0
    	sw $t1, ($t0)
    	
    	la $t0, cursor_col
    	li $t1, 0
    	sw $t1, ($t0)
    	    						
    	li $v0, 0
    	j return
    	invalidreturn:
    			
    	li $v0, -1
    	return:
    	lw $s1, ($sp)
    	lw $s0, ($sp)
    	lw $ra, 4($sp)
    	addi $sp, $sp, 12
    jr $ra

##############################
# PART 3 FUNCTIONS
##############################

init_display:
   	li $t0, 0	#counter
   	la $t8, 0xffff0002
    	reset_for_loop1:
    		li $t1, '\0'
    		sb $t1, ($t8)
    		addi $t8, $t8, 1
    		li $t1, 0x77
    		sb $t1, ($t8)    		
    		addi $t8, $t8, 1
    		addi $t0, $t0, 1
    		beq $t0, 100, done1 
    		j reset_for_loop1
    	done1:
    	
    	lw $t0, cursor_row
    	lw $t1, cursor_col
    	li $t2, 10
    	mul $t0, $t0, $t2
    	add $t1, $t1, $t0
    	li $t2, 2
    	mul $t0, $t1, $t2
    	
    	addi $t8, $t0, 0xffff0000
    	addi $t8, $t8, 1
    	lb $t1, ($t8)
    	andi $t1, $t1, 0x0f
    	ori $t1, $t1, 0xb0
    	sb $t1, ($t8) 	
    	
    	
    jr $ra

set_cell:
   	lw $t0, ($sp)
  	bltz $a0, return_invalid_set_cell
   	bgt $a0, 9, return_invalid_set_cell
    	bltz $a1, return_invalid_set_cell
    	bgt $a1, 9, return_invalid_set_cell
    	bltz $a3, return_invalid_set_cell
    	bgt $a3, 15, return_invalid_set_cell
    	bltz $t0, return_invalid_set_cell
    	bgt $t0, 15, return_invalid_set_cell
	
	sll $t0, $t0, 4
	add $t0, $t0, $a3
	
	li $t1, 10
	mul $t1, $a0, $t1
	add $t1, $t1, $a1
	li $t2, 2
	mul $t1, $t1, $t2
	  
	addi $t2, $t1, 0xffff0000
    	sb $a2, ($t2)
    	addi $t2, $t2, 1
    	sb $t0, ($t2)   
    	li $v0, 0
    	jr $ra
    	return_invalid_set_cell:
    		li $v0, -1
    		jr $ra

reveal_map:
    addi $sp, $sp, -8
    sw $ra, ($sp)
    sw $s0, 4($sp)
    beqz $a0, return_reveal_map
    bne $a0, 1, lostGame
    jal smiley
    j return_reveal_map
    lostGame: 
    
    li $t0, 0
    for_loop_reveal:
    	beq $t0, 100, done_for_loop_reveal
    	lb $t1, ($a1)
    	andi $t2, $t1, 64
    	beq $t2, 64, already_revelead
    		andi $t2, $t1, 32
    		bne $t2, 32, notBomb
    			andi $t2, $t1, 16
    			beq $t2, 16, CorrectFlag
    				li $t3, 2
  				mul $t3, $t0, $t3
  				addi $t3, $t3, 0xffff0000
  				li $t2, 'B'
  				sb $t2, ($t3)
  				addi $t3, $t3, 1
  				li $t2, 0x07
  				sb $t2, ($t3)	
  				j already_revelead	
    			CorrectFlag:
    				li $t3, 2
    				mul $t3, $t0, $t3
    				addi $t3, $t3, 0xffff0000
    				li $t2, 'F'
    				sb $t2, ($t3)
    				addi $t3, $t3, 1
    				li $t2, 0xAC
    				sb $t2, ($t3)    
    				j already_revelead	
    		notBomb:
    		andi $t2, $t1, 16
    		beq $t2, 16, FlagAtNumber
    			andi $t2, $t1, 15
    			bnez $t2, notZeroSoNumber
    				li $t3, 2
  				mul $t3, $t0, $t3
  				addi $t3, $t3, 0xffff0000
  				li $t2, '\0'
  				sb $t2, ($t3)
  				addi $t3, $t3, 1
  				li $t2, 0x0f
  				sb $t2, ($t3)
    			j already_revelead
    			notZeroSoNumber:
    			addi $t2, $t2, '0'
  			li $t3, 2
  			mul $t3, $t0, $t3
  			addi $t3, $t3, 0xffff0000
  			sb $t2, ($t3)
  			addi $t3, $t3, 1
  			li $t2, 0x0d
  			sb $t2, ($t3)
  			j already_revelead
  		FlagAtNumber:
  			li $t3, 2
    			mul $t3, $t0, $t3
    			addi $t3, $t3, 0xffff0000
    			li $t2, 'F'
    			sb $t2, ($t3)
    			addi $t3, $t3, 1
    			li $t2, 0x9C
    			sb $t2, ($t3) 
    			j already_revelead
    		
    	already_revelead:  
    	
    	addi $a1, $a1, 1
    	addi $t0, $t0, 1
    	j for_loop_reveal    	
    done_for_loop_reveal:
    
    lw $t3, cursor_row
    lw $t1, cursor_col
    li $t2, 10
    mul $t3, $t3, $t2
    add $t1, $t1, $t3
    li $t2, 2
    mul $t3, $t1, $t2
    addi $t8, $t3, 0xffff0000
    li $t1, 'E'
    sb $t1, ($t8)
    addi $t8, $t8, 1
    li $t1, 0x9f
    sb $t1, ($t8)   
    
    return_reveal_map:
    lw $ra, ($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra


##############################
# PART 4 FUNCTIONS
##############################

perform_action:
    addi $sp, $sp, -4
    sw $ra, ($sp)


    beq $a1, 'w', itsw
    beq $a1, 'W', itsw
    j notW
    itsw:
    lw $t0, cursor_row
    beqz $t0, invalidInput
    j itsMoveCursor    
    notW:   
    beq $a1, 's', itss
    beq $a1, 'S', itss
    j notS
    itss:
    lw $t0, cursor_row
    beq $t0, 9, invalidInput
    j itsMoveCursor    
    notS:  
    beq $a1, 'd', itsd
    beq $a1, 'D', itsd  
    j notD
    itsd:
    lw $t0, cursor_col
    beq $t0, 9, invalidInput
    j itsMoveCursor    
    notD: 
    beq $a1, 'a', itsa
    beq $a1, 'A', itsa
    j notA
    itsa:
    lw $t0, cursor_col
    beqz $t0, invalidInput
    j itsMoveCursor    
    notA:
    j notMoveCursor
    itsMoveCursor:
    	lw $t0, cursor_row
    	lw $t1, cursor_col
    	li $t2, 10
    	mul $t2, $t2, $t0
    	add $t2, $t2, $t1	#position at the array
    	add $t3, $t2, $a0	#load to check if it is rev or not
    	lb $t4, ($t3)
    	andi $t4, $t4, 64
    	beq $t4, 64, revled
    		li $t4, 2
    		mul $t4, $t4, $t2
    		addi $t4, $t4, 0xffff0000	#position in MMIO
    		addi $t4, $t4, 1		#skip the char byte
    		lb $t2, ($t4)			#get color byte
    		andi $t2, $t2, 0x0f		#get only forground color of cursor
    		li $t3, 0x70			#add gray color in background position
    		or $t3, $t3, $t2		#combine them together
    		sb $t3, ($t4)			#changed the color back to what it was 	
    		J ChangeNextPositionColor
    	revled:    	
    		li $t4, 2
    		mul $t4, $t4, $t2
    		addi $t4, $t4, 0xffff0000	#position in MMIO
    		addi $t4, $t4, 1		#skip the char byte
    		lb $t2, ($t4)			#get color byte
    		andi $t2, $t2, 0x0f		#get only forground color of cursor
    		li $t3, 0x00			#add gray color in background position
    		or $t3, $t3, $t2		#combine them together
    		sb $t3, ($t4)			#changed the color back to what it was 	
    		J ChangeNextPositionColor    
    	ChangeNextPositionColor:
    		#check for what letter was it to make it cursor change accord
		beq $a1, 'w', moveUP
    		beq $a1, 'W', moveUP
    		j notMoveUP
    		moveUP:
    			beqz $t0, DontMoveCursorUP
    				addi $t0, $t0, -1
    			DontMoveCursorUP:	
    			sw $t0, cursor_row
    			j return_perform_action
    		notMoveUP:
    		beq $a1, 's', moveDOWN
    		beq $a1, 'S', moveDOWN
    		j notMoveDOWN
    		moveDOWN:
    			beq $t0, 9, DontMoveCursorDOWN
    				addi $t0, $t0, 1
    			DontMoveCursorDOWN:
    			sw $t0, cursor_row
    			j return_perform_action
    		notMoveDOWN:
    		beq $a1, 'd', moveRIGHT
    		beq $a1, 'D', moveRIGHT
    		j notMoveRIGHT
    		moveRIGHT:
    			beq $t1, 9, DontMoveCursorRIGHT
    				addi $t1, $t1, 1
    			DontMoveCursorRIGHT:
    			sw $t1, cursor_col
    			j return_perform_action
    		notMoveRIGHT:
    			beq $t1, 0, DontMoveCursorLEFT
    				addi $t1, $t1, -1
    			DontMoveCursorLEFT:
    			sw $t1, cursor_col
    			j return_perform_action    		
    notMoveCursor:
    beq $a1, 'f', ToggleFlag
    beq $a1, 'F', ToggleFlag
    j notToggleFlag
    ToggleFlag:
    	lw $t0, cursor_row
    	lw $t1, cursor_col
    	li $t2, 10
    	mul $t2, $t2, $t0
    	add $t2, $t2, $t1	#position at the array
    	add $t3, $t2, $a0	#to check if it is flagged or not
    	lb $t4, ($t3)  
    	andi $t5, $t4, 64
    	beq $t5, 64, invalidInput    	
    	andi $t5, $t4, 16
    	beq $t5, 16, removeFlag
    		andi $t5, $t4, 32
    		bne $t5, 32, wrongFlag
    			lw $t6, bomb_clear
    			addi $t6, $t6, 1
    			sw $t6, bomb_clear
    			j countbombdone
    		wrongFlag:
    			lw $t6, wrong_bomb
    			addi $t6, $t6, 1
    			sw $t6, wrong_bomb
    			j countbombdone
    		countbombdone:
    		addi $t4, $t4, 16
    		sb $t4, ($t3)
    		move $a0, $t0
    		move $a1, $t1
    		li $a2, 'f'
    		li $a3, 0xc
    		li $t0, 0x7
    		addi $sp, $sp, -8
    		sw $ra, 4($sp)		
    		sw $t0, ($sp)
    			jal set_cell
    		lw $t0, ($sp)
    		lw $ra, 4($sp)
    		addi $sp, $sp, 8
    		j return_perform_action
    		
    	removeFlag:
    		andi $t5, $t4, 32
    		bne $t5, 32, wrongFlag2
    			lw $t6, bomb_clear
    			addi $t6, $t6, -1
    			sw $t6, bomb_clear
    			j countbombdone2
    		wrongFlag2:
    			lw $t6, wrong_bomb
    			addi $t6, $t6, -1
    			sw $t6, wrong_bomb
    			j countbombdone2
    		countbombdone2:
    		addi $t4, $t4, -16
    		sb $t4, ($t3)
    		move $a0, $t0
    		move $a1, $t1
    		li $a2, '\0'
    		li $a3, 0x7
    		li $t0, 0x7
    		addi $sp, $sp, -8
    		sw $ra, 4($sp)		
    		sw $t0, ($sp)
    			jal set_cell
    		lw $t0, ($sp)
    		lw $ra, 4($sp)
    		addi $sp, $sp, 8
    		j return_perform_action
    notToggleFlag:
    beq $a1, 'r', RevealCell
    beq $a1, 'R', RevealCell
    j invalidInput
    RevealCell:
    	move $t8, $a0
    	lw $t0, cursor_row
    	lw $t1, cursor_col
    	li $t2, 10
    	mul $t2, $t2, $t0
    	add $t2, $t2, $t1	#position at the array
    	add $t3, $t2, $a0	#to check if its is already rev
    	lb $t4, ($t3)  
    	andi $t5, $t4, 64
    	beq $t5, 64, invalidInput
    		andi $t5, $t4, 16
    		beqz $t5, itWasntFlaged
    			andi $t4, $t4, 0xEF		#remove the flag if there was any
    			sb $t4, ($t3)
    			andi $t5, $t4, 32
    			bne $t5, 32, wrongFlag3
    				lw $t6, bomb_clear
    				addi $t6, $t6, -1
    				sw $t6, bomb_clear
    				j countbombdone3
    			wrongFlag3:
    				lw $t6, wrong_bomb
    				addi $t6, $t6, -1
    				sw $t6, wrong_bomb
    				j countbombdone3
    			countbombdone3:
    		itWasntFlaged:    		
    		andi $t5, $t4, 32
    		bne $t5, 32, notBombRev
    			lw $t6, revel_bomb
    			addi $t6, $t6, -1
    			sw $t6, revel_bomb
    			j return_perform_action
    		notBombRev:
    		move $a0, $t0
    		move $a1, $t1
    		andi $t4, $t4, 0xf
    			bnez $t4, notZeroRev
    				li $a2, '\0'
    				addi $sp, $sp, -4
    				sw $ra, ($sp)   		
    					move $a0, $t8
    					move $a1, $t0
    					move $a2, $t1
    					jal search_cells
    				lw $ra, ($sp)
    				addi $sp, $sp, 4
    				j return_perform_action
    		notZeroRev: 
    		addi $a2, $t4, '0'
    		ori $t4, $t4, 64
    		sb $t4, ($t3)
    		zeroRev: 	
    		li $a3, 0xd
    		li $t0, 0x0
    		addi $sp, $sp, -8
    		lw $ra, 4($sp)	
    		sw $t0, ($sp)
    			jal set_cell
    		lw $t0, ($sp)
    		lw $ra, 4($sp)
    		addi $sp, $sp, 8
    		j return_perform_action
    return_perform_action:
    ChangeCursorColor
    lw $ra, ($sp)
    addi $sp, $sp, -4
    li $v0, 0
    jr $ra
    invalidInput:
    lw $ra, ($sp)
    addi $sp, $sp, -4
    li $v0, -1
    jr $ra

game_status:
    lw $t0, revel_bomb
    bltz $t0, game_lost
    
    lw $t0, bomb_clear
    lw $t1, wrong_bomb
    lw $t2, num_bomb
    bnez $t1, game_ongoing
    beq $t0, $t2, game_won    
    
    j game_ongoing
    	
    game_won:
    	li $v0, 1
    	jr $ra
    
    game_lost:
    	li $v0, -1
    	jr $ra
    	
    game_ongoing:
    	li $v0, 0
    	jr $ra

##############################
# PART 5 FUNCTIONS
##############################

search_cells:
    move $fp, $sp
    addi $sp, $sp, -8
    sw $a1, ($sp)
    sw $a2, 4($sp)
    
    while_search_cell:
    beq $fp, $sp, done_search_cells
    	lw $t0, ($sp)	#row
    	lw $t1, 4($sp)	#col
    	addi $sp, $sp, 8
    	
    	li $t2, 10
    	mul $t2, $t2, $t0
    	add $t2, $t2, $t1
    	add $t2, $t2, $a0
    	lb $t3, ($t2)
    	andi $t5, $t3, 16
    	beq $t5, 16, itsFlagged
    		addi $sp, $sp, -20
    		sw $a0, 16($sp)
    		sw $ra, 12($sp)
    		sw $t2, 8($sp)
    		sw $t1, 4($sp)		
    		sw $t0, ($sp)
    		ori $t3, $t3, 64
    		sb $t3, ($t2)
    		move $a0, $t0
    		move $a1, $t1
    		andi $t3, $t3, 0xf
    			bnez $t3, notZeroRev2
    				li $a2, '\0'
    				li $a3, 0xf
    			addi $sp, $sp, -4
    				li $t8, 0x0
    				sw $t8, ($sp)
    				jal set_cell
    				lw $t8, ($sp)
    			addi $sp, $sp, 4
    			lw $a0, 16($sp)
    			lw $ra, 12($sp)
    			lw $t2, 8($sp)
    			lw $t1, 4($sp)		
    			lw $t0, ($sp)
    			addi $sp, $sp, 20
    			j itsFlagged
    		notZeroRev2: 
    		addi $a2, $t3, '0'
    		li $a3, 0xd
    		addi $sp, $sp, -4
    			li $t8, 0x0
    			sw $t8, ($sp)
    			jal set_cell
    			lw $t8, ($sp)
    		addi $sp, $sp, 4
    		lw $a0, 16($sp)
    		lw $ra, 12($sp)
    		lw $t2, 8($sp)
    		lw $t1, 4($sp)		
    		lw $t0, ($sp)
    		addi $sp, $sp, 20
    	itsFlagged:
    	
    	lb $t3, ($t2)
    	andi $t3, $t3, 0xf
    	bnez $t3, notZeroSkipaddingToStack
    		addi $t0, $t0, -1
    		addi $t1, $t1, -1
    		addToStack
    		addi $t1, $t1, 1
    		addToStack
    		addi $t1, $t1, 1
    		addToStack
    		addi $t0, $t0, 1
    		addToStack
    		addi $t1, $t1, -2
    		addToStack
    		addi $t0, $t0, 1
    		addToStack
    		addi $t1, $t1, 1
    		addToStack
    		addi $t1, $t1, 1
    		addToStack
    	notZeroSkipaddingToStack:
    	j while_search_cell
    done_search_cells:
    jr $ra

######################
# EXTRA HELPER METHODS
######################

addOneAllNeighbours:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	move $t8, $a2
	
	addi $a0, $a0, -1
	addi $a1, $a1, -1
	jal inbound
	bltz $v0, next1
   		addOneToCell
	next1:
	addi $a0, $a0, 0
	addi $a1, $a1, 1
	jal inbound
	bltz $v0, next2
		addOneToCell	
	next2:
	addi $a0, $a0, 0
	addi $a1, $a1, 1
	jal inbound
	bltz $v0, next3
		addOneToCell	
	next3:
	addi $a0, $a0, 1
	addi $a1, $a1, 0
	jal inbound
	bltz $v0, next4
		addOneToCell	
	next4:
	addi $a0, $a0, 0
	addi $a1, $a1, -2
	jal inbound
	bltz $v0, next5
		addOneToCell	
	next5:
	addi $a0, $a0, 1
	addi $a1, $a1, 0
	jal inbound
	bltz $v0, next6
		addOneToCell	
	next6:
	addi $a0, $a0, 0
	addi $a1, $a1, 1
	jal inbound
	bltz $v0, next7
		addOneToCell	
	next7:
	addi $a0, $a0, 0
	addi $a1, $a1, 1
	jal inbound
	bltz $v0, next8
		addOneToCell	
	next8:	
	returnaddOneAllNeighbours:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
inbound:
	bltz $a0, outofBound
	bgt $a0, 9, outofBound
	bltz $a1, outofBound
	bgt $a1, 9, outofBound
	
	li $v0, 1
	jr $ra
	outofBound:
		li $v0, -1
		jr $ra	
	
	
#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
cursor_row: .word -1
cursor_col: .word -1

#place any additional data declarations here
buffer: .space 10
bomb_clear: .word 0
wrong_bomb: .word 0
revel_bomb: .word 0
num_bomb: .word 0
