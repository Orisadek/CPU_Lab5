.data 
	i: .word 1 
	j: .word 2
	g: .word 3
	h: .word 4
	f: .word 5
	
.text


addi $s2,$zero,8 #s2 = 8
add $t8, $zero, $zero
add $t8, $zero, $zero
add $t8, $zero, $zero
lw $s6, 8($s2) #s6 = Mem[s2+8] = Mem[16] = 5
add $t8, $zero, $zero
add $t8, $zero, $zero
add $t8, $zero, $zero
sw $s2, 3($s6) #Mem[5+100] = $s2 ==> Mem[Mem[216]+100] = 136
lui $s3, 100 #s3 = 100*2^16
addi $s4,$zero,36 #s4= 36
addi $s5,$zero,4 #s5 = 4
add $t8, $zero, $zero
add $t8, $zero, $zero
add $t8, $zero, $zero
mul $s6,$s5,$s4 #s6 = 4*36 = 136
move $s1,$s2
add $t8, $zero, $zero
add $t8, $zero, $zero
add $t8, $zero, $zero
andi $s7,$s1,96
addi $s1,$s2, 24
slt $t1,$t2,$t3
add $t8, $zero, $zero
add $t8, $zero, $zero
add $t8, $zero, $zero
slti $t0,$t2,50
bne $s2,$s4,NotEqual #branches because they're not equal
add $t8, $zero, $zero
add $t8, $zero, $zero
add $t8, $zero, $zero
NotEqual:
beq $s2,$s6,branch
add $t8, $zero, $zero
add $t8, $zero, $zero
add $t8, $zero, $zero
sub $t8,$s2,$s3
branch:
   addi $t8, $zero, 100
