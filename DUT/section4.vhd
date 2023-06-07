LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY sectionFour IS
	generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		PC_size : positive := 10;
		address_size: positive := 8
		); 
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			JumpAdress			: OUT  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			PCSrc 	 			: OUT   STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			RegWrite_out		: OUT 	STD_LOGIC;
			MemToReg_out		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			RegWrite_in			: IN 	STD_LOGIC;
			MemToReg_in			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			PC_plus_4     		: IN    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			Branch				: IN  	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Zero				: IN 	STD_LOGIC;
			Jump				: IN  	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( address_size-1 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
			Sign_extend_J       : IN  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
            clock,reset			: IN 	STD_LOGIC );
END sectionFour;

ARCHITECTURE behavior OF sectionFour IS
SIGNAL write_clock : STD_LOGIC; 

BEGIN
	MemToReg_out<=MemToReg_in;
	RegWrite_out<=RegWrite_in;
	
	PCSrc<= "01" when ((Branch(0)='1' and Zero = '1') or (Branch(1)='1' and Zero = '0')) else
			"10" when Jump(1)='1' ELSE
			"11" when (Jump(0)='1' or Jump(2)='1') else 
			"00";
	
	MEM:  dmemory
	PORT MAP (	read_data 		=> read_data,
				address 		=> ALU_Result(PC_size-1 DOWNTO 2),--jump memory address by 4
				write_data 		=> read_data_2,
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite, 
                clock 			=> clock,  
				reset 			=> reset );
				
	Jmp :  jmp_unit 
	PORT MAP (
			instruction 	=> Sign_extend_J( 25 DOWNTO 0 ),
			PC_plus_4  		=> PC_plus_4(3 DOWNTO 0 ),
			JumpAdress		=>JumpAdress
			);


				
END behavior;

