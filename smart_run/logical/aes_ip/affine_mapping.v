`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/25 11:44:37
// Design Name: 
// Module Name: affine_mapping
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

module affine_mapping(
    input   [`SBOX_INPUT_WIDTH-1:0]       input_data,
    
    output  [`SBOX_INPUT_WIDTH-1:0]       output_data
    );
    
    wire    tmpx4x5x6   =   input_data[4] ^ input_data[5] ^ input_data[6];
    wire    tmpx0x4     =   input_data[0] ^ input_data[4];
    wire    tmpx1x3x5x7 =   input_data[1] ^ input_data[3] ^ input_data[5] ^ input_data[7]; 
    
    assign  output_data[7]  =  ~input_data[3] ^ input_data[4] ^ input_data[6];
    assign  output_data[6]  =  ~input_data[2] ^ tmpx4x5x6     ^ input_data[7]; 
    assign  output_data[5]  =   tmpx4x5x6     ^ input_data[1];
    assign  output_data[4]  =   input_data[2] ^ input_data[5] ^ tmpx0x4;
    assign  output_data[3]  =  ~input_data[0] ^ input_data[6]; 
    assign  output_data[2]  =  ~input_data[2] ^ tmpx1x3x5x7;
    assign  output_data[1]  =  ~input_data[1] ^ input_data[7] ^ tmpx0x4;
    assign  output_data[0]  =  ~input_data[0] ^ tmpx1x3x5x7;
    
    
endmodule
