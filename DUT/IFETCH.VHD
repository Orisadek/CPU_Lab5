-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
generic ( ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8); 
	PORT(	 Instruction 		: OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        	 PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );  --WE CHANGED IT FROM 10 BITS TO 4 BITS!!! and back!
			 PC_out 			: OUT	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
        	 Add_result 		: IN 	STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
        	 Branch 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
        	 Zero 			: IN 	STD_LOGIC;
        	 clock, reset 	: IN 	STD_LOGIC;
			 data_reg 		: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			 Jump       	: IN   STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			 JumpAdress		: IN   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
			 );
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4 	 : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL next_PC, Mem_Addr, MUXres : STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );

BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => 8,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\orisa\source\modelSim\work\L1_Caches\testing\test3_prog.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a 	=> Mem_Addr, 
		q_a 			=> Instruction );
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register

		Mem_Addr <= next_PC;
						-- Adder to increment PC by 4        
      	PC_plus_4( PC_size-1 DOWNTO 2 )  <= PC( PC_size-1 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		MUXres  <= X"00" WHEN Reset = '1' ELSE
			Add_result  WHEN ( (( Branch(0) = '1' ) AND ( Zero = '1' )) or(( Branch(1) = '1' ) AND ( Zero = '0' )) )
			ELSE   PC_plus_4( PC_size-1 DOWNTO 2 );
		next_PC <= MUXres when Jump = "00" else 
				   data_reg(PC_size-1 DOWNTO 2 ) when Jump = "01" else --jr 
				   JumpAdress( PC_size-1 DOWNTO 2 ) when (Jump = "10" or Jump = "11") else --jal,j
					(others=>'0');
					
	fetch_proc:process(clock)
		BEGIN
		--	WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF (reset = '1')THEN
				   PC(PC_size-1 DOWNTO 2) <= "00000000" ; 
			elsif( clock'EVENT  AND clock = '1') then
				   PC(PC_size-1 DOWNTO 2 ) <= next_PC;
			END IF;
	END process;
END behavior;


