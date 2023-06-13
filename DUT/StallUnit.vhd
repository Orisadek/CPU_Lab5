						
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY stallUnit IS
--									*********Constants Delclaration**********								
generic ( ResSize : positive := 32;
		  cmd_size: positive := 5;
		  opcode_size: positive := 6 );
	  PORT(	
			PCWriteDisable					: OUT 	STD_LOGIC;
			If_idWriteDisable				: OUT 	STD_LOGIC;
			stall 							: OUT 	STD_LOGIC;
			write_reg_address_ex    		: IN  	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			write_reg_address_mem 		    : IN  	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			write_register_address 	    	: IN  	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 ); 
			id_ex_reg_write    				: IN 	STD_LOGIC;
			ex_mem_reg_write    			: IN 	STD_LOGIC;
			mem_wb_reg_write    			: IN 	STD_LOGIC;
			Instruction             		: IN  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			clock,reset						: IN 	STD_LOGIC );
END stallUnit;


ARCHITECTURE behavior OF stallUnit IS
	signal read_register_1_address   :STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );--	 	=> Instruction( 25 DOWNTO 21 ),
	signal read_register_2_address 	 :STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 ); --Instruction( 20 DOWNTO 16 ),	
	signal hazard_ex_1,hazard_ex_2	 :STD_LOGIC;
	signal hazard_mem_1,hazard_mem_2 :STD_LOGIC;
	signal hazard_wb_1,hazard_wb_2	 :STD_LOGIC;
	signal toStall,I_format          :STD_LOGIC;
	signal Opcode               	 :STD_LOGIC_VECTOR( opcode_size -1 DOWNTO 0 );
BEGIN
	read_register_1_address <= Instruction( 25 DOWNTO 21 );
	read_register_2_address <= Instruction( 20 DOWNTO 16 );
	Opcode                  <= Instruction( 31 DOWNTO 26 );
	I_format   <='1' WHEN  (Opcode = "001000" or Opcode ="001100" or Opcode ="001101" or Opcode ="001010" or Opcode ="001110" or Opcode ="001111") ELSE '0';
	hazard_ex_1<='1' when (read_register_1_address = write_reg_address_ex and id_ex_reg_write='1' and not(read_register_1_address="00000")) else '0';
	hazard_ex_2<='1' when (read_register_2_address = write_reg_address_ex and id_ex_reg_write='1' and not(read_register_2_address="00000") and not (I_format='1')) else '0';
	
	hazard_mem_1<='1' when (read_register_1_address=write_reg_address_mem and ex_mem_reg_write='1' and not(read_register_1_address="00000")) else '0';
	hazard_mem_2<='1' when (read_register_2_address=write_reg_address_mem and ex_mem_reg_write='1' and not(read_register_2_address="00000") and not (I_format='1')) else '0';
	
	hazard_wb_1<='1' when (read_register_1_address=write_register_address and mem_wb_reg_write='1' and not(read_register_1_address="00000")) else '0';
	hazard_wb_2<='1' when (read_register_2_address=write_register_address and mem_wb_reg_write='1' and not(read_register_2_address="00000") and not (I_format='1')) else '0';
	
	toStall<=hazard_ex_1 or hazard_ex_2 or hazard_mem_1 or hazard_mem_2 or hazard_wb_1 or hazard_wb_2;
	stall<=toStall;
	If_idWriteDisable<=toStall;
	PCWriteDisable<=toStall;
	
END behavior;


