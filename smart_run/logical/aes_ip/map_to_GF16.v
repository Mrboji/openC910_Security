`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/20 11:05:27
// Design Name: 
// Module Name: map_to_GF16
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

//`include "aes_ip_defines.v"

`define	 SBOX_INPUT_WIDTH				8

module map_to_GF16(
    input       [`SBOX_INPUT_WIDTH-1:0]     input_data,
    output      [`SBOX_INPUT_WIDTH-1:0]     output_data_in_GF16
    );
    
    wire    tmpx5x7     =   input_data[5] ^ input_data[7];
    wire    tmpx1x4x6   =   input_data[1] ^ input_data[4] ^ input_data[6];
    wire    tmpx2x3     =   input_data[2] ^ input_data[3];
    
    assign    output_data_in_GF16[7]    =   tmpx5x7;
    assign    output_data_in_GF16[6]    =   tmpx5x7 ^ tmpx2x3;
    assign    output_data_in_GF16[5]    =   input_data[7] ^ tmpx1x4x6;
    assign    output_data_in_GF16[4]    =   input_data[4] ^ input_data[5] ^ input_data[6];
    assign    output_data_in_GF16[3]    =   input_data[1] ^ input_data[3] ^ input_data[4];
    assign    output_data_in_GF16[2]    =   input_data[5];
    assign    output_data_in_GF16[1]    =   tmpx1x4x6 ^ input_data[2] ^ input_data[5];
    assign    output_data_in_GF16[0]    =   tmpx1x4x6 ^ tmpx2x3 ^ input_data[0] ^ input_data[7];
    
    
   /* 
   wire     tmpx0x2     =   input_data[0] ^ input_data[2];
   wire     tmpx1x3x6   =   input_data[1] ^ input_data[3] ^ input_data[6];
   wire     tmpx4x5     =   input_data[4] ^ input_data[5];
    
   assign    output_data_in_GF16[0]    =   tmpx0x2;
   assign    output_data_in_GF16[1]    =   tmpx0x2 ^ tmpx4x5;
   assign    output_data_in_GF16[2]    =   input_data[0] ^ tmpx1x3x6;
   assign    output_data_in_GF16[3]    =   input_data[1] ^ input_data[2] ^ input_data[3];
   assign    output_data_in_GF16[4]    =   input_data[3] ^ input_data[4] ^ input_data[6];
   assign    output_data_in_GF16[5]    =   input_data[2];
   assign    output_data_in_GF16[6]    =   tmpx1x3x6 ^ input_data[2] ^ input_data[5];
   assign    output_data_in_GF16[7]    =   tmpx1x3x6 ^ tmpx4x5 ^ input_data[0] ^ input_data[7];
   */
    
endmodule
