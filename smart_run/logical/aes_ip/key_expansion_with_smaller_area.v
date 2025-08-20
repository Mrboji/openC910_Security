`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/26 22:18:34
// Design Name: 
// Module Name: key_expansion_with_smaller_area
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

module key_expansion_with_smaller_area(
    input               clk,
    input               rst_n,
    input   [1:0]       key_width,                          //2'b00 means 128bit ,2'b01 means 192bit, 2'b10 means 256bit
    input   [31:0]      initial_key_input,
    input   [3:0]       key_expand_round_number,            //round number record which round ,tips this signal must need reorder!!!
    
  `ifdef ALL_CASE
    input   [1:0]       implement_state,                    //2'b00 IDLE, 2'b01 input key, 2'b10 enc, 2'b11 dec
    input               jump_to_dec,                        //1'b1 means state jump from enc to dec
    input   [1:0]       cycle_number,                       //cycle number per cycle round
    input   [1:0]       cycle_round,                        //2'b00 means first round(for 128/192/256) ,2'b01 means second round(for 192/256) ,2'b10 means third round(for 192)
    
  `else
    input   [2:0]       key_expand_cycle_number,            //cycle_number record which cycle in one round,when cycle_number = 3'b0,need rotword+subword+rcon;when cycle_number = 3'd4,need subword
    input               key_expansion_idle, 
    input               initial_key_input_round,            //initial_key enable signal
  `endif           
    
    output  [31:0]      round_key 
    );
    
  `ifdef ALL_CASE  
    reg     [31:0]      w2,w6;
    wire    [31:0]      w4,w7,w10;
    wire    [31:0]      initial_key_input_in_GF16;
    wire    [1:0]       control_signal_for_rotword_subword_rcon;    //genered by cycle_round and cycle_number
    wire                h_function_by_256,g_function_by_128,g_function_by_192,g_function_by_256;
    
    reg     [255:0]     key_expansion_reg;
    reg     [31:0]      reg_store;
    
    //------------------------------------------------------------------
    //transfer into GF(16)
    //------------------------------------------------------------------
    map_to_GF16     u0_map_to_GF16(
    .input_data                         (initial_key_input[07:00]),
    .output_data_in_GF16                (initial_key_input_in_GF16[07:00])
    );
    
    map_to_GF16     u1_map_to_GF16(
    .input_data                         (initial_key_input[15:08]),
    .output_data_in_GF16                (initial_key_input_in_GF16[15:08])
    );
    
    map_to_GF16     u2_map_to_GF16(
    .input_data                         (initial_key_input[23:16]),
    .output_data_in_GF16                (initial_key_input_in_GF16[23:16])
    );
    
    map_to_GF16     u3_map_to_GF16(
    .input_data                         (initial_key_input[31:24]),
    .output_data_in_GF16                (initial_key_input_in_GF16[31:24])
    );
    
    ////////////////////////////////////////////////////////////////////////////////////
    //               generate control_signal_for_rotword_subword_rcon                 //
    ////////////////////////////////////////////////////////////////////////////////////
    wire                implement_state_0, implement_state_1, implement_state_2, implement_state_3;
    wire                middle_value0,  cycle_round_0, cycle_round_1,cycle_round_2, cycle_number_0, cycle_number_1, cycle_number_2, cycle_number_3;
    wire                key_width_0, key_width_1, key_width_2;
    wire                implement_state_3_cycle_round_2_cycle_number_2;
    
    assign key_width_0       = key_width=='b0;
    assign key_width_1       = key_width=='b1;
    assign key_width_2       = key_width=='d2;
    
    assign middle_value0     = key_width_2==1'b1 && cycle_number_0==1'b1;
    
    assign implement_state_0 = implement_state==2'b00;
    assign implement_state_1 = implement_state==2'b01;
    assign implement_state_2 = implement_state==2'b10;
    assign implement_state_3 = implement_state==2'b11;
    
    assign cycle_round_0     = cycle_round==2'b0;
    assign cycle_round_1     = cycle_round==2'd1;
    assign cycle_round_2     = cycle_round==2'd2;
    
    assign cycle_number_0    = cycle_number==2'b0;
    assign cycle_number_1    = cycle_number==2'b1;
    assign cycle_number_2    = cycle_number==2'd2;
    assign cycle_number_3    = cycle_number==2'd3;
    
    assign implement_state_3_cycle_round_2_cycle_number_2 = implement_state_3==1'b1 && cycle_round_2==1'b1 && cycle_number_2==1'b1;
    
    assign h_function_by_256 = middle_value0==1'b1 && cycle_round_1==1'b1 ;
    assign g_function_by_128 = key_width_0==1'b1 && ((implement_state_2==1'b1 && cycle_number_0==1'b1)||(implement_state_3==1'b1 && cycle_number_3==1'b1));
    assign g_function_by_192 = key_width_1==1'b1 && ((cycle_round_0==1'b1 && cycle_number_0==1'b1)||(implement_state_2 && cycle_round_1==1'b1 && cycle_number_2==1'b1)||(implement_state_3_cycle_round_2_cycle_number_2==1'b1));
    assign g_function_by_256 = middle_value0==1'b1 && cycle_round_0==1'b1 ;
     
    assign control_signal_for_rotword_subword_rcon = (h_function_by_256) ? 2'b10 : (g_function_by_128||g_function_by_192||g_function_by_256) ? 2'b01 : 2'b00;

    ////////////////////////////////////////////////////////////////////////////////////
    //               generate key_expand_round_number to control rcon                 //
    ////////////////////////////////////////////////////////////////////////////////////
    wire   [3:0]       key_expand_round_number_to_control_rcon;
    reg    [2:0]       key_expand_round_number_reg;                 //no need 4bit, 3bit for max_number==7
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            key_expand_round_number_reg  <= 'b0;
        else
            key_expand_round_number_reg  <= key_expand_round_number[2:0];  
    end
    
    assign  key_expand_round_number_to_control_rcon = implement_state_3_cycle_round_2_cycle_number_2 ? key_expand_round_number_reg : key_expand_round_number;
    
    ////////////////////////////////////////////////////////////////////////////////////
    //                key expansion main datapath, excluding counter                  //
    ////////////////////////////////////////////////////////////////////////////////////
    
    assign w7   = w4 ^ w6;
    assign w10  = key_expansion_reg[31:00] ^ key_expansion_reg[127:96];
    
    ////////////////////////////////////////////////////////////////////////////////////
    //                             output round key port                              //
    ////////////////////////////////////////////////////////////////////////////////////
    assign round_key = implement_state_3 && (key_width!=2'b00) && (jump_to_dec != 1'b1) ? key_expansion_reg[159:128] : key_expansion_reg[31:00];
    
    ////////////////////////////////////////////////////////////////////////////////////
    //              combinational circuit, mainly discribe data mux                   //
    ////////////////////////////////////////////////////////////////////////////////////
    always  @(*) begin
      /*
        if(implement_state==2'b01) begin                             //input key
            w0 = initial_key_input;
        end
      */

        if(implement_state_2) begin                         //enc state
            w2 = key_expansion_reg[31:00];
            case(key_width)
                2'b00: begin
                    w6 = key_expansion_reg[127:96];
                end
                2'b01: begin
                    w6 = key_expansion_reg[191:160];
                end
                2'b10: begin
                    w6 = key_expansion_reg[255:224];
                end
                default:;
            endcase
        end
        else if(implement_state_3) begin
            if(key_width_0) begin
                w2  =   key_expansion_reg[63:32];
                w6  =   reg_store;
            end
            else begin
                w2  =   key_expansion_reg[191:160];
                w6  =   key_expansion_reg[159:128];
            end
        end
        else begin
                w2  =   key_expansion_reg[31:00];                        //default assignment to avoid latch
                w6  =   key_expansion_reg[127:96];
        end
    end
    
    ////////////////////////////////////////////////////////////////////////////////////
    //                 sequential circuit, mainly discribe data flow                  //
    ////////////////////////////////////////////////////////////////////////////////////
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)   begin
            key_expansion_reg <= 'b0;
            reg_store         <= 'b0; 
        end
        else if(implement_state_0) begin
            key_expansion_reg <= 'b0;
            reg_store         <= 'b0;
        end
        else if(implement_state_1) begin                        //input key
            key_expansion_reg <= {key_expansion_reg[223:000],initial_key_input_in_GF16};
        end  
        else if(implement_state_2) begin                       //enc state
            key_expansion_reg <= {key_expansion_reg[223:000],w7};
        end
        else if(implement_state_3 && jump_to_dec==1'b1) begin
                case(key_width)
                    2'b00: begin
                        key_expansion_reg[127:000] <= {key_expansion_reg[95:00],key_expansion_reg[127:96]};
                    end
                    2'b01: begin
                        key_expansion_reg[191:000] <= {key_expansion_reg[159:00],key_expansion_reg[191:160]};
                    end
                    2'b10: begin
                        key_expansion_reg[255:000] <= {key_expansion_reg[223:000],key_expansion_reg[255:224]};
                    end
                    default:;
                endcase
        end
        else if(implement_state_3) begin
            if(key_width_0) begin
                case(cycle_number)
                    2'b00: begin
                        key_expansion_reg[127:000] <= {key_expansion_reg[95:32],w10,key_expansion_reg[127:96]};
                        reg_store         <= key_expansion_reg[31:00];
                    end
                    2'b01: begin
                        key_expansion_reg[127:000] <= {key_expansion_reg[95:32],w10,key_expansion_reg[127:96]};
                        reg_store         <= reg_store;
                    end
                    2'b10: begin
                        key_expansion_reg[127:000] <= {key_expansion_reg[95:32],w10,key_expansion_reg[127:96]};
                        reg_store         <= reg_store;
                    end
                    2'b11: begin
                        key_expansion_reg[127:000] <= {key_expansion_reg[127:32],w7};
                        reg_store         <= reg_store;
                    end
                    default:;
                endcase
            end
            else if(key_width_1) begin
                case(cycle_number)
                    2'b00: begin
                        key_expansion_reg[191:000] <= {key_expansion_reg[159:000],key_expansion_reg[191:160]};
                        reg_store                  <= w7;
                    end
                    2'b01: begin
                        key_expansion_reg[191:000] <= {key_expansion_reg[159:000],reg_store};
                        reg_store                  <= w7;
                    end
                    2'b10: begin
                        key_expansion_reg[191:000] <= {key_expansion_reg[159:96],w7,key_expansion_reg[95:00]};
                        reg_store                  <= reg_store;
                    end
                    2'b11: begin
                        key_expansion_reg[191:000] <= {reg_store,key_expansion_reg[127:96],w7,key_expansion_reg[95:00]};
                        reg_store                  <= reg_store;
                    end
                    default:;
                endcase
            end 
            else begin   
                case(cycle_number)
                    2'b00: begin
                        key_expansion_reg[255:000] <= {key_expansion_reg[223:000],key_expansion_reg[255:224]};
                        reg_store                  <= w7;
                    end
                    2'b01: begin
                        key_expansion_reg[255:000] <= {key_expansion_reg[223:192],reg_store,key_expansion_reg[159:000],key_expansion_reg[255:224]};
                        reg_store                  <= w7;
                    end
                    2'b10: begin
                        key_expansion_reg[255:000] <= {key_expansion_reg[223:192],reg_store,key_expansion_reg[159:000],key_expansion_reg[255:224]};
                        reg_store                  <= w7;
                    end
                    2'b11: begin
                        key_expansion_reg[255:000] <= {key_expansion_reg[223:192],reg_store,w7,key_expansion_reg[127:000],key_expansion_reg[255:224]};
                        reg_store                  <= reg_store;
                    end
                    default:;
                endcase 
            end
        end   
    end 
    
    ///////////////////////////////////////////////////////////////////////////////////
    rotword_subword_rcon_with_smaller_area        u_rotword_subword_rcon_with_smaller_area(
    .input_data                 (w2),
    .key_width                  (key_width),                         
    .control_signal             (control_signal_for_rotword_subword_rcon),            
    .key_expand_round_number    (key_expand_round_number_to_control_rcon),            
    .output_data                (w4)
    );
    
    
    /*
    reg_store       u_reg_store(
    .clk            (clk),
    .rst_n          (rst_n),
    .input_data     (w8),
    
    .output_data    (w9)
    );
    */
//------------------------------------------------------------------------------------------------//    
    
  `else
    wire    [31:0]      w0,w1,w2,w3,w5;
    wire    [31:0]      key_output;
    
    ////////////////////////////////////////////////////////////////////////////////////
    //                key expansion main datapath, excluding counter                  //
    ////////////////////////////////////////////////////////////////////////////////////
    reg     [255:0]     key_expansion_reg;
    //reg                 state_reg;
    
    assign  w0  =   initial_key_input_round ? initial_key_input_in_GF16 : w5 ;
    assign  w2  =   key_expansion_reg[31:00];
    assign  w5  =   w1 ^ w3;
    assign  w1  =   key_width==2'b00 ? key_expansion_reg[127:96] : key_width==2'b01 ? key_expansion_reg[191:160] : key_width==2'b10 ? key_expansion_reg[255:224] : 32'b0;
    assign  round_key   =  key_output;
    assign  key_output  =  key_expansion_reg[31:00];
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n)   
            key_expansion_reg <= 'b0;
        else if(key_expansion_idle)  
            key_expansion_reg <= 'b0;      
        else           
            key_expansion_reg <= {key_expansion_reg[223:0],w0};
    end 
    
    
    rotword_subword_rcon        u_rotword_subword_rcon(
    .input_data                 (w2),
    .key_width                  (key_width),                         
    .key_expand_cycle_number    (key_expand_cycle_number),            
    .key_expand_round_number    (key_expand_round_number),            
    .output_data                (w3)
    );
  
  `endif
    
endmodule
