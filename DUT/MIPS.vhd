				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS
	generic ( AluOpSize : positive := 7;
			ResSize : positive := 32;
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

	COMPONENT Ifetch
   	     PORT(	Instruction			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		PC_plus_4_out 		: OUT  	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
        		Add_result 			: IN 	STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
        		Branch 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		Zero 				: IN 	STD_LOGIC;
        		PC_out 				: OUT 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
        		clock,reset 		: IN 	STD_LOGIC;
				data_reg 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
				Jump       		    : IN   STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				JumpAdress		    : IN   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
				);
	END COMPONENT; 

	COMPONENT Idecode
 	     PORT(	read_data_1 		: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		read_data_2 		: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		Instruction 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		read_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		ALU_result 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		RegWrite			: IN 	STD_LOGIC;
				MemtoReg 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		RegDst 				: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        		Sign_extend 		: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
				PC_plus_4   		: IN    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); --- change if needed
        		clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT control
	     PORT( 	Opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
             	RegDst 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	ALUSrc 				: OUT 	STD_LOGIC;
             	MemtoReg 			: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	RegWrite 			: OUT 	STD_LOGIC;
             	MemRead 			: OUT 	STD_LOGIC;
             	MemWrite 			: OUT 	STD_LOGIC;
             	Branch 				: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
				Jump       			: OUT   STD_LOGIC_VECTOR( 1 DOWNTO 0 );
             	ALUop 				: OUT 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
             	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
   	     PORT(	Read_data_1 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
                Read_data_2 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
               	Sign_Extend 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
               	Function_opcode		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
               	ALUOp 				: IN 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
               	ALUSrc 				: IN 	STD_LOGIC;
				PC_plus_4 			: IN 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
               	clock, reset		: IN 	STD_LOGIC;
               	Zero 				: OUT	STD_LOGIC;
               	ALU_Result 			: OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
               	Add_Result 			: OUT	STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 )
				);
	END COMPONENT;


	COMPONENT dmemory
	     PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		address 			: IN 	STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
        		write_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        		MemRead, Memwrite 	: IN 	STD_LOGIC;
        		Clock,reset			: IN 	STD_LOGIC );
	END COMPONENT;


	COMPONENT jmp_unit IS
	generic ( ResSize : positive := 32 ); 
	PORT(	 instruction 	: IN	STD_LOGIC_VECTOR( 25 DOWNTO 0 );
			 PC_plus_4_out 	: IN	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			 JumpAdress		: OUT   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
			 );

	END COMPONENT;
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
   zeroes<=(OTHERS =>'0');
   Instruction_out 	<= Instruction;
   ALU_result_out 	<= ALU_result;
   read_data_1_out 	<= read_data_1;
   read_data_2_out 	<= read_data_2;

   write_data_out <= ALU_result WHEN ( MemtoReg = "00" ) ELSE 
				  read_data WHEN ( MemtoReg = "01" ) ELSE  
				  zeroes(ResSize-1 downto PC_size )&PC_plus_4 WHEN ( MemtoReg = "10" ) ELSE   ---CONV_STD_LOGIC_VECTOR( 31, 32 )
				  (others=>'0');
				  
   Branch_out 		<= Branch;
   Zero_out 		<= Zero;
   RegWrite_out 	<= RegWrite;
   MemWrite_out 	<= MemWrite;	
					-- connect the 5 MIPS components   
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

	

clkcnt_proc:PROCESS(clock)
	variable clkcnt_temp:integer;
		BEGIN
			if(reset='1') then
			clkcnt_temp:= 0;
			elsif( (clock'EVENT ) AND ( clock = '1' ))then
			clkcnt_temp:=clkcnt_temp+1;
			CLKCNT<= CONV_STD_LOGIC_VECTOR( clkcnt_temp, clkcnt_size ) ;
			end if;
	END PROCESS;

END structure;

