`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/19 11:30:53
// Design Name: 
// Module Name: AES_IP_top_design_by_dong
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`include "C:\Vivado\DongZhaojie\test_graduation_project\aes_define.vh"
//`define USE_SMALLER_KEY_EXPANSION 1
//`define ALL_CASE                  1

module AES_IP_top_design_by_dong(
    input                   clk,
    input                   rst_n,
    input                   start,                      //start signal would be high for 1 cycle,early than input_text and key
    input    [31:0]         input_text,
    input    [31:0]         input_key,
    input                   mode,                       //0 means encryption, 1 means decryption
    input    [1:0]          key_width,                  //2'b00 means 128bit, 2'b01 means 192bit, 2'b10 means 256bit
    
    input bug_9_round_en,

    `ifdef AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ
    output  [31:0]            intermediate_data,
    `endif
    
    output                  done,
    output   [31:0]         output_text
    );
    
    `ifdef USE_SMALLER_KEY_EXPANSION
   	parameter		IDLE		=	2'b00;
	parameter		INPUT_KEY	=	2'b01;
	parameter		ENC_PROCESS	=	2'b10;
	parameter		DEC_PROCESS	=	2'b11;

	wire     [2:0]          key_expand_cycle_max;                       //record max number of key_expand_cycle_number
    wire     [3:0]          key_expand_round_max;                       //record max number of key_expand_round_number      
    wire     [3:0]          main_control_count_round_max;
    wire                    input_round;  
    wire                    last_round;
    wire                    done_round;
    wire                    idle_round;
    wire     [31:0]         round_key;
    wire     [31:0]         input_data; 
	wire                    initial_key_input_round;
    
    reg      [1:0]          key_expansion_current_state, key_expansion_next_state;
    reg      [2:0]          key_expansion_counter;						//used in INPUT_KEY and DEC_PROCESS for initial key   
    reg      [2:0]          key_expand_cycle_number;
    reg      [3:0]          key_expand_round_number;
    reg      [4:0]          main_control_count_round;
    reg      [1:0]          main_control_count_cycle;
    reg      [127:0]        input_text_shift_register;
	reg						jump_to_dec;
	reg 	 [2:0]			output_counter;								//used in DEC_PROCESS to output plaintext in 4 cycles

	////////////////////////////////////////////////////////////////////////////////
	//							computate     cycle_round_max 		 			  //
	////////////////////////////////////////////////////////////////////////////////
	wire	 [1:0] 			cycle_round_max = key_width==2'b01 ? 2'd2 : 2'b1;
	//cycle_number_max equal to 3 defaultly
	
	
	////////////////////////////////////////////////////////////////////////////////
	//						some middle value for decreasing area  	  			  //
	////////////////////////////////////////////////////////////////////////////////
	wire key_expand_cycle_number_equal_to_3 		= 	key_expand_cycle_number==3'd3;
	wire key_expand_round_number_equal_to_max		= 	key_expand_round_number==key_expand_round_max;
	wire main_control_count_cycle_equal_to_3		=	main_control_count_cycle=='d3;
	wire main_control_count_round_equal_to_max_plus =	main_control_count_round == (main_control_count_round_max+1'b1);
	wire main_control_count_round_equal_to_zero		=	main_control_count_round == 'b0;
	
	////////////////////////////////////////////////////////////////////////////////
	//			how to generate these signal? need extra considerasion			  //
	////////////////////////////////////////////////////////////////////////////////
	reg		 [1:0]			cycle_number;
	reg		 [1:0]			cycle_round;
	////////////////////////////////////////////////////////////////////////////////
	
	assign  initial_key_input_round = key_expansion_current_state == INPUT_KEY;
	assign  done                    = done_round;
	
	////////////////////////////////////////////////////////////////////////////////
    //          computate key_expand_cycle_max and key_expand_round_max           //
    ////////////////////////////////////////////////////////////////////////////////
    assign  key_expand_cycle_max = {key_width,1'b0} + 3'd3;             //when key_width==128bit,key_expand_cycle_max==3;when key_width==192bit,key_expand_cycle_max==5;when key_width==256bit,key_expand_cycle_max==7
    assign  key_expand_round_max = key_width==2'b00 ? 4'd9 : key_width==2'b01 ? 4'd7 : key_width==2'b10 ? 4'd6 : 4'b0;  //when key_width==128bit,key_expand_round_max==9;when key_width==192bit,key_expand_round_max==7;when key_width==256bit,key_expand_round_max==6;

    // when key_width==128bit,main_control_count_round_max==10;
    // when key_width==192bit,main_control_count_round_max==12;
    // when key_width==256bit,main_control_count_round_max==14;
	assign  main_control_count_round_max = (bug_9_round_en)? {key_width,1'b0} + 4'd10 : {key_width,1'b0} + 4'd11;    
    
	////////////////////////////////////////////////////////////////////////////////
    //                              main    fsm                                   //
    ////////////////////////////////////////////////////////////////////////////////
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            key_expansion_current_state <= IDLE;
        else
            key_expansion_current_state <= key_expansion_next_state;
    end
	
	always  @(*) begin  
        case(key_expansion_current_state)
            IDLE: begin
                if(start)
                    key_expansion_next_state = INPUT_KEY;
                else
                    key_expansion_next_state = IDLE;
            end
			INPUT_KEY: begin
				if(key_expansion_counter==key_expand_cycle_max)
                    key_expansion_next_state = ENC_PROCESS;
                else
                    key_expansion_next_state = INPUT_KEY;
			end
			ENC_PROCESS: begin
                if(mode==1'b0 && key_expand_cycle_number_equal_to_3 && key_expand_round_number_equal_to_max)        
                    key_expansion_next_state = IDLE;
                else if(mode==1'b1 && key_expand_cycle_number_equal_to_3 && key_expand_round_number_equal_to_max)
                    key_expansion_next_state = DEC_PROCESS;
                else
                    key_expansion_next_state = ENC_PROCESS;
            end 
			DEC_PROCESS: begin
			/////////////////////////////////////////////////////////////////////////////////////////////////////
			//need key_expand_cycle_number=='b0 && key_expand_round_number=='b0 |-> key_expansion_counter==key_expansion_counter_max |-> 4cycle to output plaintext
			/////////////////////////////////////////////////////////////////////////////////////////////////////
				if(output_counter==3'd4)
				//if(key_expansion_counter==3'd4 && key_expand_cycle_number=='b0 && key_expand_round_number=='b0) 
                    key_expansion_next_state = IDLE;
                else
                    key_expansion_next_state = DEC_PROCESS;
            end
            default:;
        endcase
	end
	
	always	@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			key_expand_cycle_number <= 'b0;
            key_expand_round_number <= 'b0;
            key_expansion_counter   <= 'b0;
			jump_to_dec				<= 'b0;
			cycle_number			<= 'b0;
			cycle_round				<= 'b0;
			output_counter			<= 'b0;
			
		end
		else begin
			key_expand_cycle_number <= 'b0;
            key_expand_round_number <= 'b0;
            key_expansion_counter   <= 'b0;
			jump_to_dec				<= 'b0;
			cycle_number			<= 'b0;
			cycle_round				<= 'b0;
			output_counter			<= 'b0;
			
			case(key_expansion_current_state)
				IDLE: begin
                    key_expand_cycle_number <= 'b0;
					key_expand_round_number <= 'b0;
					key_expansion_counter   <= 'b0;
					jump_to_dec				<= 'b0;
					cycle_number			<= 'b0;
					cycle_round				<= 'b0;
					output_counter			<= 'b0;
                end
				INPUT_KEY: begin
					key_expansion_counter <= key_expansion_counter + 1'b1;
				end
				ENC_PROCESS: begin
					if(key_expand_cycle_number != key_expand_cycle_max) begin
                        key_expand_cycle_number <=  key_expand_cycle_number + 1'b1;
                        key_expand_round_number <=  key_expand_round_number; 
                    end
					else if(key_expand_round_number==key_expand_round_max && key_expand_cycle_number_equal_to_3) begin
						key_expand_cycle_number <=  key_expand_cycle_number;
                        key_expand_round_number <=  key_expand_round_number; 
					end
                    else begin
                        key_expand_cycle_number <=  'b0;
                        key_expand_round_number <=  key_expand_round_number + 1'b1;
                    end
					
					if(key_expansion_next_state == DEC_PROCESS)
						jump_to_dec				<= 1'b1;
					else
						jump_to_dec				<= 1'b0;
						
					if(cycle_number==2'd3 && cycle_round!=cycle_round_max) begin
						cycle_number			<= 'd0;
						cycle_round 			<= cycle_round + 1'b1; 
					end
					else if(cycle_number==2'd3 && cycle_round==cycle_round_max) begin
						cycle_number			<= 'd0;
						cycle_round 			<= 'd0;
					end
					else begin
						cycle_number			<= cycle_number + 1'b1;
						cycle_round 			<= cycle_round;
					end
				end
				DEC_PROCESS: begin
					if(jump_to_dec == 1'b1) begin
						key_expand_cycle_number     <=  key_expand_cycle_number;
                        key_expand_round_number     <=  key_expand_round_number;
					end
					else if(key_expand_cycle_number !=  'b0) begin
                        key_expand_cycle_number     <=  key_expand_cycle_number - 1'b1;
                        key_expand_round_number     <=  key_expand_round_number;
                    end
                    else if(key_expand_round_number != 'b0) begin
                        key_expand_cycle_number     <=  key_expand_cycle_max;
                        key_expand_round_number     <=  key_expand_round_number - 1'b1;
                    end
                    else begin                                  							// key_expand_cycle_number == key_expand_cycle_max && key_expand_round_number == 'b0
						key_expand_cycle_number     <=  key_expand_cycle_number;
                        key_expand_round_number     <=  key_expand_round_number;
						
                        if(key_expansion_counter != key_expand_cycle_max)
                            key_expansion_counter   <=  key_expansion_counter + 1'b1;
                        else
                            key_expansion_counter   <=  key_expansion_counter;
							
						if(key_expansion_counter == key_expand_cycle_max)
							output_counter 			<= 	output_counter + 1'b1;
						else
							output_counter 			<=	'b0;	
                    end
					
					if(jump_to_dec == 1'b1) begin
						cycle_number			<= 'd0;
						cycle_round 			<= 'b0;
					end
					else if(cycle_number==2'd3 && cycle_round!=cycle_round_max) begin
						cycle_number			<= 'd0;
						cycle_round 			<= cycle_round + 1'b1; 
					end
					else if(cycle_number==2'd3 && cycle_round==cycle_round_max) begin
						cycle_number			<= 'd0;
						cycle_round 			<= 'd0;
					end
					else begin
						cycle_number			<= cycle_number + 1'b1;
						cycle_round 			<= cycle_round;
					end
					
				end
				default:;
			endcase	
		end
	end
	
	//////////////////////////////////////////////////////////////////////////////// 
    //                        contact with main control                           //
    //////////////////////////////////////////////////////////////////////////////// 
	assign  idle_round  =   main_control_count_round_equal_to_zero;
    assign  input_round =   main_control_count_round=='d1;
    assign  last_round  =   main_control_count_round==main_control_count_round_max;
    assign  done_round  =   main_control_count_round_equal_to_max_plus;
    assign  input_data  =   mode ? input_text_shift_register[127:96] : input_text_shift_register[31:0];
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            main_control_count_round <= 5'b0;
        else if(mode==1'b0)  begin                                                  //when encryption
            if(main_control_count_cycle_equal_to_3 && main_control_count_round_equal_to_max_plus)
                main_control_count_round <= 5'd0;
            else if(main_control_count_cycle_equal_to_3)
                main_control_count_round <= main_control_count_round + 1'b1;
            else if(main_control_count_round_equal_to_zero && initial_key_input_round)
                main_control_count_round <= 5'd1;
            else
                main_control_count_round <= main_control_count_round;
        end
        else begin                                                                  //when decryption
            if(jump_to_dec)
                main_control_count_round <= 5'd1;           
			else if(main_control_count_cycle_equal_to_3 && main_control_count_round_equal_to_max_plus)
                main_control_count_round <= 5'd0;
            else if(main_control_count_cycle_equal_to_3)
                main_control_count_round <= main_control_count_round + 1'b1;
            else
                main_control_count_round <= main_control_count_round;
        end
    end
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            main_control_count_cycle <= 'b0;
        else if(!main_control_count_round_equal_to_zero)
            main_control_count_cycle <= main_control_count_cycle + 1'b1;
    end
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            input_text_shift_register <= 'b0;
        else if(initial_key_input_round && (key_expansion_counter <= 'd3))
            input_text_shift_register <= {input_text_shift_register[95:00],input_text};
        else if(input_round)
            input_text_shift_register <= {input_text_shift_register[95:00],32'b0};
        else
            input_text_shift_register <= input_text_shift_register;
    end	
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //                                  instant submodule                                         //
    ////////////////////////////////////////////////////////////////////////////////////////////////
    key_expansion_with_smaller_area     u_key_expansion_with_smaller_area(
    .clk                            (clk),
    .rst_n                          (rst_n),
    .key_width                      (key_width),                          //2'b00 means 128bit ,2'b01 means 192bit, 2'b10 means 256bit
    .initial_key_input              (input_key),
    .key_expand_round_number        (key_expand_round_number),            //round number record which round ,tips this signal must need reorder!!!
    
  `ifdef ALL_CASE
    .implement_state                (key_expansion_current_state),        //2'b00 IDLE, 2'b01 input key, 2'b10 enc, 2'b11 dec
    .jump_to_dec                    (jump_to_dec),                        //1'b1 means state jump from enc to dec
    .cycle_number                   (cycle_number),                       //cycle number per cycle round
    .cycle_round                    (cycle_round),                        //2'b00 means first round(for 128/192/256) ,2'b01 means second round(for 192/256) ,2'b10 means third round(for 192)
    
  `else
    .key_expand_cycle_number        (key_expand_cycle_number ),           //cycle_number record which cycle in one round,when cycle_number = 3'b0,need rotword+subword+rcon;when cycle_number = 3'd4,need subword
    .key_expansion_idle             (key_expansion_idle), 
    .initial_key_input_round        (initial_key_input_round),            //initial_key enable signal
  `endif 
  
    .round_key                      (round_key)
    );
  
    
    AES_main_control   u_AES_main_control(
    .clk                              (clk),
    .rst_n                            (rst_n),
    .count_cycle                      (main_control_count_cycle),
    .mode                             (mode),
    .input_round                      (input_round),   
    .last_round                       (last_round),
    .done_round                       (done_round),
    .idle_round                       (idle_round),
    .input_data                       (input_data),
    .round_key                        (round_key),
    
    `ifdef AES_IP_WITH_INTERMEDIATE_DATA_CAN_BE_READ
    .intermediate_data                (intermediate_data),
    `endif
    
    .output_data                      (output_text)                       
    );
    
    
    
    `else
    /////////////////////////////////////////////////////////////////
    //                      original design                        //
    /////////////////////////////////////////////////////////////////
    parameter              IDLE                 =       3'b000;
    parameter              INPUT_KEY            =       3'b001;
    parameter              ENCRYPTION_PROCESS   =       3'b010;
    parameter              STAY_STATE           =       3'b011;
    parameter              DECRYPTION_PROCESS   =       3'b100;
    
    wire     [2:0]          key_expand_cycle_max;                       //record max number of key_expand_cycle_number
    wire     [3:0]          key_expand_round_max;                       //record max number of key_expand_round_number      
    wire                    key_expansion_idle;
    wire     [3:0]          main_control_count_round_max;
    wire                    input_round;  
    wire                    last_round;
    wire                    done_round;
    wire                    idle_round;
    wire     [31:0]         round_key;
    wire     [31:0]         input_data;                                 //connect main control module "input_data" port
    
    reg      [2:0]          key_expansion_current_state, key_expansion_next_state;
    reg      [2:0]          key_expansion_counter;
    reg                     initial_key_input_round;
    reg      [2:0]          key_expand_cycle_number;
    reg      [3:0]          key_expand_round_number;
    reg                     state;
    reg                     stay;
    reg      [4:0]          main_control_count_round;
    reg      [1:0]          main_control_count_cycle;
    reg      [127:0]        input_text_shift_register;
    
    assign  key_expansion_idle = key_expansion_current_state == IDLE;
    assign  done               = done_round;
    
    ////////////////////////////////////////////////////////////////////////////////
    //          computate key_expand_cycle_max and key_expand_round_max           //
    ////////////////////////////////////////////////////////////////////////////////
    assign  key_expand_cycle_max = {key_width,1'b0} + 3'd3;             //when key_width==128bit,key_expand_cycle_max==3;when key_width==192bit,key_expand_cycle_max==5;when key_width==256bit,key_expand_cycle_max==7
    assign  key_expand_round_max = key_width==2'b00 ? 4'd9 : key_width==2'b01 ? 4'd7 : key_width==2'b10 ? 4'd6 : 4'b0;  //when key_width==128bit,key_expand_round_max==9;when key_width==192bit,key_expand_round_max==7;when key_width==256bit,key_expand_round_max==6;
    
    assign  main_control_count_round_max = {key_width,1'b0} + 4'd11;    //when key_width==128bit,main_control_count_round_max==11;when key_width==192bit,main_control_count_round_max==13;when key_width==256bit,main_control_count_round_max==15;
    
    ////////////////////////////////////////////////////////////////////////////////
    //                   generate  initial_key_input_round                        //
    ////////////////////////////////////////////////////////////////////////////////
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            initial_key_input_round <= 1'b0;
        else if(start)
            initial_key_input_round <= 1'b1;
        else if(key_expansion_counter == key_expand_cycle_max)
            initial_key_input_round <= 1'b0;
        else
            initial_key_input_round <= initial_key_input_round;
    end
    
    ////////////////////////////////////////////////////////////////////////////////
    //                              main    fsm                                   //
    ////////////////////////////////////////////////////////////////////////////////
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            key_expansion_current_state <= IDLE;
        else
            key_expansion_current_state <= key_expansion_next_state;
    end
    
    always  @(*) begin  
        case(key_expansion_current_state)
            IDLE: begin
                if(start)
                    key_expansion_next_state <= INPUT_KEY;
                else
                    key_expansion_next_state <= IDLE;
            end
            INPUT_KEY: begin
                if(key_expansion_counter==key_expand_cycle_max)
                    key_expansion_next_state <= ENCRYPTION_PROCESS;
                else
                    key_expansion_next_state <= INPUT_KEY;
            end
            ENCRYPTION_PROCESS: begin
                if(mode==1'b0 && key_expand_cycle_number==3'd3 && key_expand_round_number==key_expand_round_max)        //
                    key_expansion_next_state <= IDLE;
                else if(mode==1'b1 && key_expand_cycle_number==3'd3 && key_expand_round_number==key_expand_round_max)
                    key_expansion_next_state <= STAY_STATE;
                else
                    key_expansion_next_state <= ENCRYPTION_PROCESS;
            end 
            STAY_STATE: begin
                if(key_expansion_counter == key_expand_cycle_max)
                    key_expansion_next_state <= DECRYPTION_PROCESS;
                else
                    key_expansion_next_state <= STAY_STATE;
            end  
            DECRYPTION_PROCESS: begin
                if(key_expansion_counter==3'd4 && key_expand_cycle_number=='b0 && key_expand_round_number=='b0)            //key_expansion_counter used to hold up for another 4 cycle,�˴����������⣿key_expansion_counter==3'd3����
                //if(key_expansion_counter==3'd4)
                    key_expansion_next_state <= IDLE;
                else
                    key_expansion_next_state <= DECRYPTION_PROCESS;
            end
            default:;
        endcase
    end
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            key_expand_cycle_number <= 'b0;
            key_expand_round_number <= 'b0;
            state                   <= 'b0; 
            stay                    <= 'b0;
            key_expansion_counter   <= 'b0;
        
        end 
        else begin
            key_expand_cycle_number <= 'b0;
            key_expand_round_number <= 'b0;
            state                   <= 'b0; 
            stay                    <= 'b0;
            key_expansion_counter   <= 'b0;
            
            case(key_expansion_current_state)
                IDLE: begin
                    key_expand_cycle_number <= 'b0;
                    key_expand_round_number <= 'b0;
                    state                   <= 'b0; 
                    stay                    <= 'b0;
                    key_expansion_counter   <= 'b0;
                
                end
                INPUT_KEY: begin
                    key_expansion_counter   <= key_expansion_counter + 1'b1;
                end
                ENCRYPTION_PROCESS: begin
                    if(key_expand_cycle_number != key_expand_cycle_max && key_expand_round_number != key_expand_round_max) begin
                        key_expand_cycle_number <=  key_expand_cycle_number + 1'b1;
                        key_expand_round_number <=  key_expand_round_number; 
                    end
                    else if(key_expand_cycle_number == key_expand_cycle_max && key_expand_round_number != key_expand_round_max) begin
                        key_expand_cycle_number <=  'b0;
                        key_expand_round_number <=  key_expand_round_number + 1'b1;
                    end
                    else if(key_expand_cycle_number != 'd3 && key_expand_round_number == key_expand_round_max) begin
                        key_expand_cycle_number <=  key_expand_cycle_number + 1'b1;
                        key_expand_round_number <=  key_expand_round_number;
                    end
                    else begin
                        key_expand_cycle_number <=  key_expand_cycle_number;
                        key_expand_round_number <=  key_expand_round_number;
                    end
                    
                    if(key_expansion_next_state == STAY_STATE) begin
                        state                   <=  1'b1;
                        stay                    <=  1'b1;
                    end
                end
                STAY_STATE: begin
                    key_expand_cycle_number <=  key_expand_cycle_number;                            //key_expand_cycle_number hold up during STAY_STATE
                    key_expand_round_number <=  key_expand_round_number;                            //key_expand_round_number hold up during STAY_STATE
                    key_expansion_counter   <=  key_expansion_counter + 1'b1; 
                    state                   <=  1'b1;
                    if(key_expansion_next_state == DECRYPTION_PROCESS)
                        stay                <=  1'b0;
                    else
                        stay                <=  stay;
                end
                DECRYPTION_PROCESS: begin
                    if(key_expansion_next_state == IDLE)
                        state               <=  1'b0;
                    else
                        state               <=  1'b1;
                    
                    if(key_expand_cycle_number != 'b0) begin
                        key_expand_cycle_number     <=  key_expand_cycle_number - 1'b1;
                        key_expand_round_number     <=  key_expand_round_number;
                    end
                    else if(key_expand_round_number != 'b0) begin
                        key_expand_cycle_number     <=  key_expand_cycle_max;
                        key_expand_round_number     <=  key_expand_round_number - 1'b1;
                    end
                    else begin                                  // key_expand_cycle_number == 'b0 && key_expand_round_number == 'b0
                        key_expand_cycle_number     <=  key_expand_cycle_number;
                        key_expand_round_number     <=  key_expand_round_number;
                        if(key_expansion_counter != 'd4)
                            key_expansion_counter   <=  key_expansion_counter + 1'b1;
                        else
                            key_expansion_counter   <=  'b0;
                    end 
                end
                default:;
            endcase
        end    
    end
    ////////////////////////////////////////////////////////////////////////////////    
    
    //////////////////////////////////////////////////////////////////////////////// 
    //                        contact with main control                           //
    //////////////////////////////////////////////////////////////////////////////// 
    assign  idle_round  =   main_control_count_round=='d0;
    assign  input_round =   main_control_count_round=='d1;
    assign  last_round  =   main_control_count_round==main_control_count_round_max;
    assign  done_round  =   main_control_count_round==main_control_count_round_max+1'b1;
    assign  input_data  =   mode ? input_text_shift_register[127:96] : input_text_shift_register[31:0];
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            main_control_count_round <= 5'b0;
        else if(mode==1'b0)  begin                                                  //when encryption
            if(main_control_count_cycle_equal_to_3 && main_control_count_round==main_control_count_round_max+1'b1)
                main_control_count_round <= 5'd0;
            else if(main_control_count_cycle_equal_to_3)
                main_control_count_round <= main_control_count_round + 1'b1;
            else if(main_control_count_round==5'b0 && initial_key_input_round==1'b1)
                main_control_count_round <= 5'd1;
            else
                main_control_count_round <= main_control_count_round;
        end
        else begin                                                                  //when decryption
            if((key_width==2'b01 || key_width==2'b10) && key_expansion_current_state==STAY_STATE && key_expansion_counter=='d4)
                main_control_count_round <= 5'd1;
            else if(key_width==2'b00 && key_expansion_current_state==DECRYPTION_PROCESS && key_expand_round_number==key_expand_round_max && key_expand_cycle_number=='d3)    
                main_control_count_round <= 5'd1;
            else if(main_control_count_cycle_equal_to_3 && main_control_count_round==main_control_count_round_max+1'b1)
                main_control_count_round <= 5'd0;
            else if(main_control_count_cycle_equal_to_3)
                main_control_count_round <= main_control_count_round + 1'b1;
            else
                main_control_count_round <= main_control_count_round;
        end
    end
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n) 
            main_control_count_cycle <= 'b0;
        else if(main_control_count_round != 'b0)
            main_control_count_cycle <= main_control_count_cycle + 1'b1;
    end
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            input_text_shift_register <= 'b0;
        else if(initial_key_input_round && (key_expansion_counter <= 'd3))
            input_text_shift_register <= {input_text_shift_register[95:00],input_text};
        else if(input_round)
            input_text_shift_register <= {input_text_shift_register[95:00],32'b0};
        else
            input_text_shift_register <= input_text_shift_register;
    end
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    //                                  instant submodule                                         //
    ////////////////////////////////////////////////////////////////////////////////////////////////
    key_expansion       u_key_expansion(
    .clk                            (clk),
    .rst_n                          (rst_n),
    .key_width                      (key_width),                          
    .initial_key_input_round        (initial_key_input_round),          
    .initial_key_input              (input_key),
    .key_expand_cycle_number        (key_expand_cycle_number),         
    .key_expand_round_number        (key_expand_round_number),        
    .state                          (state),                             
    .key_expansion_idle             (key_expansion_idle), 
    .stay                           (stay),                           
    .round_key                      (round_key) 
    );
    
    AES_main_control   u_AES_main_control(
    .clk                              (clk),
    .rst_n                            (rst_n),
    .count_cycle                      (main_control_count_cycle),
    .mode                             (mode),
    .input_round                      (input_round),   
    .last_round                       (last_round),
    .done_round                       (done_round),
    .idle_round                       (idle_round),
    .input_data                       (input_data),
    .round_key                        (round_key),
    .output_data                      (output_text)                       
    );
    
    `endif
   
   endmodule
