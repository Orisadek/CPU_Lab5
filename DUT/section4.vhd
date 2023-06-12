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
		cmd_size		: positive := 5;
		add_res_size  : positive := 8;
		address_size: positive := 8
		); 
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			PCSrc 	 			: OUT   STD_LOGIC;
			RegWrite_out		: OUT 	STD_LOGIC;
			MemToReg_out		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Alu_res_out         : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Add_res_out         : OUT 	STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
			w_address_out       : OUT 	STD_LOGIC_VECTOR(cmd_size-1 DOWNTO 0 ); 
			PC_plus_4_out     	: OUT    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			Instruction_out 	: OUT  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Instruction 		: IN   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Add_res      		: IN 	STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
			w_address           : IN 	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			RegWrite_in			: IN 	STD_LOGIC;
			MemToReg_in			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			PC_plus_4     		: IN    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			Branch				: IN  	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Zero				: IN 	STD_LOGIC;
        	ALU_Result 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END sectionFour;

ARCHITECTURE behavior OF sectionFour IS
SIGNAL write_clock : STD_LOGIC; 

BEGIN
------------------------------------------forward ans ---------------------------------------
	MemToReg_out     <= MemToReg_in;
	RegWrite_out     <= RegWrite_in;
	Alu_res_out      <= ALU_Result;
	Add_res_out      <= Add_res;
	PC_plus_4_out    <= PC_plus_4;
	Instruction_out  <= Instruction;
	w_address_out    <= w_address;
-------------------------------------------start mem -----------------------------------------------
	PCSrc<= '1' when ((Branch(0)='1' and Zero = '1') or (Branch(1)='1' and Zero = '0')) else '0';
	
	MEM:  dmemory
	PORT MAP (	read_data 		=> read_data,
				address 		=> ALU_Result(PC_size-1 DOWNTO 2),--jump memory address by 4
				write_data 		=> write_data,
				MemRead 		=> MemRead, 
				Memwrite 		=> MemWrite, 
                clock 			=> clock,  
				reset 			=> reset );
				

				
END behavior;

