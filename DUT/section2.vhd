						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY sectionTwo IS
--									*********Constants Delclaration**********								
generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8;
		cmd_size: positive := 5;
		Imm_val_I: positive  :=16;
		Imm_val_J: positive  :=26
		);
	  PORT(	read_data_1				 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data_2				 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			write_reg_address_1 	 : OUT STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			write_reg_address_0      : OUT STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			Sign_extend 			 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			PC_plus_4_out 			 : OUT STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			RegDst 					 : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Regwrite_out 			 : OUT STD_LOGIC;
			ALUop 					 : OUT STD_LOGIC_VECTOR(  AluOpSize-1 DOWNTO 0 );
			ALUSrc 					 : OUT STD_LOGIC;
			MemWrite 				 : OUT STD_LOGIC;
			MemtoReg 				 : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			MemRead 				 : OUT STD_LOGIC;
			Jump 					 : OUT STD_LOGIC_VECTOR( 2 DOWNTO 0 );
			Branch 				     : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			JumpAdress		         : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Instruction_out 		 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			stall 					 : IN 	STD_LOGIC;
			Instruction 			 : IN  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			RegWrite_in 			 : IN  STD_LOGIC;
			PC_plus_4   			 : IN  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			write_register_address 	 : IN  STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 ); 
			write_data				 : IN  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			clock,reset				 : IN  STD_LOGIC );
END sectionTwo;


ARCHITECTURE behavior OF sectionTwo IS
	SIGNAL Instruction_immediate_value_I	: STD_LOGIC_VECTOR( Imm_val_I-1 DOWNTO 0 );
	SIGNAL Instruction_immediate_value_J	: STD_LOGIC_VECTOR( Imm_val_J-1 DOWNTO 0 );
	SIGNAL Sign_extend_J 			        : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );			
	SIGNAL RegDst_local 					: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite_out_local 				: STD_LOGIC;
	SIGNAL ALUop_local 					 	: STD_LOGIC_VECTOR(  AluOpSize-1 DOWNTO 0 );
	SIGNAL ALUSrc_local 					: STD_LOGIC;
	SIGNAL MemWrite_local 				 	: STD_LOGIC;
	SIGNAL MemtoReg_local 				 	: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL MemRead_local 				 	: STD_LOGIC;
	SIGNAL Jump_local 					 	: STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL Branch_local 				    : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL read_data_1_local 				: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data_2_local 				: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
BEGIN
----------------------------forward signals------------------------------------------
   	write_reg_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_reg_address_0 <= Instruction( 20 DOWNTO 16 );
	PC_plus_4_out		<= PC_plus_4;
	Instruction_out     <= (others=>'0') when stall='1' else  Instruction;
------------------------------------------------------------------------------------------
	
   	Instruction_immediate_value_I <= Instruction( Imm_val_I-1 DOWNTO 0 ); --decompositioning Immediate part of the intruction
	Instruction_immediate_value_J <= Instruction( Imm_val_J-1 DOWNTO 0 );
	
					-- Sign Extend 16-bits to 32-bits or from 26 to 32 bits
		--- sign extention
    Sign_extend <= X"0000" & Instruction_immediate_value_I WHEN (Instruction_immediate_value_I(Imm_val_I-1) = '0' ) ELSE
		X"FFFF" & Instruction_immediate_value_I;
	
	Sign_extend_J<=B"000000" & Instruction_immediate_value_J WHEN (Instruction_immediate_value_J(Imm_val_J-1) = '0')  ELSE
		B"111111" & Instruction_immediate_value_J when (Instruction_immediate_value_J(Imm_val_J-1) = '1');
	
	RegDst 			<= "00" when stall='1' else RegDst_local; 
	Regwrite_out 	<= '0' when stall='1' else Regwrite_out_local; 
	ALUop			<= (others=>'0') when stall='1' else ALUop_local; 
	ALUSrc			<= '0' when stall='1' else ALUSrc_local; 
	MemWrite        <= '0' when stall='1' else MemWrite_local; 
	MemtoReg        <= (others=>'0') when stall='1' else MemtoReg_local; 
	MemRead     	<= '0' when stall='1' else MemRead_local; 
	Jump    		<= (others=>'0') when stall='1' else Jump_local; 
	Branch      	<= (others=>'0') when stall='1' else Branch_local; 
	read_data_1 	<= (others=>'0') when stall='1' else read_data_1_local;
	read_data_2		<= (others=>'0') when stall='1' else read_data_2_local;
	
	decode_port_map : Idecode 
		PORT MAP(
			read_data_1					=> read_data_1_local,
			read_data_2				 	=> read_data_2_local,
			read_register_1_address	 	=> Instruction( 25 DOWNTO 21 ),
			read_register_2_address	 	=> Instruction( 20 DOWNTO 16 ),
			RegWrite 					=> RegWrite_in,
			write_register_address 	 	=> write_register_address, 
			write_data					=> write_data,
			clock 						=> clock,
			reset 						=> reset );	

	CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				func_op     	=> Instruction( 5 DOWNTO 0 ),
				RegDst 			=> RegDst_local,
				ALUSrc 			=> ALUSrc_local,
				MemtoReg 		=> MemtoReg_local,
				RegWrite 		=> Regwrite_out_local,
				MemRead 		=> MemRead_local,
				MemWrite 		=> MemWrite_local,
				Branch 			=> Branch_local,
				Jump            => Jump_local,
				ALUop 			=> ALUop_local,
                clock 			=> clock,
				reset 			=> reset );
				
				
		Jmp :  jmp_unit 
	PORT MAP (
			instruction 	=> Sign_extend_J( 25 DOWNTO 0 ),
			PC_plus_4_msb  	=> PC_plus_4(3 DOWNTO 0 ),
			JumpAdress		=> JumpAdress
			);


END behavior;


