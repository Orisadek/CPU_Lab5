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
			flush_size: positive := 8;
			stall_size: positive := 8;
			cmd_size: positive := 5); 
			
	PORT( reset, clock				    : IN 	STD_LOGIC; 
	      BPADD  						: IN 	STD_LOGIC_VECTOR( PC_size-1 DOWNTO 2 ); 
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
END 	MIPS;

ARCHITECTURE structure OF MIPS IS
				-- declare signals used to connect VHDL components
	
	SIGNAL ALU_result 					   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data 					   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Zero 						   : STD_LOGIC;
	SIGNAL zeroes						   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	-------------------------Fetch - in --------------------------------------
	SIGNAL PCSrc       					   : STD_LOGIC;
	SIGNAL Add_result 					   : STD_LOGIC_VECTOR( change_size-1 DOWNTO 0 );
	SIGNAL JumpAdress					   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	-------------------------Fetch - out -------------------------------------
	SIGNAL PC_plus_4_If_Id 				   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL Instruction_If_Id			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL PC_out						   :STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	-------------------------Decode - IN section 2-------------------------------------------
	SIGNAL Instruction_ID 			       :  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
    SIGNAL PC_plus_4_ID 			       :  STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 ); 
	SIGNAL write_register_address 	       :  STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 ); 
	SIGNAL write_data				 	   :  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Regwrite_in 				   	   : STD_LOGIC;
	-------------------------Decode - Out section 2-------------------------------------------
	SIGNAL read_data_1_id_ex 			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL read_data_2_id_ex 			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Sign_Extend 					   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL Instruction_ID_out 			   :  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
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
	SIGNAL Instruction_Ex_in 			   :  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
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
	SIGNAL  Branch_id_ex 				   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
---------------------------Execute - out  section 3--------------------------------------------		
	SIGNAL	Regwrite_ex_mem 	           : STD_LOGIC;
	SIGNAL	MemWrite_ex_mem  		       : STD_LOGIC;
	SIGNAL	MemtoReg_ex_mem  		   	   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	MemRead_ex_mem  		  	   : STD_LOGIC;
	SIGNAL	Zero_ex_mem  				   : STD_LOGIC;
	SIGNAL Instruction_Ex_out 			   :  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	ALU_Result_ex_mem  			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	Add_Result_ex_mem  			   : STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
	SIGNAL	write_register_address_ex_mem  : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL  read_reg_1_ex_mem 		       : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  read_reg_2_ex_mem 		       : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  PC_plus_4_ex_mem			   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL  Branch_ex_mem 				   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL  Ainput, Binput      		   :  STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );	
--------------------------memory - in section 4 ----------------------------------------------		 
	SIGNAL	Regwrite_mem 	           	   : STD_LOGIC;
	SIGNAL	MemWrite_mem  		           : STD_LOGIC;
	SIGNAL	MemtoReg_mem  		   	       : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	MemRead_mem  		  	       : STD_LOGIC;
	SIGNAL	Zero_mem  				       : STD_LOGIC;
	SIGNAL	ALU_Result_mem  			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	Add_Result_mem  			   : STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
	SIGNAL	write_reg_address_mem    	   : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL  Instruction_mem_in			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  read_reg_1_mem 		           : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  read_reg_2_mem 		           : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  PC_plus_4_mem				   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL  Branch_mem                     : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
--------------------------memory - out section 4 ----------------------------------------------
	SIGNAL	Regwrite_mem_wb 	           : STD_LOGIC;
	SIGNAL	MemtoReg_mem_wb  		   	   : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	write_reg_address_mem_wb       : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL	ALU_Result_mem_wb  			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	read_data_mem_wb  			   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	Add_Result_mem_wb  			   : STD_LOGIC_VECTOR( add_res_size-1 DOWNTO 0 );
	SIGNAL  Instruction_mem_out 		   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	read_reg_1_mem_wb     		   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  PC_plus_4_mem_wb			   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
---------------------------write back in ------------------------------------------------
	SIGNAL	Regwrite_wb      	           : STD_LOGIC;
	SIGNAL  PC_plus_4_wb    			   : STD_LOGIC_VECTOR( PC_size-1 DOWNTO 0 );
	SIGNAL	MemtoReg_wb  		   	       : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	SIGNAL	write_reg_address_wb           : STD_LOGIC_VECTOR( cmd_size-1 DOWNTO 0 );
	SIGNAL	ALU_Result_wb  			  	   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL	read_data_wb  			   	   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
	SIGNAL  Instruction_wb 	        	   : STD_LOGIC_VECTOR( ResSize-1 DOWNTO 0 );
---------------------------stall unit---------------------------------------------------------------
	SIGNAL  PCWriteDisable				   : STD_LOGIC;
	SIGNAL	If_idWriteDisable	 		   : STD_LOGIC;
	SIGNAL	stall 				           : STD_LOGIC;
	-----------------------flush signals -------------------------------------
	SIGNAL flush_if_id					   : STD_LOGIC;
	SIGNAL flush_id_ex					   : STD_LOGIC;
	SIGNAL flush_ex_mem			           : STD_LOGIC;
	
BEGIN
					-- copy important signals to output pins for easy 
					-- display in Simulator
    zeroes<=(OTHERS =>'0');
	STtrigger <= '1' when (BPADD=PC_out) ELSE '0';
    ID_Instruction	<= Instruction_ID;
    ID_read_data_1	<= read_data_1_id_ex;
    ID_read_data_2	<= read_data_2_id_ex;
    ID_write_data 	<= write_data;
    ID_Regwrite   	<= RegWrite_in;
    Ex_Instruction	<= Instruction_Ex_out;
    Ex_ALU_result   <= ALU_Result_ex_mem;
	Ex_Zero 		<= Zero_ex_mem;
	Ex_ALUAinput    <= Ainput;
	Ex_ALUBinput    <= Binput;
	Mem_Instruction <= Instruction_mem_out;
	Mem_Memwrite    <= MemWrite_mem;
	Mem_write_data  <= read_reg_2_mem;
	Mem_read_data   <= read_data_mem_wb;
	Mem_Branch      <= Branch_mem;
	Mem_address     <= ALU_Result_mem;
	WB_Instruction  <= Instruction_wb;
	Mem_MemToReg    <= MemtoReg_wb;
		
		
--------------------------- connect the 5 MIPS components----------------------------------------------------------   
  IFE : Ifetch
	PORT MAP (	Instruction 	=> Instruction_If_Id,
    	    	PC_plus_4_out 	=> PC_plus_4_If_Id,
				Add_result 		=> Add_result,
				PC_out 			=> PC_out,        		
				clock 			=> clock, 
				PCWriteDisable	=> PCWriteDisable,			
				reset 			=> reset,
				data_reg 	    => read_data_1_id_ex,
				PCSrc           => PCSrc,
				Jump            => Jump,
				JumpAdress		=> JumpAdress);


   s2 : sectionTwo	
   	PORT MAP (	read_data_1 			 => read_data_1_id_ex,
        		read_data_2 			 => read_data_2_id_ex,
				stall                    => stall,
				write_reg_address_1 	 => write_reg_address_1,
				write_reg_address_0		 => write_reg_address_0,
				PC_plus_4_out 			 => PC_plus_4_id_ex,
        		Instruction 			 => Instruction_ID,
				Instruction_out 		 => Instruction_ID_out,
				JumpAdress               => JumpAdress,
				RegWrite_in 			 => Regwrite_in,
				MemtoReg 				 => MemtoReg,
				RegDst 					 => RegDst,
				Sign_extend 			 => Sign_extend,
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
				RegDst         			=> RegDst_ex,
				Instruction 			=> Instruction_Ex_in, 
				Instruction_out 		=> Instruction_Ex_out,
				Regwrite_in    			=> Regwrite_id_ex,
				MemWrite_in    	 		=> MemWrite_id_ex,
				MemtoReg_in     		=> MemtoReg_id_ex,
				MemRead_in      		=> MemRead_id_ex,
				Branch 					=> Branch_id_ex,
				Branch_out 				=> Branch_ex_mem,				
				Regwrite_out    		=> Regwrite_ex_mem,
				MemWrite_out    		=> MemWrite_ex_mem,
				MemtoReg_out			=> MemtoReg_ex_mem,
				MemRead_out			    => MemRead_ex_mem,
				write_register_address  => write_register_address_ex_mem,
				Ainput                  => Ainput,
			    Binput      	 		=> Binput,
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
				PCSrc 	 			=> PCSrc,
				RegWrite_out		=> Regwrite_mem_wb,
				MemToReg_out		=> MemtoReg_mem_wb,
				w_address_out       => write_reg_address_mem_wb,
				Alu_res_out         => ALU_Result_mem_wb, 
				Add_res_out         => Add_result, 
				PC_plus_4_out     	=> PC_plus_4_mem_wb,
				Instruction_out 	=> Instruction_mem_out, 
				-------------------IN---------------------------------
				Instruction 		=> Instruction_mem_in,
				w_address           => write_reg_address_mem,
				Add_res             => Add_Result_mem,
				RegWrite_in			=> Regwrite_mem,
				MemToReg_in			=> MemtoReg_mem,
				PC_plus_4     		=> PC_plus_4_mem,
				Branch				=> Branch_mem, 
				Zero				=> Zero_mem , 
				ALU_Result 			=> ALU_Result_mem,
				write_data 			=> read_reg_2_mem,
				MemRead             => MemRead_mem,
				Memwrite 			=> MemWrite_mem,
				clock           	=> clock,
				reset				=> reset
				);
				
				

stall_port_map:stallUnit
	PORT MAP (
			PCWriteDisable		   => PCWriteDisable,
			If_idWriteDisable	   => If_idWriteDisable,
			stall 				   => stall,
			write_reg_address_ex   => write_register_address_ex_mem,
			write_reg_address_mem  => write_reg_address_mem_wb, 
			write_register_address => write_register_address,
			id_ex_reg_write    	   => Regwrite_id_ex,
			ex_mem_reg_write       => Regwrite_mem,
			mem_wb_reg_write       => RegWrite_in,
			Instruction            => Instruction_ID,
			clock				   => clock,
			reset				   => reset );

				

----------- Mux to bypass data memory for Rformat instructions  ---- change later
write_data <=  ALU_Result_wb( ResSize-1 DOWNTO 0 ) WHEN ( MemtoReg_wb = "00" ) ELSE  --- to register file
			   read_data_wb WHEN ( MemtoReg_wb = "01" ) ELSE  
			   zeroes(ResSize-1 downto PC_size )&PC_plus_4_wb  WHEN ( MemtoReg_wb = "10" ) ELSE 			   
			   (others=>'0');
	  
-------------------------------forward the signals-------------------------------------------	


forward:PROCESS(clock)
BEGIN
	if(reset = '1') then
		PC	<= (OTHERS=>'0');
	elsif( clock'EVENT  AND  clock = '1' )then		
		PC	<= PC_out;
end if;
END PROCESS;

If_id:PROCESS(clock)
BEGIN
	if(reset = '1') then
		Instruction_ID <=	(OTHERS=>'0');
		PC_plus_4_ID   <=	(OTHERS=>'0');
	elsif( clock'EVENT  AND  clock = '1' and not(If_idWriteDisable='1'))then	
	-------------------------Decode - IN section 2-------------------------------------------
		Instruction_ID  		 <= Instruction_If_Id;
		PC_plus_4_ID			 <= PC_plus_4_If_Id ;
	elsif( clock'EVENT  AND  clock = '1' and If_idWriteDisable='1')then
		null;
	elsif( clock'EVENT  AND  clock = '1' and flush_if_id='1')then 
		Instruction_ID  		 <= (OTHERS=>'0');
		PC_plus_4_ID			 <= (OTHERS=>'0'); 
	end if;
END PROCESS;

id_ex:PROCESS(clock)
BEGIN
	if(reset = '1') then
		read_data_1_ex 			 <=	(OTHERS=>'0');	          
		read_data_2_ex 			 <=	(OTHERS=>'0');	
		Sign_extend_ex 			 <=	(OTHERS=>'0');		   			   
		ALUOp_ex 				 <=	(OTHERS=>'0');			       
		ALUSrc_ex 				 <=	'0';
		register_address_ex_1    <=	(OTHERS=>'0');
		register_address_ex_0 	 <=	(OTHERS=>'0');
		PC_plus_4_ex 			 <=	(OTHERS=>'0');
		RegDst_ex 				 <=	(OTHERS=>'0');
		Regwrite_id_ex 		     <=	'0';
		MemWrite_id_ex 			 <=	'0';
		MemtoReg_id_ex 			 <=	(OTHERS=>'0');
		MemRead_id_ex 			 <=	'0';
		Branch_id_ex 			 <=	(OTHERS=>'0');
		Instruction_Ex_in        <=	(OTHERS=>'0');
	elsif( clock'EVENT  AND  clock = '1' and not (flush_id_ex='1'))then
	------------------------Execute - in  section 3-------------------------------------
		read_data_1_ex 			 <= read_data_1_id_ex;	          
		read_data_2_ex 			 <= read_data_2_id_ex;		
		Sign_extend_ex 			 <= Sign_Extend;		   			   
		ALUOp_ex 				 <= ALUop;			       
		ALUSrc_ex 				 <= ALUSrc;
		register_address_ex_1    <= write_reg_address_1;
		register_address_ex_0 	 <= write_reg_address_0;
		PC_plus_4_ex 			 <= PC_plus_4_id_ex;
		RegDst_ex 				 <= RegDst;
		Regwrite_id_ex 		     <= Regwrite_ctl_out;
		MemWrite_id_ex 			 <= MemWrite;
		MemtoReg_id_ex 			 <= MemtoReg;
		MemRead_id_ex 			 <= MemRead;
		Branch_id_ex 			 <= Branch;
		Instruction_Ex_in        <= Instruction_ID_out;
	elsif( clock'EVENT  AND  clock = '1' and  flush_id_ex='1')then
		read_data_1_ex 			 <=	(OTHERS=>'0');	          
		read_data_2_ex 			 <=	(OTHERS=>'0');	
		Sign_extend_ex 			 <=	(OTHERS=>'0');		   			   
		ALUOp_ex 				 <=	(OTHERS=>'0');			       
		ALUSrc_ex 				 <=	'0';
		register_address_ex_1    <=	(OTHERS=>'0');
		register_address_ex_0 	 <=	(OTHERS=>'0');
		PC_plus_4_ex 			 <=	(OTHERS=>'0');
		RegDst_ex 				 <=	(OTHERS=>'0');
		Regwrite_id_ex 		     <=	'0';
		MemWrite_id_ex 			 <=	'0';
		MemtoReg_id_ex 			 <=	(OTHERS=>'0');
		MemRead_id_ex 			 <=	'0';
		Branch_id_ex 			 <=	(OTHERS=>'0');
		Instruction_Ex_in        <=	(OTHERS=>'0');
end if;
END PROCESS;

ex_mem:PROCESS(clock)
BEGIN
	if(reset = '1') then
		Regwrite_mem  	     	 <=	'0';	           
		MemWrite_mem  	     	 <=	'0';		          
		MemtoReg_mem 	     	 <=	(OTHERS=>'0');		   	       
		MemRead_mem  	     	 <=	'0';		  	      
		Zero_mem  	 	 	 	 <=	'0';		      
		ALU_Result_mem  	 	 <=	(OTHERS=>'0');		 
		Add_Result_mem  		 <=	(OTHERS=>'0');			  
		write_reg_address_mem 	 <=	(OTHERS=>'0');            
		read_reg_2_mem 			 <=	(OTHERS=>'0');	         
		PC_plus_4_mem		  	 <=	(OTHERS=>'0');						
		Branch_mem    		 	 <=	(OTHERS=>'0');             
		Instruction_mem_in    	 <=	(OTHERS=>'0');
	elsif( clock'EVENT  AND  clock = '1' and not (flush_ex_mem='1') )then
--------------------------memory - in section 4 ----------------------------------------------		 
		Regwrite_mem  	     	 <= Regwrite_ex_mem;	           
		MemWrite_mem  	     	 <= MemWrite_ex_mem;		          
		MemtoReg_mem 	     	 <= MemtoReg_ex_mem;		   	       
		MemRead_mem  	     	 <= MemRead_ex_mem;		  	      
		Zero_mem  	 	 	 	 <= Zero_ex_mem;		      
		ALU_Result_mem  	 	 <= ALU_Result_ex_mem;		 
		Add_Result_mem  		 <= Add_Result_ex_mem;			  
		write_reg_address_mem 	 <= write_register_address_ex_mem;            
		read_reg_2_mem 			 <= read_reg_2_ex_mem;	         
		PC_plus_4_mem		  	 <= PC_plus_4_ex_mem;						
		Branch_mem    		 	 <= Branch_ex_mem;              
		Instruction_mem_in    	 <= Instruction_Ex_out;
	elsif( clock'EVENT  AND  clock = '1' and  flush_ex_mem='1' )then
		Regwrite_mem  	     	 <=	'0';	           
		MemWrite_mem  	     	 <=	'0';		          
		MemtoReg_mem 	     	 <=	(OTHERS=>'0');		   	       
		MemRead_mem  	     	 <=	'0';		  	      
		Zero_mem  	 	 	 	 <=	'0';		      
		ALU_Result_mem  	 	 <=	(OTHERS=>'0');		 
		Add_Result_mem  		 <=	(OTHERS=>'0');			  
		write_reg_address_mem 	 <=	(OTHERS=>'0');            
		read_reg_2_mem 			 <=	(OTHERS=>'0');	         
		PC_plus_4_mem		  	 <=	(OTHERS=>'0');						
		Branch_mem    		 	 <=	(OTHERS=>'0');             
		Instruction_mem_in    	 <=	(OTHERS=>'0');
	end if;
END PROCESS;

mem_wb:PROCESS(clock)
BEGIN
	if(reset = '1') then
		RegWrite_in				 <=	'0';
		MemtoReg_wb 			 <=	(OTHERS=>'0'); 
		PC_plus_4_wb       		 <=	(OTHERS=>'0');
		write_register_address   <=	(OTHERS=>'0');
		ALU_Result_wb 			 <=	(OTHERS=>'0');
		read_data_wb  			 <=	(OTHERS=>'0');
		Instruction_wb           <=	(OTHERS=>'0');
	elsif( clock'EVENT  AND  clock = '1' )then
---------------------------write back in 	------------------------------------------------
		RegWrite_in				 <= Regwrite_mem_wb ;
		MemtoReg_wb 			 <= MemtoReg_mem_wb; 
		PC_plus_4_wb       		 <= PC_plus_4_mem_wb;
		write_register_address   <= write_reg_address_mem_wb;
		ALU_Result_wb 			 <= ALU_Result_mem_wb;
		read_data_wb  			 <= read_data_mem_wb;
		Instruction_wb           <= Instruction_mem_out;
------------------------------------------------------------------------------------------	
end if;
END PROCESS;
	
-------------------------------CLKCNT register-------------------------------------------	
clkcnt_proc:PROCESS(clock)
	variable clkcnt_temp:integer;
		BEGIN
			if(reset='1') then
				clkcnt_temp:= 0;
				CLKCNT<=(OTHERS=>'0');
			elsif( clock'EVENT  AND  clock = '1' )then
				clkcnt_temp:=clkcnt_temp+1;
				CLKCNT<= CONV_STD_LOGIC_VECTOR( clkcnt_temp, clkcnt_size ) ;
			end if;
END PROCESS;


flush_if_id  <= '1' when PCSrc='1' or not (Jump = "000") else '0';
flush_id_ex  <= '1' when PCSrc='1' else '0';
flush_ex_mem <= '1' when PCSrc='1' else '0';

-------------------------------FHCNT register-------------------------------------------	

flush_proc:PROCESS(flush_if_id,flush_id_ex,flush_ex_mem,clock)
variable flush_temp:integer;
BEGIN
	if(reset = '1') then
		flush_temp := 0;
		FHCNT <= (OTHERS=>'0');
	elsif(clock'EVENT  AND  clock = '1' and flush_if_id = '1' and flush_id_ex = '1' and flush_ex_mem= '1' ) then
		flush_temp:=flush_temp+3;
		FHCNT<= CONV_STD_LOGIC_VECTOR( flush_temp, flush_size ) ;
	elsif(clock'EVENT  AND  clock = '1' and flush_if_id = '1') then
		flush_temp:=flush_temp+1;
		FHCNT<= CONV_STD_LOGIC_VECTOR( flush_temp, flush_size ) ;
	end if;
END PROCESS;	

-------------------------------FHCNT register-------------------------------------------	
stall_count:PROCESS(stall,clock)
variable stall_temp:integer;
BEGIN
	if(reset = '1') then
		stall_temp := 0;
		STCNT <=(OTHERS=>'0');
	elsif(clock'EVENT  AND  clock = '1' and stall = '1') then
		stall_temp:=stall_temp+1;
		STCNT<= CONV_STD_LOGIC_VECTOR( stall_temp, stall_size ) ;
	end if;
END PROCESS;

END structure;

