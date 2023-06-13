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

addi $t1, $zero, 15 #t1 = 15
addi $t2,$t1,3 #t2 = 18
add $t3,$t2,$t1 #t3 = 33
or $t5,$t3,$t2 #t5 initialzied
sub $t4,$t3,$t1 #t4 = 18
sub $t7,$t2,$t1 #t7 = 3
mul $t6,$t7,$t1 #t6 = 3*15 = 45
and $s1,$t5,100
ori $s2,$t2,50
xori $s3,$t2,50
sll $s4,$t6,6
srl $s5,$t3,4
move $s6,$s1
addi $s4,$zero,136
jal label
addi $t8, $zero, 15
label:
addi $s4,$zero,12420
jr $s4
addi $t8, $zero, 16
END: 	sw $t5,f	#save f

#j label

