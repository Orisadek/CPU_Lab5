.data 
	i: .word 1 
	j: .word 2
	g: .word 3
	h: .word 4
	f: .word 5
	
.text


addi $s2,$zero,8 #s2 = 8
lw $s6, 8($s2) #s6 = Mem[s2+8] = Mem[16] = 5
sw $s2, 3($s6) #Mem[5+100] = $s2 ==> Mem[Mem[216]+100] = 136
lui $s3, 100 #s3 = 100*2^16
addi $s4,$zero,36 #s4= 36
addi $s5,$zero,4 #s5 = 4
mul $s6,$s5,$s4 #s6 = 4*36 = 136
move $s1,$s2
andi $s7,$s1,96
addi $s1,$s2, 24
slt $t1,$t2,$t3
slti $t0,$t2,50
bne $s2,$s4,NotEqual 
addi $t8,$zero,9
NotEqual:
beq $s2,$s6,branch
sub $t8,$s2,$s3
branch:
   addi $t8, $zero, 100
