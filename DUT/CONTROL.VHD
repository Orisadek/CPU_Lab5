		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
<<<<<<< HEAD
generic ( AluOpSize : positive := 7 ); 
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
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
=======
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC;
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC;
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 		: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Branch 		: OUT 	STD_LOGIC;
	Jump        : OUT   STD_LOGIC;
	ALUop 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	clock, reset	: IN 	STD_LOGIC );
>>>>>>> 172d992f8b088c653a05e3fb3314e990089d6643

END control;

ARCHITECTURE behavior OF control IS

<<<<<<< HEAD
	SIGNAL  R_format, Lw, Sw, Beq,Bne,jmp,jr,jal, I_format,Addi,Ori,Andi,Xori,Slti: STD_LOGIC;
=======
	SIGNAL  R_format, Lw, Sw, Beq, I_format 	: STD_LOGIC;
>>>>>>> 172d992f8b088c653a05e3fb3314e990089d6643

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
<<<<<<< HEAD
	I_format    <=  '1'  WHEN  (Opcode = "001000" or Opcode ="001100" or Opcode ="001101" or Opcode ="001010" or Opcode ="001110" or Opcode ="001111") ELSE '0'; --ADDI,ANDI,ORI,SLTI,XORI
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
	Bne         <=  '1'  WHEN  Opcode = "000101"  ELSE '0';
  	RegDst    	<=  "01" when R_format='1' else "10" when jal ='1' ELSE "00";
 	ALUSrc  	<=  Lw OR Sw OR I_format;
	MemtoReg 	<=  "01" when Lw='1' else "10"  when jal = '1' else "00";
  	RegWrite 	<=  R_format OR Lw;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch(0)   <=  Beq;
	Branch(1)   <=  Bne;
	Jump		<=  "11" when jmp = '1' ELSE "10" when jal = '1' ELSE "01" when jr = '1' else "00";
	Addi<= '1'  WHEN  (Opcode = "001000") ELSE '0';
	Ori <= '1'  WHEN  (Opcode ="001101") ELSE '0';
	Andi<= '1'  WHEN  (Opcode = "001100") ELSE '0';
	Xori<= '1'  WHEN  (Opcode = "001110") ELSE '0';
	Slti<= '1'  WHEN  (Opcode ="001010") ELSE '0';
	ALUOp(6)<=Slti;
	ALUOp(5)<=Xori;
	ALUOp(4)<=Andi;
	ALUOp(3)<=Ori;
	ALUOp(2)<=Addi;
=======
	I_format    <=  '1'  WHEN  (Opcode = "001000" or "001100" or "001101" or "001010" or "001110") ELSE '0'; --ADDI,ANDI,ORI,SLTI,XORI
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
  	RegDst    	<=  R_format;
 	ALUSrc  	<=  Lw OR Sw OR I_format;
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  R_format OR Lw;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch      <=  Beq;
>>>>>>> 172d992f8b088c653a05e3fb3314e990089d6643
	ALUOp( 1 ) 	<=  R_format;
	ALUOp( 0 ) 	<=  Beq; 

   END behavior;


