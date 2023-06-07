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
			write_register_address_1 : OUT STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			write_register_address_0 : OUT STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			Sign_extend 			 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			PC_plus_4_out 			 : OUT STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			RegDst 					 : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Regwrite_out 			 : OUT STD_LOGIC;
			ALUop 					 : OUT STD_LOGIC_VECTOR(  AluOpSize-1 DOWNTO 0 );
			MemWrite 				 : OUT STD_LOGIC;
			MemtoReg 				 : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			MemRead 				 : OUT STD_LOGIC;
			Instruction 			 : IN  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			RegWrite_in 			 : IN  STD_LOGIC;
			PC_plus_4   			 : IN  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			write_register_address 	 : IN  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			write_data				 : IN  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			clock,reset				 : IN  STD_LOGIC );
END sectionTwo;


ARCHITECTURE behavior OF sectionTwo IS
TYPE register_file IS ARRAY ( 0 TO ResSize-1 ) OF STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );

	SIGNAL register_array					: register_file;
	--SIGNAL write_register_address 			: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	--SIGNAL write_data						: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_register_1_address			: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL read_register_2_address			: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL Instruction_immediate_value_I	: STD_LOGIC_VECTOR( Imm_val_I-1 DOWNTO 0 );
	SIGNAL Instruction_immediate_value_J	: STD_LOGIC_VECTOR( Imm_val_J-1 DOWNTO 0 );
	SIGNAL zeroes							: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL J								: STD_LOGIC;
	
BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	<= Instruction( 20 DOWNTO 16 );
	PC_plus_4_out<=PC_plus_4;
	
   	Instruction_immediate_value_I <= Instruction( Imm_val_I-1 DOWNTO 0 ); --decompositioning Immediate part of the intruction
	Instruction_immediate_value_J<=Instruction( Imm_val_J-1 DOWNTO 0 );
	J <= '1' when (Instruction(ResSize-1 downto 26) = "000010" or Instruction(ResSize-1 downto 26) = "000011") ELSE --detecting wether J type is required
	'0'; --- jmp or jal
	
					-- Sign Extend 16-bits to 32-bits or from 26 to 32 bits
		--- sign extention
    Sign_extend <= X"0000" & Instruction_immediate_value_I WHEN (Instruction_immediate_value_I(Imm_val_I-1) = '0' 
		and J = '0') ELSE
		X"FFFF" & Instruction_immediate_value_I when (Instruction_immediate_value_I(Imm_val_I-1) = '1' 
		and J = '0') ELSE
		B"000000" & Instruction_immediate_value_J WHEN (Instruction_immediate_value_J(Imm_val_J-1) = '0' 
		and J = '1') ELSE
		B"111111" & Instruction_immediate_value_J when (Instruction_immediate_value_J(Imm_val_J-1) = '1' 
		and J = '1');

	decode_port_map : Idecode PORT map(
			read_data_1					=> read_data_1,
			read_data_2				 	=> read_data_2,
			read_register_1_address	 	=> read_register_1_address,
			read_register_2_address	 	=> read_register_2_address,
			--Instruction 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			RegWrite 					=> RegWrite_in,
			write_register_address 	 	=> write_register_address, 
			write_data					=> write_data,
			clock 						=> clock,
			reset 						=> reset );	

	CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction( 31 DOWNTO 26 ),
				func_op     	=> Instruction( 5 DOWNTO 0 ),
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Branch 			=> Branch,
				Jump            => Jump,
				ALUop 			=> ALUop,
                clock 			=> clock,
				reset 			=> reset );
END behavior;

