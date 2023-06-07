		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY control IS

generic ( AluOpSize : positive := 9 ;
		  cmd_size    : positive := 6 ); 
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	func_op 	: IN 	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 	: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Branch 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	Jump 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALUop 		: OUT 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
	clock, reset: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS
	SIGNAL  R_format, Lw, Sw, Beq,Bne,jmp,jr,jal,I_format,Addi,Ori,Andi,Xori,Slti,LUI,Mul: STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	I_format    <=  '1'  WHEN  (Opcode = "001000" or Opcode ="001100" or Opcode ="001101" or Opcode ="001010" or Opcode ="001110" or Opcode ="001111") ELSE '0'; --ADDI,ANDI,ORI,SLTI,XORI
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
	Bne         <=  '1'  WHEN  Opcode = "000101"  ELSE '0';
  	RegDst    	<=  "01" when (R_format='1' or Mul='1')	else 
					"10" when jal ='1' ELSE "00";
	jmp			<=  '1'  WHEN  Opcode = "000010"  ELSE '0'; -- jmp
	jr			<=  '1'  WHEN  (R_format='1' and func_op = "001000") ELSE '0'; --jr
	jal			<=  '1'  WHEN  Opcode = "000011"  ELSE '0'; --jal
	PCSrc		<=  "11" when (jmp = '1' or jal = '1')  ELSE "01" when jr = '1' else "00"; 
	Addi<= '1'  WHEN  (Opcode = "001000") ELSE '0';
	Ori <= '1'  WHEN  (Opcode ="001101") ELSE '0';
	Andi<= '1'  WHEN  (Opcode = "001100") ELSE '0';
	Xori<= '1'  WHEN  (Opcode = "001110") ELSE '0';
	Slti<= '1'  WHEN  (Opcode ="001010") ELSE '0';
	LUI<= '1'  WHEN  (Opcode ="001111") ELSE '0';
	Mul<= '1'  WHEN  (Opcode ="011100") ELSE '0';
	
	----------------------------------------------------------------------------
 	ALUSrc  	<=  Lw OR Sw OR I_format; -- Src (sign ex or register)
	MemtoReg 	<=  "01" when Lw='1' else "10"  when jal = '1' else "00";
  	RegWrite 	<=  R_format OR Lw OR I_format or jal or Mul; -- enable write to register
  	MemRead 	<=  Lw; --enable Memory read 
   	MemWrite 	<=  Sw; --enable Memory Write 
 	Branch(0)   <=  Beq; -- we defined 2 bits so we can distinguish between Branch ops. 
	Branch(1)   <=  Bne;
	ALUOp(8)<= Mul; --all control signals of ALU
	ALUOp(7)<= LUI;
	ALUOp(6)<= Slti;
	ALUOp(5)<= Xori;
	ALUOp(4)<= Andi;
	ALUOp(3)<= Ori;
	ALUOp(2)<= Addi or Lw or Sw; --all of which require adding in I format
	ALUOp(1)<= R_format;
	ALUOp(0)<= Beq or Bne; --conditional branch bit 

   END behavior;


