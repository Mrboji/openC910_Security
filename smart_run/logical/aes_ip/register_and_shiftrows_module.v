`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/09 22:48:08
// Design Name: 
// Module Name: register_and_shiftrows_module
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

`define count_cycle_width 2
//`define count_cycle_number_width 5
`define data_width 32

module register_and_shiftrows_module(
    input                              clk,
    input                              rst_n,
    input                              mode,                    //0 means encryption,1 means decryption
    input                              done_round,              //the round when output data,made by counter module
    input   [`count_cycle_width-1:0]   count_cycle,             //display which cycle in per round,made by counter module
    //input   [`count_cycle_number_width-1:0] count_cycle_number, //display which round, made by counter module
    //input                              input_round,             //means count_cycle_number == 5'b1
    input                              idle_round,              //means count_cycle_number == 5'b0, AES IP doesn't active
    input   [`data_width-1:0]          input_data,
    output  [`data_width-1:0]          output_data
    );
    
    wire    [`data_width/4-1:0]        w0_input_wire,w1_input_wire,w2_input_wire,w3_input_wire;
    wire    [`data_width/4-1:0]        w0_output_wire,w1_output_wire,w2_output_wire,w3_output_wire;
    
    reg     [`data_width-1:0]          w0_reg,w1_reg,w2_reg,w3_reg;                         //4*32bit shift register
    
    assign  w0_input_wire   =   input_data[31:24];
    assign  w1_input_wire   =   mode? input_data[07:00] : input_data[23:16];
    assign  w2_input_wire   =   input_data[15:08];
    assign  w3_input_wire   =   mode? input_data[23:16] : input_data[07:00];
    
    assign  w0_output_wire  =   w0_reg[31:24];
    assign  w1_output_wire  =   (done_round || (count_cycle == 2'd3)) ? w1_reg[31:24] : w1_reg[23:16];
    assign  w2_output_wire  =   (done_round || (count_cycle >= 2'd2)) ? w2_reg[31:24] : w2_reg[15:08];
    assign  w3_output_wire  =   (done_round || (count_cycle >= 2'd1)) ? w3_reg[31:24] : w3_reg[07:00];
    
    assign  output_data     =   mode ? {w0_output_wire,w3_output_wire,w2_output_wire,w1_output_wire} : {w0_output_wire,w1_output_wire,w2_output_wire,w3_output_wire};
    
    always  @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            w0_reg  <=  'b0;
            w1_reg  <=  'b0;
            w2_reg  <=  'b0;
            w3_reg  <=  'b0;
        end
        //else if(count_cycle_number == 'b0) begin  
        else if(idle_round) begin              
            w0_reg  <=  'b0;
            w1_reg  <=  'b0;
            w2_reg  <=  'b0;
            w3_reg  <=  'b0;
        end
        
        /*
        //else if(count_cycle_number == 'b1) begin                //input_data_round
        else if(input_round) begin
            w0_reg  <=  {w0_reg[23:0],w0_input_wire};
            w1_reg  <=  {w1_reg[23:0],w1_input_wire};
            w2_reg  <=  {w2_reg[23:0],w2_input_wire};
            w3_reg  <=  {w3_reg[23:0],w3_input_wire};
        end
        */
        
        else begin
            w0_reg  <=  {w0_reg[23:0],w0_input_wire};           //shift register w0_reg
            
            if(done_round)                                     //shift register w1_reg ,maybe do not need input_round
                w1_reg <= {w1_reg[23:0],w1_input_wire};
            else if(count_cycle==2'b11)
                w1_reg <= {w1_reg[23:0],w1_input_wire};   
            else
                w1_reg <= {w1_reg[31:24],w1_reg[15:0],w1_input_wire};
                
            if(done_round)                                      //shift register w2_reg
                w2_reg <= {w2_reg[23:0],w2_input_wire};
            else if(count_cycle >= 2'b10)
                w2_reg <= {w2_reg[23:0],w2_input_wire};
            else
                w2_reg <= {w2_reg[31:16],w2_reg[07:00],w2_input_wire};
                
            if(done_round)                                      //shift register w3_reg
                w3_reg <= {w3_reg[23:0],w3_input_wire};
            else if(count_cycle >= 2'b01)
                w3_reg <= {w3_reg[23:0],w3_input_wire};
            else
                w3_reg <= {w3_reg[31:08],w3_input_wire};    
            
        end
    end
    
endmodule
