add $t1,$t2,$t3
sub $t2,$t3,$t5
addi $t1,$t2,50
mul $t3,$t2,$t3
and $t2,$t4,50
or $t1,$t2,$t3
andi $t6,$t7,50
ori $t1,$t2,50
xori $t1,$t2,50
sll $t4,$t5,75
srl $s1,$s2,50
move $s2,$s1
lw $s6, 100($s2)
sw $s7, 100($s6)
lui $s3, 100
andi $s2,0 // i want beq to branch and bne to branch as well
move $s1,$s2
beq $s1,$s2,50 // I need to talk with ori about pc divided by 4
addi $s1,$s2, 24
bne $t1,$t2,50 //should branch
slt $t1,$t2,$t3
slti $t1,$t2,50
j 1000
jr $t1
jal 1000


