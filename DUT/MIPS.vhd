				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY MIPS IS
	generic ( AluOpSize : positive := 7;
			ResSize : positive := 32;
			shamt_size: positive := 5;
			PC_size : positive := 10;
			change_size: positive := 8;
			Imm_size: positive := 26;
			clkcnt_size: positive := 16 ); 
	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
		CLKCNT							: OUT  STD_LOGIC_VECTOR( clkcnt_size-1 DOWNTO 0 );
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Branch_out                      : OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0 );
		Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC );
END 	MIPS;

ARCHITECTURE structure OF MIPS IS
				-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Add_result 		: STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data 		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL Branch 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Jump       		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL RegDst 			: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(  AluOpSize-1 DOWNTO 0 );
	SIGNAL Instruction		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL JumpAdress		: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL zeroes				: STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	
BEGIN
					-- copy important signals to output pins for easy 
					-- display in Simulator
   --zeroes<=(OTHERS =>'0');
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;

   write_data_out <= ALU_result WHEN ( MemtoReg = "00" ) ELSE 
				  read_data WHEN ( MemtoReg = "01" ) ELSE  
				  X"00000"&B"00"&PC_plus_4 WHEN ( MemtoReg = "10" ) ELSE   ---CONV_STD_LOGIC_VECTOR( 31, 32 )
				  (others=>'0');
				  
   Branch_out 		<= Branch;
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite;	
--------------------------- connect the 5 MIPS components----------------------------------------------------------   
  IFE : Ifetch
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				Add_result 		=> Add_result,
				Branch 			=> Branch,
				Zero 			=> Zero,
				PC_out 			=> PC,        		
				clock 			=> clock,  
				reset 			=> reset,
				data_reg 	    => read_data_1,
				Jump            => Jump,
				JumpAdress		=> JumpAdress);


   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				Sign_extend 	=> Sign_extend,
				PC_plus_4       => PC_plus_4,
        		clock 			=> clock,  
				reset 			=> reset );


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

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
				shamt 			=> Instruction( 10 DOWNTO 6 ),
                Function_opcode	=> Instruction( 5 DOWNTO 0 ),
				ALUOp 			=> ALUop,
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset );

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
			instruction 	=> Instruction( 25 DOWNTO 0 ),
			PC_plus_4_out   => PC_plus_4(3 DOWNTO 0 ),
			JumpAdress		=>JumpAdress
			);

-------------------------------CLKCNT register-------------------------------------------	

clkcnt_proc:PROCESS(clock)
	variable clkcnt_temp:integer;
		BEGIN
			if(reset='1') then
				clkcnt_temp:= 0;
			elsif( clock'EVENT  AND  clock = '1' )then
				clkcnt_temp:=clkcnt_temp+1;
				CLKCNT<= CONV_STD_LOGIC_VECTOR( clkcnt_temp, clkcnt_size ) ;
			end if;
	END PROCESS;

END structure;

