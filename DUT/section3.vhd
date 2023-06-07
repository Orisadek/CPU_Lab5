
--  Execute module (implements the data ALU and Address Adder  

--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY  sectionThree IS
--									*********Constants Delclaration**********
generic ( AluOpSize 	: positive := 9;
		  add_res_size  : positive := 8;
		  shamt_size	: positive := 5;
		  cmd_size		: positive := 5;
		  func_op_size	: positive := 6;
		  ResSize		: positive := 32;
		  PC_size    	: positive := 10;
		  change_size	: positive := 8;
		  mult_size	 	: positive := 64	); 

	PORT(	Read_data_1 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Read_data_2 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Sign_extend 		     : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			ALUOp 					 : IN 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
			ALUSrc 					 : IN 	STD_LOGIC;
			PC_plus_4 				 : IN 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
			clock, reset			 : IN 	STD_LOGIC;
			write_register_address_1 : IN   STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			write_register_address_0 : IN	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			RegDst 					 : IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Regwrite_in 			 : IN 	STD_LOGIC;
			MemWrite_in 			 : IN 	STD_LOGIC;
			MemtoReg_in 			 : IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			MemRead_in 				 : IN 	STD_LOGIC;
			Sign_extend_J   		 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Sign_extend_J_out   	 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Regwrite_out 			 : OUT 	STD_LOGIC;
			MemWrite_out 			 : OUT 	STD_LOGIC;
			MemtoReg_out 			 : OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			MemRead_out 			 : OUT 	STD_LOGIC;
			Read_data_1_out 		 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Read_data_2_out 		 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Zero 					 : OUT	STD_LOGIC;
			ALU_Result 				 : OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Add_Result 				 : OUT	STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
			write_register_address 	 : OUT  STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			PC_plus_4_out			 : OUT  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 )
			 );
END sectionThree;

ARCHITECTURE behavior OF sectionThree IS
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
SIGNAL zeroes				: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );


BEGIN
--------------------------------forward the controls ------------------------------------------------
Regwrite_out  	<= Regwrite_in;
MemWrite_out  	<= MemWrite_in;		
MemtoReg_out  	<= MemtoReg_in; 			
MemRead_out   	<= MemRead_in;		
Read_data_1_out <= Read_data_1;
Read_data_2_out <= Read_data_2;
Sign_extend_J_out <=Sign_extend_J;
PC_plus_4_out   <= PC_plus_4;
---------------------------------start the Execute ------------------------------------------------------
	
				
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( PC_size-1 DOWNTO 2 ) +  Sign_extend( change_size-1 DOWNTO 0 ); 
	Add_result 	<= Branch_Add( change_size-1 DOWNTO 0 );
		
	EXE:  Execute
   	PORT MAP (	Read_data_1 	=>Read_data_1,
				Read_data_2 	=>Read_data_2,
				Sign_extend 	=> Sign_extend_ex,
				ALUOp 			=> ALUop_ex,
				ALUSrc 			=> ALUSrc_ex,	
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
                Clock			=> clock,
				Reset			=> reset );

  
 -----------------------------------------mux choose register to write into --------------------------
   write_register_address <= write_register_address_1 WHEN RegDst = "01"  ELSE 
							write_register_address_0  WHEN RegDst = "00"  ELSE 
							CONV_STD_LOGIC_VECTOR( ResSize-1, cmd_size ) WHEN RegDst = "10"  ELSE 
							(others=>'0');
END behavior;

