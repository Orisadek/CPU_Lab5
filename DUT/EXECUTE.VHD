
--  Execute module (implements the data ALU and Address Adder  

--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS

generic ( AluOpSize : positive := 7 ); 

	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_mult		: STD_LOGIC_VECTOR( 63 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ZERO					: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
SIGNAL zeroes				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
BEGIN
	Ainput <= Read_data_1;
	zeroes<=(OTHERS =>'0');
						-- ALU input mux
	Binput <= Read_data_2 WHEN ( ALUSrc = "00" and not( Function_opcode = "000000" or Function_opcode = "000010" )) 
  		else  Sign_extend( 31 DOWNTO 0 );
					---- add mult
					
	ALU_ctl <= "0000" when (Function_opcode = "100100" or ALUOp(4)='1' )  else --AND
			   "0001" when (Function_opcode = "100101" or ALUOp(3)='1') else --OR
			   "0010" when (Function_opcode = "100000" or ALUOp(2) = '1') else --ADD
			   "0011" when (Function_opcode = "100110" or ALUOp(5) = '1')else --XOR
			   "0100" when (Function_opcode = "000000" ) else --SHL
			   "0101" when (Function_opcode = "000010" ) else --SHR
			   "0110" when Function_opcode = "100010" ) else --SUB
			   "0111" when (Function_opcode = "101010" or ALUOp(6) ='1' ) else  --SLT
			   "1000" when (Function_opcode = "011000" ) else -- MULT
			   "1001" when (Function_opcode = "001111") else -- LUI
			   "1111"; 
			   ;
	
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		else '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) WHEN  ALU_ctl = "0111" 
		else  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );
	Zero <= '1' when ALU_output_mux = zeroes else '0';

PROCESS ( ALU_ctl, Ainput, Binput )
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
 	 	WHEN "0100" 	=>	ALU_output_mux 	<= Ainput( 31-Binput DOWNTO 0 ),(others<='0');
						-- ALU performs ALUresult = AINPUT shifted *RIGHT* by immdediate value(Binput)
 	 	WHEN "0101" 	=>	ALU_output_mux 	<= (31 downto 31-Binput =>'0') & Ainput( (31 downto 31-Binput);
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "0111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
		
		WHEN "1000"    => ALU_mult 	<= Ainput * Binput ; -- mult
		
		WHEN "1000"    => ALU_output_mux <= ALU_mult(31 DOWNTO 0);
		
		WHEN "1001"    => ALU_output_mux <= Binput(15 DOWNTO 0),(others<='0');
		
		
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
	
  END PROCESS;
END behavior;

