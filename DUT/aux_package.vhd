LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

package aux_package is

COMPONENT MIPS IS
	generic ( AluOpSize : positive := 9;
			ResSize : positive := 32;
			shamt_size: positive := 5;
			PC_size : positive := 10;
			change_size: positive := 8;
			Imm_size: positive := 26;
			add_res_size  : positive := 8;
			clkcnt_size: positive := 16;
			cmd_size: positive := 5); 
			
	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals to pins for easy display in Simulator
		PC								: OUT  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
		CLKCNT							: OUT  STD_LOGIC_VECTOR( clkcnt_size-1 DOWNTO 0 );
		ALU_result_out, read_data_1_out, read_data_2_out, write_data_out,	
     	Instruction_out					: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
		Branch_out                      : OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0 );
		Zero_out, Memwrite_out, 
		Regwrite_out					: OUT 	STD_LOGIC );
END 	COMPONENT;

COMPONENT sectionTwo IS
--									*********Constants Delclaration**********								
generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8;
		cmd_size: positive := 5;
		Imm_val_I: positive  :=16;
		Imm_val_J: positive  :=26
		);
	  PORT(	read_data_1				 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data_2				 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			write_reg_address_1 	 : OUT STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			write_reg_address_0 	 : OUT STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			Sign_extend 			 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Sign_extend_J 			 : OUT STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			PC_plus_4_out 			 : OUT STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			RegDst 					 : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Regwrite_out 			 : OUT STD_LOGIC;
			JumpAdress		         : OUT  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			ALUop 					 : OUT STD_LOGIC_VECTOR(  AluOpSize-1 DOWNTO 0 );
			ALUSrc 					 : OUT 	STD_LOGIC;
			MemWrite 				 : OUT STD_LOGIC;
			MemtoReg 				 : OUT STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			MemRead 				 : OUT STD_LOGIC;
			Jump 					 : OUT 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
			Branch 				     : OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Instruction 			 : IN  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			RegWrite_in 			 : IN  STD_LOGIC;
			PC_plus_4   			 : IN  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			write_register_address 	 : IN  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			write_data				 : IN  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			clock,reset				 : IN  STD_LOGIC );
END COMPONENT;

COMPONENT  sectionThree IS
--									*********Constants Delclaration**********
generic ( AluOpSize 	: positive := 9;
		  add_res_size  : positive := 8;
		  shamt_size	: positive := 5;
		  cmd_size		: positive := 5;
		  func_op_size	: positive := 6;
		  ResSize		: positive := 32;
		  PC_size    	: positive := 10;
		  change_size	: positive := 8;
		  mult_size	 	: positive := 64	); 

	PORT(	Read_data_1 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Read_data_2 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Sign_extend 		     : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			ALUOp 					 : IN 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
			ALUSrc 					 : IN 	STD_LOGIC;
			PC_plus_4 				 : IN 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
			clock, reset			 : IN 	STD_LOGIC;
			write_reg_address_1 	 : IN   STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			write_reg_address_0      : IN	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			RegDst 					 : IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Regwrite_in 			 : IN 	STD_LOGIC;
			MemWrite_in 			 : IN 	STD_LOGIC;
			MemtoReg_in 			 : IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			MemRead_in 				 : IN 	STD_LOGIC;
			--Sign_extend_J   		 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			--Jump            		 : IN 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
			Branch 					 : IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Branch_out 				 : OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			--Jump_out        		 : OUT 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
			--Sign_extend_J_out   	 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Regwrite_out 			 : OUT 	STD_LOGIC;
			MemWrite_out 			 : OUT 	STD_LOGIC;
			MemtoReg_out 			 : OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			MemRead_out 			 : OUT 	STD_LOGIC;
			Read_data_1_out 		 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Read_data_2_out 		 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Zero 					 : OUT	STD_LOGIC;
			ALU_Result 				 : OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Add_Result 				 : OUT	STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
			write_register_address 	 : OUT  STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			PC_plus_4_out			 : OUT  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 )
			 );
END COMPONENT;

COMPONENT sectionFour IS
	generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		PC_size : positive := 10;
		cmd_size		: positive := 5;
		add_res_size  : positive := 8;
		address_size: positive := 8
		); 
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			--JumpAdress			: OUT  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			PCSrc 	 			: OUT   STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			RegWrite_out		: OUT 	STD_LOGIC;
			MemToReg_out		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Alu_res_out         : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Add_res_out         : OUT 	STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
			w_address_out       : OUT 	STD_LOGIC_VECTOR( cmd_size DOWNTO 0 );
			--read_data_1_out     : OUT 	STD_LOGIC_VECTOR( ResSize DOWNTO 0 ); 
			PC_plus_4_out     	: OUT    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			--read_data_1    		: IN 	STD_LOGIC_VECTOR( ResSize DOWNTO 0 ); 
			Add_res      		: IN 	STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
			w_address           : IN 	STD_LOGIC_VECTOR( cmd_size DOWNTO 0 );
			RegWrite_in			: IN 	STD_LOGIC;
			MemToReg_in			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			PC_plus_4     		: IN    STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			Branch				: IN  	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			Zero				: IN 	STD_LOGIC;
			--Jump				: IN  	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
        	ALU_Result 			: IN 	STD_LOGIC_VECTOR( address_size-1 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
			--Sign_extend_J       : IN  	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
            clock,reset			: IN 	STD_LOGIC );
END COMPONENT;


COMPONENT Ifetch IS
--									*********Constants Delclaration**********
generic ( ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8); 
	PORT(	 Instruction 		: OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        	 PC_plus_4_out 		: OUT	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
			 PC_out 			: OUT	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
        	 Add_result 		: IN 	STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
        	 clock, reset 		: IN 	STD_LOGIC;
			 data_reg 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			 PCSrc       		: IN   STD_LOGIC_VECTOR( 1 DOWNTO 0 ); 
			 Jump 				: IN 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
			 JumpAdress			: IN   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
			 );
END COMPONENT;

COMPONENT Idecode IS
--									*********Constants Delclaration**********								
generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		PC_size : positive := 10;
		change_size: positive := 8;
		cmd_size: positive := 5;
		Imm_val_I: positive  :=16;
		Imm_val_J: positive  :=26
		);
	  PORT(	read_data_1				 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_data_2				 : OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			read_register_1_address	 : IN   STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			read_register_2_address	 : IN   STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
			RegWrite 				 : IN 	STD_LOGIC;
			write_register_address 	 : IN 	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 ); 
			write_data				 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			clock,reset				 : IN 	STD_LOGIC );
END COMPONENT;

COMPONENT control IS

generic ( AluOpSize : positive := 9 ;
		  cmd_size    : positive := 6 ); 
   PORT( 	
	Opcode 		: IN 	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	func_op 	: IN 	STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	RegDst 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	ALUSrc 		: OUT 	STD_LOGIC;
	MemtoReg 	: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	RegWrite 	: OUT 	STD_LOGIC;
	MemRead 	: OUT 	STD_LOGIC;
	MemWrite 	: OUT 	STD_LOGIC;
	Branch 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	Jump 		: OUT 	STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	ALUop 		: OUT 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
	clock, reset: IN 	STD_LOGIC );

END COMPONENT;

COMPONENT  Execute IS
--									*********Constants Delclaration**********
generic ( AluOpSize 	: positive := 9;
		  shamt_size	: positive := 5;
		  cmd_size		: positive := 5;
		  func_op_size	: positive := 6;
		  ResSize		: positive := 32;
		  mult_size	 	: positive := 64	); 

	PORT(	Read_data_1 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Read_data_2 			 : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			Sign_extend 		     : IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
			ALUOp 					 : IN 	STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
			ALUSrc 					 : IN 	STD_LOGIC;
			clock, reset			 : IN 	STD_LOGIC;
			Zero 					 : OUT	STD_LOGIC;
			ALU_Result 				 : OUT	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
			 );
END COMPONENT;


COMPONENT dmemory IS
	generic ( AluOpSize : positive := 9;
		ResSize : positive := 32;
		address_size: positive := 8
		); 
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( address_size-1 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END COMPONENT;

COMPONENT jmp_unit IS
	generic ( ResSize : positive := 32;
		Imm_size: positive := 26);  
	PORT(	 instruction 	: IN	STD_LOGIC_VECTOR( 25 DOWNTO 0 );
			 PC_plus_4_msb 	: IN	STD_LOGIC_VECTOR( 3 DOWNTO 0 );
			 JumpAdress		: OUT   STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 )
			 );

END COMPONENT;

  
end aux_package;