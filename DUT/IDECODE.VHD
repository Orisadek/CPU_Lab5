						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY Idecode IS
--									*********Constants Delclaration**********								
generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8;
		cmd_size: positive := 5;
		Imm_val_I: positive  :=16;
		Imm_val_J: positive  :=26
		);
	  PORT(	read_data_1				 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data_2				 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_register_1_address	 : IN STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			read_register_2_address	 : IN STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			RegWrite 				 : IN 	STD_LOGIC;
			write_register_address 	 : IN 	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 ); 
			write_data				 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			clock,reset				 : IN 	STD_LOGIC );
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO ResSize-1 ) OF STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );

SIGNAL register_array					: register_file;

	
BEGIN

					-- Read Register 1 Operation
	read_data_1 <= register_array( CONV_INTEGER( read_register_1_address ) );
					-- Read Register 2 Operation		 
	read_data_2 <= register_array( CONV_INTEGER( read_register_2_address ) );
					-- Mux for Register Write Address
	


PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '0';
		IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			FOR i IN 0 TO ResSize-1 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, ResSize );
 			END LOOP;
					-- Write back to register - don't write to register 0
  		ELSIF (RegWrite = '1' AND write_register_address/= 0 ) THEN
		      register_array(CONV_INTEGER(write_register_address)) <= write_data;
			  --register_array(ResSize-1) <= zeroes(ResSize-1 downto PC_size )&PC_plus_4_mem_wb;
		END IF;
	END PROCESS;
END behavior;


