LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;

ENTITY MIPS_tb IS
-- Declarations
generic ( AluOpSize : positive := 9;
			ResSize : positive := 32;
			PC_size : positive := 10;
			change_size: positive := 8;
			Imm_size: positive := 26;
			clkcnt_size: positive := 16 ); 
END MIPS_tb ;



ARCHITECTURE struct OF MIPS_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL ALU_result_out  : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
   SIGNAL Branch_out      :  STD_LOGIC_VECTOR( 1 DOWNTO 0 );
   SIGNAL Instruction_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
   SIGNAL Memwrite_out    : STD_LOGIC;
   SIGNAL PC              : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
   SIGNAL Regwrite_out    : STD_LOGIC;
   SIGNAL Zero_out        : STD_LOGIC;
   SIGNAL clock           : STD_LOGIC;
   SIGNAL read_data_1_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
   SIGNAL read_data_2_out : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
   SIGNAL reset           : STD_LOGIC;
   SIGNAL write_data_out  : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
   SIGNAL CLKCNT		  : STD_LOGIC_VECTOR( clkcnt_size-1 DOWNTO 0 );

   -- Component Declarations
   COMPONENT MIPS
   PORT (
      reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
		CLKCNT							: OUT  STD_LOGIC_VECTOR( clkcnt_size-1 DOWNTO 0 );
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Branch_out                      : OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0 );
		Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC
   );
   END COMPONENT;
   



BEGIN

   -- Instance port mappings.
  
   U_0 : MIPS
      PORT MAP (
         reset           => reset,
         clock           => clock,
         PC              => PC,
		 CLKCNT          =>CLKCNT,
         ALU_result_out  => ALU_result_out,
         read_data_1_out => read_data_1_out,
         read_data_2_out => read_data_2_out,
         write_data_out  => write_data_out,
         Instruction_out => Instruction_out,
         Branch_out      => Branch_out,
         Zero_out        => Zero_out,
         Memwrite_out    => Memwrite_out,
         Regwrite_out    => Regwrite_out
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
