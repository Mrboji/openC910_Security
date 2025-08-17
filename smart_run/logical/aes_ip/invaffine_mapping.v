`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/25 11:23:16
// Design Name: 
// Module Name: invaffine_mapping
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

module invaffine_mapping(
    input   [`SBOX_INPUT_WIDTH-1:0]       input_data,
    
    output  [`SBOX_INPUT_WIDTH-1:0]       output_data
    );
    
    wire    tmpx3x4x5x6x7   =   input_data[3] ^ input_data[4] ^ input_data[5] ^ input_data[6] ^ input_data[7];
    wire    tmpx1x4         =   input_data[1] ^ input_data[4];
    wire    tmpx5x6         =   input_data[5] ^ input_data[6];
    
    assign  output_data[7]  =   input_data[6] ^ input_data[4] ^ input_data[3];  
    assign  output_data[6]  =  ~input_data[3] ^ tmpx3x4x5x6x7 ^ input_data[0];
    assign  output_data[5]  =   tmpx1x4       ^ tmpx5x6;
    assign  output_data[4]  =   tmpx5x6       ^ input_data[2] ^ input_data[1] ^ input_data[0];
    assign  output_data[3]  =   tmpx1x4       ^ input_data[2];
    assign  output_data[2]  =   tmpx3x4x5x6x7 ^ input_data[2];
    assign  output_data[1]  =  ~input_data[2] ^ input_data[6] ^ input_data[7];
    assign  output_data[0]  =   tmpx3x4x5x6x7 ^ input_data[0];

    
endmodule
