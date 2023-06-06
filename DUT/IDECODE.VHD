						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY Idecode IS
generic ( AluOpSize : positive := 7;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8;
		cmd_size: positive := 5;
		Imm_val_I: positive  :=16;
		Imm_val_J: positive  :=26
			);
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data 	: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			ALU_result	: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			RegDst 		: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Sign_extend : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			PC_plus_4   : IN    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); --- change if needed
			clock,reset	: IN 	STD_LOGIC );
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO ResSize-1 ) OF STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );

	SIGNAL register_array				: register_file;
	SIGNAL write_register_address 		: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL write_data					: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL Instruction_immediate_value_I	: STD_LOGIC_VECTOR( Imm_val_I-1 DOWNTO 0 );
	SIGNAL Instruction_immediate_value_J	: STD_LOGIC_VECTOR( Imm_val_J-1 DOWNTO 0 );
	SIGNAL zeroes				: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL J				: STD_LOGIC;
	
BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	<= Instruction( 20 DOWNTO 16 );
	
   	Instruction_immediate_value_I <= Instruction( Imm_val_I-1 DOWNTO 0 );
	Instruction_immediate_value_J<=Instruction( Imm_val_J-1 DOWNTO 0 );
	J <= '1' when (Instruction(ResSize-1 downto 26) = "000010" or Instruction(ResSize-1 downto 26) = "000011") ELSE
	'0'; --- jmp or jal
	zeroes<=(OTHERS =>'0');
					-- Read Register 1 Operation
	read_data_1 <= register_array( CONV_INTEGER( read_register_1_address ) );
					-- Read Register 2 Operation		 
	read_data_2 <= register_array( CONV_INTEGER( read_register_2_address ) );
					-- Mux for Register Write Address

   write_register_address <= write_register_address_1 WHEN RegDst = "01"  ELSE 
							write_register_address_0  WHEN RegDst = "00"  ELSE 
							CONV_STD_LOGIC_VECTOR( ResSize-1, cmd_size ) WHEN RegDst = "10"  ELSE 
							(others=>'0');
					-- Mux to bypass data memory for Rformat instructions
	write_data <= ALU_result( ResSize-1 DOWNTO 0 ) WHEN ( MemtoReg = "00" ) ELSE 
				  read_data WHEN ( MemtoReg = "01" ) ELSE  
				  zeroes(ResSize-1 downto PC_size )&PC_plus_4 WHEN ( MemtoReg = "10" ) ELSE   
				  (others=>'0');
					-- Sign Extend 16-bits to 32-bits
		--- sign extention
    	Sign_extend <= X"0000" & Instruction_immediate_value_I WHEN (Instruction_immediate_value_I(Imm_val_I-1) = '0' 
		and J = '0') ELSE
		X"FFFF" & Instruction_immediate_value_I when (Instruction_immediate_value_I(Imm_val_I-1) = '1' 
		and J = '0') ELSE
		B"000000" & Instruction_immediate_value_J WHEN (Instruction_immediate_value_J(Imm_val_J-1) = '0' 
		and J = '1') ELSE
		B"111111" & Instruction_immediate_value_J when (Instruction_immediate_value_J(Imm_val_J-1) = '1' 
		and J = '1');

PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '1';
		IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			FOR i IN 0 TO ResSize-1 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, ResSize );
 			END LOOP;
					-- Write back to register - don't write to register 0
  		ELSIF RegWrite = '1' AND write_register_address /= 0 THEN
		      register_array(CONV_INTEGER(write_register_address)) <= write_data;
		END IF;
	END PROCESS;
END behavior;


