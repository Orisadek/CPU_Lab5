						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY work;
USE work.aux_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		address_size: positive := 8
		); 
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( address_size-1 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock : STD_LOGIC;
BEGIN
	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 32,
		widthad_a => 8,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\orisa\source\modelSim\work\L1_Caches\stall_test\test3_data.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => memwrite,
		clock0 => write_clock,
		address_a => address,
		data_a => write_data,
		q_a => read_data	);
-- Load memory address register with write clock
		write_clock <= NOT clock;
END behavior;

