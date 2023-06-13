LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;

ENTITY MIPS_tb IS
-- Declarations
generic ( AluOpSize : positive := 9;
			ResSize : positive := 32;
			shamt_size: positive := 5;
			PC_size : positive := 10;
			change_size: positive := 8;
			Imm_size: positive := 26;
			add_res_size  : positive := 8;
			clkcnt_size: positive := 16;
			flush_size: positive := 8;
			stall_size: positive := 8;
			cmd_size: positive := 5); 
END MIPS_tb ;



ARCHITECTURE struct OF MIPS_tb IS

   -- Architecture declarations

   -- Internal signal declarations
    signal reset, clock					    :  	STD_LOGIC; 
	signal  BPADD  						    :  	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 2 ); 
		-- Output important signals to pins for easy display in Simulator
	signal	PC								:   STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	signal	CLKCNT							:   STD_LOGIC_VECTOR( clkcnt_size-1 DOWNTO 0 );
	signal	STtrigger						:   STD_LOGIC;
	signal	STCNT							:   STD_LOGIC_VECTOR( stall_size-1 DOWNTO 0 );
	signal 	FHCNT							:   STD_LOGIC_VECTOR( flush_size-1 DOWNTO 0 );
		-----------------------------ID ---------------------------------------
	signal	ID_Instruction  				:  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	signal	ID_read_data_1, ID_read_data_2, ID_write_data
										    :  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	signal	ID_Regwrite					    :  	STD_LOGIC;
		--------------------------------Ex------------------------------------
	signal	Ex_Instruction					:  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	signal	Ex_ALU_result					:  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	signal	Ex_Zero     			    	:  	STD_LOGIC;
	signal	Ex_ALUAinput,Ex_ALUBinput		:  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		---------------------------------Mem ------------------------------------------
	signal	Mem_Instruction					:  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	signal	Mem_Memwrite					:  	STD_LOGIC;
	signal	Mem_write_data              	:  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	signal	Mem_read_data              	 	:  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	signal	Mem_Branch                 	    :  	STD_LOGIC_VECTOR(1 DOWNTO 0 );
	signal	Mem_address					    :  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		--------------------------------Wb---------------------------------------------
	signal	WB_Instruction				    :  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	signal	Mem_MemToReg 				    :  	STD_LOGIC_VECTOR( 1 DOWNTO 0 );

   -- Component Declarations
 COMPONENT MIPS IS
	generic ( AluOpSize : positive := 9;
			ResSize : positive := 32;
			shamt_size: positive := 5;
			PC_size : positive := 10;
			change_size: positive := 8;
			Imm_size: positive := 26;
			add_res_size  : positive := 8;
			clkcnt_size: positive := 16;
			flush_size: positive := 8;
			stall_size: positive := 8;
			cmd_size: positive := 5); 
			
	PORT( reset, clock					: IN 	STD_LOGIC; 
	      BPADD  						: IN 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
		CLKCNT							: OUT  STD_LOGIC_VECTOR( clkcnt_size-1 DOWNTO 0 );
		STtrigger						: OUT  STD_LOGIC;
		STCNT							: OUT  STD_LOGIC_VECTOR( stall_size-1 DOWNTO 0 );
		FHCNT							: OUT  STD_LOGIC_VECTOR( flush_size-1 DOWNTO 0 );
		-----------------------------ID ---------------------------------------
		ID_Instruction  				: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		ID_read_data_1, ID_read_data_2, ID_write_data
										: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		ID_Regwrite					    : OUT 	STD_LOGIC;
		--------------------------------Ex------------------------------------
		Ex_Instruction					: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Ex_ALU_result					: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Ex_Zero     			    	: OUT 	STD_LOGIC;
		Ex_ALUAinput,Ex_ALUBinput		: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		---------------------------------Mem ------------------------------------------
		Mem_Instruction					: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Mem_Memwrite					: OUT 	STD_LOGIC;
		Mem_write_data              	: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Mem_read_data              	 	: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Mem_Branch                 	    : OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0 );
		Mem_address					    : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		--------------------------------Wb---------------------------------------------
		WB_Instruction				    : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Mem_MemToReg 				    : OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 )
		 );
END 	COMPONENT;
   



BEGIN

   -- Instance port mappings.
  
   U_0 : MIPS
      PORT MAP (
        reset 				=> reset,
		clock 				=> clock,
	    BPADD 				=> BPADD, 						
		PC					=> PC,						
		CLKCNT				=> CLKCNT,						
		STtrigger 			=> STtrigger,						
		STCNT	 			=> STCNT,						
		FHCNT				=> FHCNT,		
		ID_Instruction		=> ID_Instruction,
		ID_read_data_1		=> ID_read_data_1,
		ID_read_data_2		=> ID_read_data_2, 
		ID_write_data 		=> ID_write_data,
		ID_Regwrite			=> ID_Regwrite,			  
		Ex_Instruction		=> Ex_Instruction,
		Ex_ALU_result		=> Ex_ALU_result,
		Ex_Zero     		=> Ex_Zero,
		Ex_ALUAinput		=> Ex_ALUAinput,
		Ex_ALUBinput		=> Ex_ALUBinput,
		Mem_Instruction		=> Mem_Instruction,
		Mem_Memwrite		=> Mem_Memwrite,
		Mem_write_data      => Mem_write_data,
		Mem_read_data       => Mem_read_data,
		Mem_Branch          => Mem_Branch,
		Mem_address			=> Mem_address,
		WB_Instruction		=> WB_Instruction,
		Mem_MemToReg 		=> Mem_MemToReg
      );
	  
   rst: PROCESS
   BEGIN
		reset<='1';
        WAIT FOR 100 ns;
		reset<='0';
		wait;
  
   END PROCESS rst;
   
   clk: PROCESS
   BEGIN
		clock<='0';
        WAIT FOR 50 ns;
		clock<='1';
		WAIT FOR 50 ns;
    
   END PROCESS clk;
END struct;
