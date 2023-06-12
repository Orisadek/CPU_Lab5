addi $s2,$zero,136 #s2 = 136
lw $s6, 80($s2) #s6 = Mem[s2+80] = Mem[216]
sw $s2, 100($s6) #Mem[s6+100] = $s2 ==> Mem[Mem[216]+100] = 136
lui $s3, 100 #s3 = 100*2^16
addi $s4,$zero,36 #s4= 36
addi $s5,$zero,4 #s5 = 4
mul $s6,$s5,$s4 #s6 = 4*36 = 136
move $s1,$s2
andi $s7,$s1,96
addi $s1,$s2, 24
slt $t1,$t2,$t3
slti $t1,$t2,50
branch:
bne $s2,$s4,NotEqual #branches because they're not equal
NotEqual:
beq $s2,$s6,branch


