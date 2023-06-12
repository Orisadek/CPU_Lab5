						
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY stallUnit IS
--									*********Constants Delclaration**********								
generic ( ResSize : positive := 32);
	  PORT(	
			PCWriteDisable			: OUT 	STD_LOGIC;
			If_idWriteDisable		: OUT 	STD_LOGIC;
			stall 					: OUT 	STD_LOGIC;
			id_ex_reg_write    		: IN 	STD_LOGIC;
			ex_mem_reg_write    	: IN 	STD_LOGIC;
			mem_wb_reg_write    	: IN 	STD_LOGIC;
			Instruction             : IN  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			clock,reset				: IN 	STD_LOGIC );
END stallUnit;


ARCHITECTURE behavior OF stallUnit IS

	
BEGIN

	
	

END stallUnit;


