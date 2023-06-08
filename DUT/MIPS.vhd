				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;
USE work.aux_package.all;


ENTITY MIPS IS
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
END 	MIPS;

ARCHITECTURE structure OF MIPS IS
				-- declare signals used to connect VHDL components
	
	SIGNAL ALU_result 					   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data 					   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Zero 						   : STD_LOGIC;
	SIGNAL zeroes						   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	-------------------------Fetch - in --------------------------------------
	SIGNAL PCSrc       					   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Add_result 					   : STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
	SIGNAL JumpAdress					   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data_1_if 				   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	-------------------------Fetch - out -------------------------------------
	SIGNAL PC_plus_4_If_Id 				   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL Instruction_If_Id			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	-------------------------Decode - IN section 2-------------------------------------------
	SIGNAL Instruction_ID 			       :  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
    SIGNAL PC_plus_4_ID 			       :  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
	SIGNAL write_register_address 	       :  STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 ); 
	SIGNAL write_data				 	   :  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Regwrite_in 				   	   : STD_LOGIC;
--	SIGNAL PC_out_ID 			: 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	-------------------------Decode - Out section 2-------------------------------------------
	SIGNAL read_data_1_id_ex 			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data_2_id_ex 			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Sign_Extend 					   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Sign_extend_J 				   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL write_reg_address_1		       : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL write_reg_address_0		       : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL PC_plus_4_id_ex 				   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
	-------------------------Control - out section 2-----------------------------------------
	SIGNAL RegDst 						   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Regwrite_ctl_out 			   : STD_LOGIC;
	SIGNAL ALUop 						   : STD_LOGIC_VECTOR(  AluOpSize-1 DOWNTO 0 );
	SIGNAL MemWrite 					   : STD_LOGIC;
	SIGNAL MemtoReg 					   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL MemRead 						   : STD_LOGIC;
	SIGNAL ALUSrc 						   : STD_LOGIC;
	SIGNAL Branch 					       : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL Jump 					       : STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	------------------------Execute - in  section 3-------------------------------------
	SIGNAL  read_data_1_ex 		           : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  read_data_2_ex 		           : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  Sign_extend_ex 				   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL 	Sign_extend_J_ex 			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  ALUOp_ex 			           : STD_LOGIC_VECTOR( AluOpSize-1 DOWNTO 0 );
	SIGNAL  ALUSrc_ex 					   : STD_LOGIC;
	SIGNAL  register_address_ex_1 		   : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL	register_address_ex_0 		   : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL 	PC_plus_4_ex 			       : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
	SIGNAL	RegDst_ex 					   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	Regwrite_id_ex 		           : STD_LOGIC;
	SIGNAL	MemWrite_id_ex 				   : STD_LOGIC;
	SIGNAL	MemtoReg_id_ex 				   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	MemRead_id_ex 				   : STD_LOGIC;
	SIGNAL  Jump_id_ex           		   : STD_LOGIC_VECTOR( 2 DOWNTO 0 );
---------------------------Execute - out  section 3--------------------------------------------		
	SIGNAL	Regwrite_ex_mem 	           : STD_LOGIC;
	SIGNAL	MemWrite_ex_mem  		       : STD_LOGIC;
	SIGNAL	MemtoReg_ex_mem  		   	   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	MemRead_ex_mem  		  	   : STD_LOGIC;
	SIGNAL	Zero_ex_mem  				   : STD_LOGIC;
	SIGNAL 	Sign_extend_J_ex_mem 		   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	ALU_Result_ex_mem  			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	Add_Result_ex_mem  			   : STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
	SIGNAL	write_register_address_ex_mem  : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL  read_reg_1_ex_mem 		       : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  read_reg_2_ex_mem 		       : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  PC_plus_4_ex_mem			   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL  Jump_ex_mem           		   : STD_LOGIC_VECTOR( 2 DOWNTO 0 );
				
--------------------------memory - in section 4 ----------------------------------------------		 
	SIGNAL	Regwrite_mem 	           	   : STD_LOGIC;
	SIGNAL	MemWrite_mem  		           : STD_LOGIC;
	SIGNAL	MemtoReg_mem  		   	       : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	MemRead_mem  		  	       : STD_LOGIC;
	SIGNAL	Zero_mem  				       : STD_LOGIC;
	SIGNAL	ALU_Result_mem  			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	Add_Result_mem  			   : STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
	SIGNAL	write_reg_address_mem     : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL  read_reg_1_mem 		           : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  read_reg_2_mem 		           : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  PC_plus_4_mem				   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL  Sign_extend_J_mem			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  Jump_mem					   : STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL  Branch_mem                     : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
--------------------------memory - out section 4 ----------------------------------------------
	SIGNAL	Regwrite_mem_wb 	           : STD_LOGIC;
	SIGNAL	MemtoReg_mem_wb  		   	   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	write_reg_address_mem_wb       : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL	ALU_Result_mem_wb  			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	read_data_mem_wb  			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	Add_Result_mem_wb  			   : STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
	SIGNAL	read_reg_1_mem_wb     		   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  PC_plus_4_mem_wb			   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL 	PCSrc_mem_wb       			   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL  JumpAdress_mem_wb			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
---------------------------write back in ------------------------------------------------
	SIGNAL	Regwrite_wb      	           : STD_LOGIC;
	SIGNAL	MemtoReg_wb  		   	       : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	write_reg_address_wb           : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL	ALU_Result_wb  			  	   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	read_data_wb  			   	   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
------------------------------------------------------------------------------------------	
BEGIN
					-- copy important signals to output pins for easy 
					-- display in Simulator
   zeroes<=(OTHERS =>'0');
   Instruction_out 	<= Instruction_If_Id;
   ALU_result_out 	<= ALU_Result_wb;
   read_data_1_out 	<= read_data_1_ex;
   read_data_2_out 	<= read_data_2_ex;

   write_data_out <= ALU_Result_wb WHEN ( MemtoReg_wb = "00" ) ELSE 
					read_data_wb WHEN ( MemtoReg_wb = "01" ) ELSE  
					X"00000"&B"00"&PC_plus_4_mem_wb WHEN ( MemtoReg_wb = "10" ) ELSE   ---CONV_STD_LOGIC_VECTOR( 31, 32 )
					(others=>'0');
				  
   Branch_out 		<= Branch;
   Zero_out 		<= Zero_mem;
   RegWrite_out 	<= Regwrite_ctl_out;
   MemWrite_out 	<= MemWrite_mem;	
--------------------------- connect the 5 MIPS components----------------------------------------------------------   
  IFE : Ifetch
	PORT MAP (	Instruction 	=> Instruction_If_Id,
    	    	PC_plus_4_out 	=> PC_plus_4_If_Id,
				Add_result 		=> Add_result,
				PC_out 			=> PC,        		
				clock 			=> clock,  
				reset 			=> reset,
				data_reg 	    => read_data_1_if,
				PCSrc           => PCSrc,
				JumpAdress		=> JumpAdress);


   s2 : sectionTwo	
   	PORT MAP (	read_data_1 			 => read_data_1_id_ex,
        		read_data_2 			 => read_data_2_id_ex,
				write_reg_address_1 	 => write_reg_address_1,
				write_reg_address_0		 => write_reg_address_0,
				PC_plus_4_out 			 => PC_plus_4_id_ex,
        		Instruction 			 => Instruction_ID,
        		--read_data 				 => read_data,
				RegWrite_in 			 => Regwrite_in,
				MemtoReg 				 => MemtoReg,
				RegDst 					 => RegDst,
				Sign_extend 			 => Sign_extend,
				Sign_extend_J   		 => Sign_extend_J,
				PC_plus_4       		 => PC_plus_4_ID,
				write_register_address   => write_register_address,
				write_data				 => write_data,
				Regwrite_out    		 => Regwrite_ctl_out,
				Jump 					 => Jump,
				Branch 					 => Branch,
				ALUop 					 => ALUop,	
				ALUSrc 					 => ALUSrc,		
				MemWrite        		 => MemWrite,				
				MemRead         		 => MemRead,										
        		clock 					 => clock,  
				reset 					 => reset );
				
				
		
   s3:  sectionThree
   	PORT MAP (	Read_data_1 			=> read_data_1_ex,
             	Read_data_2 			=> read_data_2_ex,
				Sign_extend 			=> Sign_extend_ex,
				Sign_extend_J   		=> Sign_extend_J_ex,
				Sign_extend_J_out   	=> Sign_extend_J_ex_mem,
				RegDst         			=> RegDst_ex,
				Regwrite_in    			=> Regwrite_id_ex,
				MemWrite_in    	 		=> MemWrite_id_ex,
				MemtoReg_in     		=> MemtoReg_id_ex,
				MemRead_in      		=> MemRead_id_ex,
				Jump            		=> Jump_id_ex,  
				Jump_out        		=> Jump_ex_mem,
				Regwrite_out    		=> Regwrite_ex_mem,
				MemWrite_out    		=> MemWrite_ex_mem,
				MemtoReg_out			=> MemtoReg_ex_mem,
				MemRead_out			    => MemRead_ex_mem,
				write_register_address  => write_register_address_ex_mem,
				ALUOp 				    => ALUop_ex,
				ALUSrc 					=> ALUSrc_ex,
				write_reg_address_1 	=> register_address_ex_1, 	
				write_reg_address_0 	=> register_address_ex_0,	
				Zero 					=> Zero_ex_mem,
                ALU_Result				=> ALU_Result_ex_mem,
				Add_Result 				=> Add_Result_ex_mem,
				Read_data_1_out 		=> read_reg_1_ex_mem,
				Read_data_2_out 		=> read_reg_2_ex_mem,
				PC_plus_4_out   		=> PC_plus_4_ex_mem,
				PC_plus_4				=> PC_plus_4_ex,
                Clock					=> clock,
				Reset					=> reset );

	
   s4:  sectionFour
	PORT MAP (	
				------------------Out---------------------------------
				read_data 			=> read_data_mem_wb,
				JumpAdress			=> JumpAdress_mem_wb,
				PCSrc 	 			=> PCSrc_mem_wb,
				RegWrite_out		=> Regwrite_mem_wb,
				MemToReg_out		=> MemtoReg_mem_wb,
				w_address_out       => write_reg_address_mem_wb,
				Alu_res_out         => ALU_Result_mem_wb, 
				Add_res_out         => Add_Result_mem_wb, 
				read_data_1_out     => read_reg_1_mem_wb,
				PC_plus_4_out     	=> PC_plus_4_mem_wb,
				-------------------IN---------------------------------
				read_data_1    		=> read_reg_1_mem,
				w_address           => write_reg_address_mem,
				Add_res             => Add_Result_mem,
				RegWrite_in			=> Regwrite_mem,
				MemToReg_in			=> MemtoReg_mem,
				PC_plus_4     		=> PC_plus_4_mem,
				Branch				=> Branch_mem, 
				Zero				=> Zero_mem , 
				Jump				=> Jump_mem , 
				ALU_Result 			=> ALU_Result_mem,
				write_data 			=> read_reg_2_mem,
				MemRead             => MemRead_mem,
				Memwrite 			=> MemWrite_mem,
				Sign_extend_J       => Sign_extend_J_mem, 
				clock           	=> clock,
				reset				=> reset
				);
				
				

----------- Mux to bypass data memory for Rformat instructions  ---- change later
write_data <=  ALU_Result_wb( ResSize-1 DOWNTO 0 ) WHEN ( MemtoReg_wb = "00" ) ELSE  --- to register file
			   read_data_wb WHEN ( MemtoReg_wb = "01" ) ELSE  
			   zeroes(ResSize-1 downto PC_size )&PC_plus_4_mem_wb WHEN ( MemtoReg_wb = "10" ) ELSE   
			   (others=>'0');
	  
-------------------------------forward the signals-------------------------------------------	

forward:PROCESS(clock)
		BEGIN
			if(reset = '1') then
				PC<=(OTHERS=>'0');
			elsif( clock'EVENT  AND  clock = '1' )then
				
	-------------------------Fetch - in --------------------------------------
	PCSrc           <= PCSrc_mem_wb; 
	Add_result      <= Add_Result_mem_wb;
	JumpAdress      <= JumpAdress_mem_wb;
	read_data_1_if 	<= read_reg_1_mem_wb;

	-------------------------Decode - IN section 2-------------------------------------------
	Instruction_ID  <= Instruction_If_Id;
    PC_plus_4_ID	<= PC_plus_4_If_Id ;			      
	------------------------Execute - in  section 3-------------------------------------
	read_data_1_ex 			<= read_data_1_id_ex;	          
	read_data_2_ex 			<= read_data_2_id_ex;		
	Sign_extend_ex 			<= Sign_Extend;		   
	Sign_extend_J_ex 		<= Sign_extend_J;			   
	ALUOp_ex 				<= ALUop;			       
	ALUSrc_ex 				<= ALUSrc;
	register_address_ex_1   <= write_reg_address_1;
	register_address_ex_0 	<= write_reg_address_0;
	PC_plus_4_ex 			<= PC_plus_4_id_ex;
	RegDst_ex 				<= RegDst;
	Regwrite_id_ex 		    <= Regwrite_ctl_out;
	MemWrite_id_ex 			<= MemWrite;
	MemtoReg_id_ex 			<= MemtoReg;
	MemRead_id_ex 			<= MemRead;
	Jump_id_ex           	<= Jump;
	
--------------------------memory - in section 4 ----------------------------------------------		 
	Regwrite_mem  	      <= Regwrite_ex_mem;	           
	MemWrite_mem  	      <= MemWrite_ex_mem;		          
	MemtoReg_mem 	      <= MemtoReg_ex_mem;		   	       
	MemRead_mem  	      <= MemRead_ex_mem;		  	      
	Zero_mem  	 	 	  <= Zero_ex_mem;		      
	ALU_Result_mem  	  <= ALU_Result_ex_mem;		 
	Add_Result_mem  	  <= Add_Result_ex_mem;			  
	write_reg_address_mem <= write_register_address_ex_mem;   
	read_reg_1_mem 	      <= read_reg_1_ex_mem;	         
	read_reg_2_mem 		  <= read_reg_2_ex_mem;	         
	PC_plus_4_mem		  <= PC_plus_4_ex_mem;			
	Sign_extend_J_mem	  <= Sign_extend_J_ex_mem;	 
	Jump_mem			  <= Jump_ex_mem;			
	Branch_mem    		  <= Branch;              

---------------------------write back in ------------------------------------------------
	RegWrite_in				<= Regwrite_mem_wb ;
	MemtoReg_wb 			<= MemtoReg_mem_wb; 	
	write_register_address  <= write_reg_address_mem_wb;
	ALU_Result_wb 			<= ALU_Result_mem_wb;
	read_data_wb  			<= read_data_mem_wb;
------------------------------------------------------------------------------------------
				
				
			end if;
END PROCESS;
	
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

