`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/20 11:46:44
// Design Name: 
// Module Name: invmap_to_GF16
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

module invmap_to_GF16(
    input       [`SBOX_INPUT_WIDTH-1:0]     input_data_in_GF16,
    output      [`SBOX_INPUT_WIDTH-1:0]     output_data_in_GF256
    );
    
    wire    tmpx1x3x6x7 =   input_data_in_GF16[1] ^ input_data_in_GF16[3] ^ input_data_in_GF16[6] ^ input_data_in_GF16[7];  
    wire    tmpx5x7     =   input_data_in_GF16[5] ^ input_data_in_GF16[7];
    
    assign  output_data_in_GF256[7] =   input_data_in_GF16[2] ^ input_data_in_GF16[7];
    assign  output_data_in_GF256[6] =   input_data_in_GF16[2] ^ tmpx1x3x6x7;
    assign  output_data_in_GF256[5] =   input_data_in_GF16[2];
    assign  output_data_in_GF256[4] =   tmpx1x3x6x7 ^ input_data_in_GF16[4];
    assign  output_data_in_GF256[3] =   input_data_in_GF16[1] ^ input_data_in_GF16[5] ^ input_data_in_GF16[6];
    assign  output_data_in_GF256[2] =   tmpx5x7 ^ input_data_in_GF16[1];
    assign  output_data_in_GF256[1] =   tmpx5x7 ^ input_data_in_GF16[4];
    assign  output_data_in_GF256[0] =   tmpx5x7 ^ input_data_in_GF16[6] ^ input_data_in_GF16[0];
     
    
    
    /*
    wire    tmpx0x1x4x6 =   input_data_in_GF16[0] ^ input_data_in_GF16[1] ^ input_data_in_GF16[4] ^ input_data_in_GF16[6];
    wire    tmpx0x2     =   input_data_in_GF16[0] ^ input_data_in_GF16[2];
    
    assign  output_data_in_GF256[0] =   input_data_in_GF16[0] ^ input_data_in_GF16[5];
    assign  output_data_in_GF256[1] =   tmpx0x1x4x6           ^ input_data_in_GF16[5];
    assign  output_data_in_GF256[2] =   input_data_in_GF16[5];
    assign  output_data_in_GF256[3] =   tmpx0x1x4x6           ^ input_data_in_GF16[3];
    assign  output_data_in_GF256[4] =   input_data_in_GF16[1] ^ input_data_in_GF16[2] ^ input_data_in_GF16[6];
    assign  output_data_in_GF256[5] =   tmpx0x2               ^ input_data_in_GF16[6];
    assign  output_data_in_GF256[6] =   tmpx0x2               ^ input_data_in_GF16[3];
    assign  output_data_in_GF256[7] =   tmpx0x2               ^ input_data_in_GF16[1] ^ input_data_in_GF16[7];
    */

endmodule
