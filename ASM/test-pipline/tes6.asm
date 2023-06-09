#This program implements the following C code
#if (i<j)
#	f=g+h;
#else
#	f=g-h;
#end
.data 
	i: .word 1 
	j: .word 2
	g: .word 3
	h: .word 4
	f: .word 5
.text
# Before running this code make sure that
# Settings -> Memory Configuration -> Compact, Data at Address 0
	lw $t1,0#$t1=i
	lw $t2,4#$t2=j
	lw $t3,8#$t3=g
	lw $t4,12#$t4=h
	slti $t0,$t1,5 #if i<j than $t0=1
	beq $t0,$zero,ELSE #if i>=j then go to else part
	add $t8, $zero, $zero
	add $t8, $zero, $zero
	add $t8, $zero, $zero
	add $t8, $zero, $zero
IF:     or $t9,$t3,$t9
	addi $s4,$zero,88
	and $s0,$t1,$t3
	xor $s1,$t2,$t0
	move $s2,$t4
	mul $s3,$t2,$t4
	j END #jr $t4 #jump to END is the same as "j END" which is not yet implemented in our MIPS	 
	add $t8, $zero, $zero
	add $t8, $zero, $zero
	add $t8, $zero, $zero
	add $t8, $zero, $zero
ELSE:   sub $t5,$t3,$t4 #f=g-h
END: 	sw $t5,f	#save f
