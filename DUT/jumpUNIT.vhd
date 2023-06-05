-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY jmp_unit IS
generic ( ResSize : positive := 32 ); 
	PORT(	SIGNAL instruction 		: IN	STD_LOGIC_VECTOR( 25 DOWNTO 0 );
			SIGNAL PC_plus_4_out 	: IN	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			SIGNAL JumpAdress		: OUT   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );

END jmp_unit;

ARCHITECTURE JumpUnitA OF jmp_unit IS
	SIGNAL inst_shftd 	 : STD_LOGIC_VECTOR( 27 DOWNTO 0 );
	
	
BEGIN

	inst_shftd <= instruction ,(others<='0');
	JumpAdress <= PC_plus_4_out & inst_shftd;
	
END JumpUnitA;


