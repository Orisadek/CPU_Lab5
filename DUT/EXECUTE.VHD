
--  Execute module (implements the data ALU and Address Adder  

--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY  Execute IS
--									*********Constants Delclaration**********
generic ( AluOpSize 	: positive := 9;
		  shamt_size	: positive := 5;
		  cmd_size		: positive := 5;
		  func_op_size	: positive := 6;
		  ResSize		: positive := 32;
		  mult_size	 	: positive := 64	); 

	PORT(	Read_data_1 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Read_data_2 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Sign_extend 		     : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			ALUOp 					 : IN 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
			ALUSrc 					 : IN 	STD_LOGIC;
			clock, reset			 : IN 	STD_LOGIC;
			Ainput_out, Binput_out 	 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Zero 					 : OUT	STD_LOGIC;
			ALU_Result 				 : OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
			 );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
SIGNAL zeroes				: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
SIGNAL shamt_int            : integer;
SIGNAL shamt 				: STD_LOGIC_VECTOR( shamt_size-1 DOWNTO 0 );
SIGNAL Function_opcode 		: STD_LOGIC_VECTOR( func_op_size-1 DOWNTO 0 );

BEGIN

---------------------------------start the Execute ------------------------------------------------------
	shamt <= Sign_extend(10 DOWNTO 6);
	Function_opcode <= Sign_extend(5 DOWNTO 0);
	Ainput <= Read_data_1; --No condition is required as they are physically always connected unlike B input
	zeroes<=(OTHERS =>'0');
						-- ALU input mux
	Binput <= Read_data_2 WHEN (ALUSrc = '0' or ALUOp(0) = '1') --Mux for Binput 
		else  Sign_extend;
					
					
	shamt_int<= CONV_INTEGER(shamt); --We converted to integer for validity
					
	ALU_ctl <= "0000" when ((Function_opcode = "100100" and ALUOp(1) = '1') or ALUOp(4)='1')  else --AND,ANDI
			   "0001" when ((Function_opcode = "100101" and ALUOp(1) = '1') or ALUOp(3)='1') else --OR,ORI
			   "0010" when (((Function_opcode = "100000" or Function_opcode = "100001") and ALUOp(1) = '1') or ALUOp(2) = '1') else --ADD ,ADDU,Addi , Sw,Lw
			   "0011" when ((Function_opcode = "100110" and ALUOp(1) = '1') or ALUOp(5) = '1')else --XOR,XORI
			   "0100" when (Function_opcode  = "000000" and ALUOp(1) = '1') else --SHL
			   "0101" when (Function_opcode  = "000010" and ALUOp(1) = '1') else --SHR
			   "0110" when ((Function_opcode = "100010" and ALUOp(1) = '1') or ALUOp(0) = '1') else --SUB,Beq,Bne
			   "0111" when ((Function_opcode = "101010" and ALUOp(1) = '1') or ALUOp(6) = '1') else  --SLT,SLTi
			   "1000" when (ALUOp(8) = '1') else -- MULT
			   "1001" when (ALUOp(7)='1') else -- LUI
			   "1010" when (Function_opcode = "100001"  and  ALUOp(1) = '1') else -- addu
			   "1111"; 
			   
	
	---------Zero signal --------------------------	    
	Zero <= '1' when ALU_output_mux= zeroes else '0';
	Ainput_out<=Ainput;
	Binput_out<=Binput;
PROCESS ( ALU_ctl, Ainput, Binput )
	variable alu_tmp : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	variable alu_mult : STD_LOGIC_VECTOR( mult_size-1 DOWNTO 0 );
	BEGIN
	
					-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs ALUresult = A_input XOR B_input 
 	 	WHEN "0011" 	=>	ALU_output_mux <= Ainput xor Binput;
						-- ALU performs ALUresult = AINPUT shifted *LEFT* by immdediate value (Binput)
 	 	WHEN "0100" 	=>--ALU_output_mux 	<= Binput(ResSize-1-shamt_int DOWNTO 0 )& zeroes(shamt_int-1 DOWNTO 0);
						ALU_output_mux(ResSize-1 DOWNTO shamt_int) 	<= Binput(ResSize-1-shamt_int DOWNTO 0 );
						ALU_output_mux(shamt_int-1 DOWNTO 0)  <= zeroes(shamt_int-1 DOWNTO 0);
						-- ALU performs ALUresult = AINPUT shifted *RIGHT* by immdediate value(Binput)
 	 	WHEN "0101" 	=>ALU_output_mux 	<= zeroes(shamt_int-1 DOWNTO 0) & Binput(ResSize-1 downto shamt_int);
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "0111" 	=>
			alu_tmp:=Ainput - Binput;
			ALU_output_mux <= X"0000000"&B"000"&alu_tmp(ResSize-1);
		WHEN "1000"    => 
				alu_mult :=Ainput * Binput ; -- mult
				ALU_output_mux <= alu_mult(ResSize-1 DOWNTO 0);
		
		WHEN "1001" => ALU_output_mux <= Binput(15 DOWNTO 0)&X"0000";
		
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
			-- Select ALU output        
  END PROCESS;
  ALU_result <= ALU_output_mux;
  

END behavior;

